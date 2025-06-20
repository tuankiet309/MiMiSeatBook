package com.mimi.SeatBook.persistence.entity;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.OffsetDateTime;
import java.util.List;

@Getter
@Setter
@Entity
@Table(name = "building")
public class Building  extends BaseEntity{

    @Column(nullable=false)
    private String name;
    @Column(nullable=false, unique=true)
    private String address;
    @OneToMany(mappedBy="building")
    private List<Floor> floors;

}