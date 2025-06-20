package com.mimi.SeatBook.persistence.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "floor")
public class Floor extends BaseEntity{


    @ManyToOne
    @JoinColumn(name="building_id", nullable=false)
    private Building building;

    @Column(name="floor_number", nullable=false)
    private Integer floorNumber;

    @OneToMany(mappedBy="floor")
    private List<Seat> seats;


}