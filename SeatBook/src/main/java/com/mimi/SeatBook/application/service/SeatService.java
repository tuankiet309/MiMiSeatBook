package com.mimi.SeatBook.application.service;

import com.mimi.SeatBook.persistence.interfaceProjection.AvailableSeat;
import com.mimi.SeatBook.persistence.repository.SeatRepository;
import org.springframework.stereotype.Service;

import java.time.OffsetDateTime;
import java.util.List;

@Service
public class SeatService {
    private final SeatRepository repo;
    public SeatService(SeatRepository repo){ this.repo = repo; }

    public List<AvailableSeat> findAvailable(
            OffsetDateTime start,
            OffsetDateTime end,
            Integer buildingId,
            Integer floorId,
            int page,
            int perPage
    ) {
        return repo.searchAvailableSeats(
                start, end, buildingId, floorId, page, perPage
        );
    }
}