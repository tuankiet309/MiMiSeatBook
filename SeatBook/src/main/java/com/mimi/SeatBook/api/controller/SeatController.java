package com.mimi.SeatBook.api.controller;

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
    @PostMapping("/reserve")
    public ResponseEntity<?> reserve(@RequestBody ReservationRequest req) {
        Integer resId = svc.reserveSeat(
                req.getUserId(),
                req.getSeatId(),
                req.getStart(),
                req.getEnd()
        );
        return ResponseEntity.ok(resId);
    }
    public static class ReservationRequest {
        private Integer userId;
        private Integer seatId;
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
        private LocalDateTime start;
        @DateTimeFormat(iso = DateTimeFormat.ISO.DATE_TIME)
        private LocalDateTime end;

        public Integer getUserId() { return userId; }
        public void setUserId(Integer userId) { this.userId = userId; }

        public Integer getSeatId() { return seatId; }
        public void setSeatId(Integer seatId) { this.seatId = seatId; }

        public LocalDateTime getStart() { return start; }
        public void setStart(LocalDateTime start) { this.start = start; }

        public LocalDateTime getEnd() { return end; }
        public void setEnd(LocalDateTime end) { this.end = end; }
    }
}
