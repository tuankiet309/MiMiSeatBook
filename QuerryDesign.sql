--View Seat map
CREATE OR REPLACE VIEW v_seat_map as
SELECT
  s.id           AS seat_id,
  s.name         AS seat_name,
  s.status       AS seat_status,
  f.id           AS floor_id,
  f.floor_number AS floor_number,
  f.building_id  AS building_id
FROM seat s
JOIN floor f   ON s.floor_id    = f.id
JOIN building b ON f.building_id = b.id;
-- Tìm kiếm các phòng còn chỗ và không broke

CREATE OR REPLACE FUNCTION fn_search_available_seats_paginated(
  p_start        TIMESTAMP,
  p_end          TIMESTAMP,
  p_building_id  INT        DEFAULT NULL,
  p_floor_id     INT        DEFAULT NULL,
  p_page         INT        DEFAULT 1,
  p_per_page     INT        DEFAULT 20
)
RETURNS TABLE (
  seat_id     INT,
  building_id INT,
  floor_id    INT,
  seat_name   VARCHAR,
  status      seat_status
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    vm.seat_id,
    vm.building_id,
    vm.floor_id,
    vm.seat_name,
    vm.seat_status
  FROM v_seat_map vm
  WHERE (p_building_id IS NULL OR vm.building_id = p_building_id)
    AND (p_floor_id    IS NULL OR vm.floor_id    = p_floor_id)
    AND vm.seat_status = 'AVAILABLE'
    AND NOT EXISTS (
      SELECT 1
        FROM reservation r
       WHERE r.seat_id = vm.seat_id
         AND r.status NOT IN ('CANCELLED','NO_SHOW','FAIL')
         -- tsrange instead of tstzrange
         AND tsrange(r.start_time, r.end_time) &&
             tsrange(p_start, p_end)
    )
  ORDER BY vm.seat_id
  LIMIT p_per_page
  OFFSET (p_page - 1) * p_per_page;
END;
$$;


-- 2) fn_current_reservations: TIMESTAMP + localtimestamp
CREATE OR REPLACE FUNCTION fn_current_reservations(
  p_user_id INT
)
RETURNS TABLE (
  reservation_id INT,
  seat_id        INT,
  building_id    INT,
  floor_id       INT,
  seat_name      VARCHAR,
  start_time     TIMESTAMP,
  end_time       TIMESTAMP,
  status         reservation_status
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    s.id,
    f.building_id,
    s.floor_id,
    s.name,
    r.start_time,
    r.end_time,
    r.status
  FROM reservation r
  JOIN seat     s ON r.seat_id  = s.id
  JOIN floor    f ON s.floor_id  = f.id
  WHERE r.user_id = p_user_id
    AND r.status IN ('PENDING','RESERVED','IN_USE')
    AND r.end_time >= localtimestamp
  ORDER BY r.start_time;
END;
$$;
-- 3) fn_reservation_history: TIMESTAMP + localtimestamp
CREATE OR REPLACE FUNCTION fn_reservation_history(
  p_user_id  INT,
  p_page     INT DEFAULT 1,
  p_per_page INT DEFAULT 5
)
RETURNS TABLE (
  reservation_id INT,
  seat_id        INT,
  building_id    INT,
  floor_id       INT,
  seat_name      VARCHAR,
  start_time     TIMESTAMP,
  end_time       TIMESTAMP,
  status         reservation_status
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    r.id,
    s.id,
    f.building_id,
    s.floor_id,
    s.name,
    r.start_time,
    r.end_time,
    r.status
  FROM reservation r
  JOIN seat     s ON r.seat_id  = s.id
  JOIN floor    f ON s.floor_id  = f.id
  WHERE r.user_id = p_user_id
    AND r.start_time >= localtimestamp - INTERVAL '1 month'
    AND r.start_time  < localtimestamp
  ORDER BY r.start_time DESC
  LIMIT p_per_page
  OFFSET (p_page - 1) * p_per_page;
END;
$$;

-- 4) fn_seat_status_map: no time columns
CREATE OR REPLACE FUNCTION fn_seat_status_map(
  p_building_id INT DEFAULT NULL,
  p_floor_id    INT DEFAULT NULL
)
RETURNS TABLE (
  building_id INT,
  floor_id    INT,
  seat_id     INT,
  seat_name   VARCHAR,
  status      seat_status
) 
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    vm.building_id, vm.floor_id,
    vm.seat_id, vm.seat_name, vm.seat_status
  FROM (
    SELECT s.id AS seat_id, s.name AS seat_name, s.status AS seat_status,
           f.id AS floor_id, f.building_id
      FROM seat s
      JOIN floor f ON s.floor_id = f.id
  ) vm
  WHERE (p_building_id IS NULL OR vm.building_id = p_building_id)
    AND (p_floor_id    IS NULL OR vm.floor_id    = p_floor_id)
    AND vm.seat_status <> 'BROKEN'
  ORDER BY vm.seat_id;
END;
$$

-- 5) fn_detailed_seat_view: TIMESTAMP + localtimestamp
CREATE OR REPLACE FUNCTION fn_detailed_seat_view(
  p_floor_id INT
)
RETURNS TABLE (
  seat_id               INT,
  seat_name             VARCHAR,
  seat_status           seat_status,
  active_res_id         INT,
  active_res_status     reservation_status,
  active_res_start_time TIMESTAMP,
  active_res_end_time   TIMESTAMP
)
LANGUAGE plpgsql
AS $$
BEGIN
  RETURN QUERY
  SELECT
    s.id,
    s.name,
    s.status,
    ar.id,
    ar.status,
    ar.start_time,
    ar.end_time
  FROM seat s
  LEFT JOIN LATERAL (
    SELECT
      r2.id,
      r2.status,
      r2.start_time,
      r2.end_time
    FROM reservation r2
    WHERE r2.seat_id = s.id
      AND r2.status IN ('PENDING','RESERVED','IN_USE')
      AND r2.start_time <= localtimestamp
      AND r2.end_time   >= localtimestamp
    ORDER BY r2.start_time
    LIMIT 1
  ) AS ar ON TRUE
  WHERE s.floor_id = p_floor_id
  ORDER BY s.id;
END;
$$;
