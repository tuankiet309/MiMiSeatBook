package com.mimi.SeatBook.persistence.repository;

import com.mimi.SeatBook.persistence.entity.Reservation;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.OffsetDateTime;

public interface ReservationRepository extends JpaRepository<Reservation,Integer> {
    @Query(value = "SELECT fn_reserve_seat(:userId, :seatId, :start, :end)", nativeQuery = true)
    Integer reserveSeat(
            @Param("userId") Integer userId,
            @Param("seatId") Integer seatId,
            @Param("start") OffsetDateTime start,
            @Param("end")    OffsetDateTime end
    );
}
