CREATE OR REPLACE FUNCTION trg_set_timestamps()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    NEW.created_at := COALESCE(NEW.created_at, now());
    NEW.updated_at := COALESCE(NEW.updated_at, now());
  ELSIF TG_OP = 'UPDATE' THEN
    NEW.updated_at := now();
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;



-- users
DROP TRIGGER IF EXISTS set_ts_users ON users;
CREATE TRIGGER set_ts_users
  BEFORE INSERT OR UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION trg_set_timestamps();

-- building
DROP TRIGGER IF EXISTS set_ts_building ON building;
CREATE TRIGGER set_ts_building
  BEFORE INSERT OR UPDATE ON building
  FOR EACH ROW EXECUTE FUNCTION trg_set_timestamps();

-- floor
DROP TRIGGER IF EXISTS set_ts_floor ON floor;
CREATE TRIGGER set_ts_floor
  BEFORE INSERT OR UPDATE ON floor
  FOR EACH ROW EXECUTE FUNCTION trg_set_timestamps();

-- seat
DROP TRIGGER IF EXISTS set_ts_seat ON seat;
CREATE TRIGGER set_ts_seat
  BEFORE INSERT OR UPDATE ON seat
  FOR EACH ROW EXECUTE FUNCTION trg_set_timestamps();

-- reservation
DROP TRIGGER IF EXISTS set_ts_reservation ON reservation;
CREATE TRIGGER set_ts_reservation
  BEFORE INSERT OR UPDATE ON reservation
  FOR EACH ROW EXECUTE FUNCTION trg_set_timestamps();