package com.mimi.SeatBook.persistence.repository;

import com.mimi.SeatBook.persistence.interfaceProjection.AvailableSeat;
import com.mimi.SeatBook.persistence.entity.Seat;
import io.lettuce.core.dynamic.annotation.Param;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.OffsetDateTime;
import java.util.List;

public interface SeatRepository extends JpaRepository<Seat,Integer> {
    @Query(value = """
  SELECT
    vm.seat_id     AS seatId,
    vm.building_id AS buildingId,
    vm.floor_id    AS floorId,
    vm.seat_name   AS seatName,
    vm.status      AS status
  FROM fn_search_available_seats_paginated(
    :start, :end,
    :buildingId, :floorId,
    :page, :perPage
  ) vm
    """, nativeQuery = true)
    List<AvailableSeat> searchAvailableSeats(
            @Param("start")      OffsetDateTime start,
            @Param("end")        OffsetDateTime end,
            @Param("buildingId") Integer buildingId,
            @Param("floorId")    Integer floorId,
            @Param("page")       Integer page,
            @Param("perPage")    Integer perPage
    );
}