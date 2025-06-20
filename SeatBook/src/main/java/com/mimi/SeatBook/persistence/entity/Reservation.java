package com.mimi.SeatBook.persistence.entity;
import com.mimi.SeatBook.persistence.valueObject.ReservationStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDateTime;
import java.util.List;
@Entity
@Table(name = "reservation")
@Getter
@Setter
public class Reservation extends BaseEntity{
    @ManyToOne @JoinColumn(name="user_id", nullable=false)
    private User user;

    @ManyToOne @JoinColumn(name="seat_id", nullable=false)
    private Seat seat;

    @Column(name="start_time", nullable=false)
    private LocalDateTime  startTime;

    @Column(name="end_time", nullable=false)
    private LocalDateTime endTime;

    @Enumerated(EnumType.STRING)
    @Column(nullable=false)
    private ReservationStatus status;

    @Column(name="check_in_at")
    private LocalDateTime  checkInAt;

    @ManyToOne
    @JoinColumn(name="extended_from_reservation_id")
    private Reservation extendedFrom;

    @OneToMany(mappedBy="extendedFrom")
    private List<Reservation> extensions;
}
