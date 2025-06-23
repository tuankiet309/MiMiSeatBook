-- Các kiểu ENUM
CREATE TYPE seat_status AS ENUM('AVAILABLE','UNAVAILABLE','BROKEN');
CREATE TYPE reservation_status AS ENUM('PENDING','RESERVED','IN_USE','CANCELLED','NO_SHOW','COMPLETED','FORCED_CANCEL','FAIL');
--CREATE TYPE user_role AS ENUM('EMPLOYEE','ADMIN');
-- Bảng roles
CREATE TABLE roles(
  role_id SERIAL PRIMARY KEY,
  role_name VARCHAR(50) NOT NULL UNIQUE,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);
-- Bảng users
CREATE TABLE users(
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  email VARCHAR(255) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role_id INT NOT NULL REFERENCES roles(role_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);
-- Bảng buildings
CREATE TABLE buildings(
  building_id SERIAL PRIMARY KEY,
  building_name VARCHAR(255) NOT NULL,
  address VARCHAR(255),
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);
-- Bảng floors
CREATE TABLE floors(
  floor_id SERIAL PRIMARY KEY,
  building_id INT NOT NULL REFERENCES buildings(building_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  floor_number INT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);
-- Bảng seat
CREATE TABLE seat(
  seat_id SERIAL PRIMARY KEY,
  seat_name VARCHAR(100) NOT NULL,
  seat_status seat_status NOT NULL DEFAULT 'AVAILABLE',

  floor_id INT NOT NULL REFERENCES floors(floor_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now()
);
-- Bảng reservations
CREATE TABLE reservations(
  reservation_id SERIAL PRIMARY KEY,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  check_in_time TIMESTAMP,
  check_out_time TIMESTAMP,
  reservation_status reservation_status NOT NULL DEFAULT 'PENDING',
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  updated_at TIMESTAMP NOT NULL DEFAULT now(),
  seat_id INT NOT NULL REFERENCES seat(seat_id) ON UPDATE CASCADE ON DELETE RESTRICT,
  user_id INT NOT NULL REFERENCES users(user_id) ON UPDATE CASCADE ON DELETE RESTRICT
);
-- Bảng reservation_history
CREATE TABLE reservation_history(
  reservation_history_id SERIAL PRIMARY KEY,
  start_time TIMESTAMP NOT NULL,
  end_time TIMESTAMP NOT NULL,
  reservation_status reservation_status NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT now(),
  extended_from_reservation_id INT REFERENCES reservations(reservation_id) ON UPDATE CASCADE ON DELETE RESTRICT
);
