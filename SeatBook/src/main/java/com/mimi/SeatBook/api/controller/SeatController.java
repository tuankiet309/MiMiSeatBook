package com.mimi.SeatBook.api.controller;

import com.mimi.SeatBook.application.service.SeatService;
import com.mimi.SeatBook.persistence.interfaceProjection.AvailableSeat;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.OffsetDateTime;
import java.util.List;

@RestController
@RequestMapping("/api/seats")
public class SeatController {
    private final SeatService svc;
    public SeatController(SeatService svc){ this.svc = svc; }

    @GetMapping("/available")
    public List<AvailableSeat> available(
            @RequestParam OffsetDateTime start,
            @RequestParam OffsetDateTime end,
            @RequestParam(required=false) Integer buildingId,
            @RequestParam(required=false) Integer floorId,
            @RequestParam(defaultValue="1") int page,
            @RequestParam(defaultValue="20") int perPage
    )
    {
        return svc.findAvailable(start, end, buildingId, floorId, page, perPage);
    }
}
