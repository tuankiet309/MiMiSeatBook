package com.mimi.SeatBook.persistence.interfaceProjection;

public interface AvailableSeat {
    Integer getSeatId();
    Integer getBuildingId();
    Integer getFloorId();
    String  getSeatName();
    String  getStatus();
}