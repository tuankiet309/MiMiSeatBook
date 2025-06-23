package com.mimi.SeatBook.api.controller;

import com.mimi.SeatBook.api.dto.CheckInSeatInDto;
import com.mimi.SeatBook.api.dto.CheckInSeatOutDto;
import com.mimi.SeatBook.api.dto.ReservationRequest;
import com.mimi.SeatBook.application.service.SeatService;
import com.mimi.SeatBook.persistence.interfaceProjection.AvailableSeat;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/seats")
public class SeatController {
    private final SeatService svc;
    public SeatController(SeatService svc){ this.svc = svc; }

    @GetMapping("/available")
    public List<AvailableSeat> available(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime start,
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
            LocalDateTime end,
            @RequestParam(required=false) Integer buildingId,
            @RequestParam(required=false) Integer floorId,
            @RequestParam(defaultValue="1")  int page,
            @RequestParam(defaultValue="20") int perPage
    ) {
        return svc.findAvailable(start, end, buildingId, floorId, page, perPage);
    }

}
