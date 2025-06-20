package com.mimi.SeatBook.application.service;

import com.mimi.SeatBook.persistence.interfaceProjection.AvailableSeat;
import com.mimi.SeatBook.persistence.repository.SeatRepository;
import jakarta.transaction.Transactional;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.OffsetDateTime;
import java.util.List;

@Service
public class SeatService {
    private final SeatRepository repo;
    public SeatService(SeatRepository repo){ this.repo = repo; }

    public List<AvailableSeat> findAvailable(
            LocalDateTime start,
            LocalDateTime end,
            Integer buildingId,
            Integer floorId,
            int page,
            int perPage
    ) {
        return repo.searchAvailableSeats(
                start, end, buildingId, floorId, page, perPage
        );
    }
    @Transactional
    public Integer reserveSeat(
            Integer userId,
            Integer seatId,
            LocalDateTime start,
            LocalDateTime end
    ) {
        return repo.fnReserveSeat(userId, seatId, start, end);
    }
}