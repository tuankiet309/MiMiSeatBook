package com.mimi.SeatBook.persistence.entity;

import com.mimi.SeatBook.persistence.valueObject.SeatStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "seat")
public class Seat extends BaseEntity {


    @ManyToOne @JoinColumn(name="floor_id", nullable=false)
    private Floor floor;

    @Column(nullable=false, length=100)
    private String name;

    @Enumerated(EnumType.STRING)
    @Column(nullable=false)
    private SeatStatus status;

    @OneToMany(mappedBy="seat")
    private List<Reservation> reservations;




}