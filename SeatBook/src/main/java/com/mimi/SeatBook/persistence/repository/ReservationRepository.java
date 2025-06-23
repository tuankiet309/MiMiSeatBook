package com.mimi.SeatBook.persistence.repository;

import com.mimi.SeatBook.persistence.entity.Reservation;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;

public interface ReservationRepository extends JpaRepository<Reservation,Integer> {
    
}
