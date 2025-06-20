-- 1) ENUM types cho trạng thái
CREATE TYPE seat_status AS ENUM (
  'AVAILABLE',
  'UNAVAILABLE'
);

CREATE TYPE reservation_status AS ENUM (
  'PENDING',
  'RESERVED',
  'IN_USE',
  'CANCELLED',
  'NO_SHOW',
  'COMPLETED',
  'FORCED_CANCEL',
  'FAIL'
);
CREATE TYPE  user_role AS ENUM (
  'EMPLOYEE',
  'ADMIN'
);
-- 2) Bảng users

CREATE TABLE  users (
  id             SERIAL PRIMARY KEY,
  username       VARCHAR(50)  NOT NULL UNIQUE,
  email          VARCHAR(255) NOT NULL UNIQUE,
  password_hash  VARCHAR(255) NOT NULL,
  role           user_role    NOT NULL DEFAULT 'EMPLOYEE',
  created_at     TIMESTAMP     NOT NULL DEFAULT now(),
  updated_at     TIMESTAMP     NOT NULL DEFAULT now()
);

-- 3) Bảng building
CREATE TABLE building (
  id             SERIAL PRIMARY KEY,
  name           VARCHAR(255) NOT NULL,
  address        VARCHAR(255),
  created_at     TIMESTAMP     NOT NULL DEFAULT now(),
  updated_at     TIMESTAMP     NOT NULL DEFAULT now()
);

-- 4) Bảng floor
CREATE TABLE floor (
  id             SERIAL PRIMARY KEY,
  building_id    INT NOT NULL
                    REFERENCES building(id)
                      ON UPDATE CASCADE
                      ON DELETE RESTRICT,
  floor_number   INT NOT NULL,
  created_at     TIMESTAMP     NOT NULL DEFAULT now(),
  updated_at     TIMESTAMP     NOT NULL DEFAULT now()
);

-- 5) Bảng seat
CREATE TABLE seat (
  id             SERIAL PRIMARY KEY,
  floor_id       INT NOT NULL
                    REFERENCES floor(id)
                      ON UPDATE CASCADE
                      ON DELETE RESTRICT,
  name           VARCHAR(100) NOT NULL,
  status         seat_status  NOT NULL DEFAULT 'AVAILABLE',
  created_at     TIMESTAMP     NOT NULL DEFAULT now(),
  updated_at     TIMESTAMP     NOT NULL DEFAULT now()
);

-- 6) Bảng reservation
CREATE TABLE reservation (
  id                            SERIAL PRIMARY KEY,
  user_id                       INT NOT NULL
                    REFERENCES users(id)
                      ON UPDATE CASCADE
                      ON DELETE RESTRICT,
  seat_id                       INT NOT NULL
                    REFERENCES seat(id)
                      ON UPDATE CASCADE
                      ON DELETE RESTRICT,
  start_time                    TIMESTAMP     NOT NULL,
  end_time                      TIMESTAMP     NOT NULL,
  status                        reservation_status NOT NULL
                                 DEFAULT 'PENDING',
  check_in_at                   TIMESTAMP,
  created_at                    TIMESTAMP     NOT NULL DEFAULT now(),
  updated_at                    TIMESTAMP     NOT NULL DEFAULT now(),
  extended_from_reservation_id  INT
                    REFERENCES reservation(id)
                      ON UPDATE CASCADE
                      ON DELETE SET NULL
);
