package com.mimi.SeatBook.persistence.repository;

import com.mimi.SeatBook.persistence.interfaceProjection.AvailableSeat;
import com.mimi.SeatBook.persistence.entity.Seat;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.List;
public interface SeatRepository extends JpaRepository<Seat,Integer> {

    @Query(value = """
            SELECT * 
            FROM public.fn_search_available_seats_paginated(
                ?1,?2,?3,?4,?5,?6
            )
            """,
            nativeQuery = true
            )
    List<AvailableSeat> searchAvailableSeats(
            LocalDateTime start,
            LocalDateTime end,
            Integer buildingId,
            Integer floorId,
            int page,
            int perPage
    );
    @Procedure(procedureName = "fn_reserve_seat")
    Integer fnReserveSeat(
            @Param("p_user_id") Integer userId,
            @Param("p_seat_id") Integer seatId,
            @Param("p_start")   LocalDateTime start,
            @Param("p_end")     LocalDateTime end
    );
}