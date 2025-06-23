package com.mimi.SeatBook.api.dto;

import java.time.LocalDateTime;

public class CheckInSeatOutDto {
    private Integer reservationId;
    private LocalDateTime checkInAt;

    public CheckInSeatOutDto(Integer reservationId, LocalDateTime checkInAt) {
        this.reservationId = reservationId;
        this.checkInAt     = checkInAt;
    }

    public Integer getReservationId() { return reservationId; }
    public LocalDateTime getCheckInAt()  { return checkInAt; }
}
