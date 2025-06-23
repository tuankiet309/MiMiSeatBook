package com.mimi.SeatBook.application.service;

import com.mimi.SeatBook.api.dto.CheckInSeatInDto;
import com.mimi.SeatBook.api.dto.CheckInSeatOutDto;
import com.mimi.SeatBook.persistence.interfaceProjection.AvailableSeat;
import com.mimi.SeatBook.persistence.repository.ReservationRepository;
import com.mimi.SeatBook.persistence.repository.SeatRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
public class SeatService {
    private final SeatRepository seatRepo;
    private final ReservationRepository reservationRepo;
    public SeatService(SeatRepository repo, ReservationRepository reservationRepo){
        this.seatRepo = repo;
        this.reservationRepo = reservationRepo;
    }

    public List<AvailableSeat> findAvailable(
            LocalDateTime start,
            LocalDateTime end,
            Integer buildingId,
            Integer floorId,
            int page,
            int perPage
    ) {
        return seatRepo.searchAvailableSeats(
                start, end, buildingId, floorId, page, perPage
        );
    }

}