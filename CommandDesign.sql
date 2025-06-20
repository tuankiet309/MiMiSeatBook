-- Các hàm phụ
CREATE OR REPLACE FUNCTION fn_check_seat_overlap(
  p_seat_id INT,
  p_start   TIMESTAMP,
  p_end     TIMESTAMP
)
RETURNS BOOLEAN
LANGUAGE plpgsql AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
      FROM reservation r
     WHERE r.seat_id = p_seat_id
       AND r.status NOT IN ('CANCELLED','NO_SHOW','FAIL')
       AND tsrange(r.start_time, r.end_time) &&
           tsrange(p_start, p_end)
  );
END;
$$;

-- Tạo reservation (check để tại backend)
CREATE OR REPLACE FUNCTION fn_reserve_seat(
  p_user_id INT,
  p_seat_id INT,
  p_start   TIMESTAMP,
  p_end     TIMESTAMP
)
RETURNS INT
LANGUAGE plpgsql AS $$
DECLARE
  v_res_id INT;
BEGIN
  IF p_start >= p_end THEN
    RAISE EXCEPTION 'start_time (%) must be before end_time (%)', p_start, p_end;
  END IF;

  PERFORM pg_advisory_xact_lock(1, p_seat_id);

  IF fn_check_seat_overlap(p_seat_id, p_start, p_end) THEN
    RAISE EXCEPTION 'Seat % is already booked for that time', p_seat_id;
  END IF;

  INSERT INTO reservation(
    user_id, seat_id, start_time, end_time, status, created_at
  ) VALUES (
    p_user_id, p_seat_id, p_start, p_end, 'PENDING', now()
  )
  RETURNING id INTO v_res_id;

  RETURN v_res_id;
END;
$$;
-- Huỷ reservation (Check status tại backend và check thêm phát nữa ở db)
CREATE OR REPLACE FUNCTION fn_cancel_reservation(
  p_res_id   INT,
  p_user_id  INT,
  p_is_admin BOOLEAN DEFAULT FALSE
)
RETURNS VOID
LANGUAGE plpgsql AS $$
DECLARE
  v_status reservation_status;
  v_owner  INT;
BEGIN
  SELECT status, user_id INTO v_status, v_owner
    FROM reservation
   WHERE id = p_res_id;

  IF v_status <> 'RESERVED' THEN
    RAISE EXCEPTION 'Only RESERVED can be cancelled';
  END IF;
  IF NOT p_is_admin AND v_owner <> p_user_id THEN
    RAISE EXCEPTION 'Not your reservation';
  END IF;

  UPDATE reservation
     SET status = 'CANCELLED'
   WHERE id = p_res_id;
END;
$$;

-- Extend reservation 
CREATE OR REPLACE FUNCTION fn_extend_reservation(
  p_res_id INT
)
RETURNS INT
LANGUAGE plpgsql AS $$
DECLARE
  v_base     RECORD;
  v_new_id   INT;
  v_next_end TIMESTAMP;
  v_midnight TIMESTAMP;
BEGIN
  SELECT * INTO v_base FROM reservation WHERE id = p_res_id;

  IF v_base.status <> 'RESERVED' THEN
    RAISE EXCEPTION 'Can only extend RESERVED';
  END IF;

  v_midnight := date_trunc('day', v_base.start_time) + INTERVAL '1 day';
  v_next_end := v_base.end_time + INTERVAL '1 hour';

  IF v_next_end > v_midnight THEN
    RAISE EXCEPTION 'Cannot extend past midnight';
  END IF;

  IF EXISTS (
    SELECT 1 FROM reservation r
     WHERE r.seat_id = v_base.seat_id
       AND r.id <> p_res_id
       AND r.status NOT IN ('CANCELLED','NO_SHOW','FAIL')
       AND tsrange(r.start_time, r.end_time) &&
           tsrange(v_base.end_time, v_next_end)
  ) THEN
    RAISE EXCEPTION 'Overlap with another reservation';
  END IF;

  INSERT INTO reservation(
    user_id, seat_id, start_time, end_time,
    status, created_at, extended_from_reservation_id
  ) VALUES (
    v_base.user_id, v_base.seat_id,
    v_base.end_time, v_next_end,
    'PENDING', now(), p_res_id
  )
  RETURNING id INTO v_new_id;

  RETURN v_new_id;
END;
$$;
-- Checkin
CREATE OR REPLACE FUNCTION fn_check_in(
  p_res_id INT
)
RETURNS VOID
LANGUAGE plpgsql AS $$
DECLARE
  v_status reservation_status;
BEGIN
  SELECT status INTO v_status FROM reservation WHERE id = p_res_id;
  IF v_status <> 'RESERVED' THEN
    RAISE EXCEPTION 'Only RESERVED can be checked in';
  END IF;

  UPDATE reservation
     SET status = 'IN_USE',
         check_in_at = now()
   WHERE id = p_res_id;

  UPDATE seat
     SET status = 'UNAVAILABLE'
   WHERE id = (SELECT seat_id FROM reservation WHERE id = p_res_id);
END;
$$;


-- Checkout 
CREATE OR REPLACE FUNCTION fn_check_out(
  p_res_id INT
)
RETURNS VOID
LANGUAGE plpgsql AS $$
DECLARE
  v_status reservation_status;
BEGIN
  SELECT status INTO v_status FROM reservation WHERE id = p_res_id;
  IF v_status <> 'IN_USE' THEN
    RAISE EXCEPTION 'Only IN_USE can be returned';
  END IF;

  UPDATE reservation
     SET status = 'COMPLETED'
   WHERE id = p_res_id;

  UPDATE seat
     SET status = 'AVAILABLE'
   WHERE id = (SELECT seat_id FROM reservation WHERE id = p_res_id);
END;
$$;
-- Trả ghế cho tao
CREATE OR REPLACE FUNCTION fn_force_return(
  p_res_id INT
)
RETURNS VOID
LANGUAGE plpgsql AS $$
BEGIN
  UPDATE reservation
     SET status = 'CANCELLED'
   WHERE id = p_res_id
     AND status = 'IN_USE';

  UPDATE reservation
     SET status = 'CANCELLED'
   WHERE extended_from_reservation_id = p_res_id;

  UPDATE seat
     SET status = 'AVAILABLE'
   WHERE id = (SELECT seat_id FROM reservation WHERE id = p_res_id);
END;
$$;