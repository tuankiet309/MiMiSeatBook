package com.mimi.SeatBook.persistence.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.Table;
import lombok.*;

@Entity
@Table(name = "users")
@Builder
@Getter
@Setter
@Data
public class User extends BaseEntity{
    @Column(nullable=false, unique=true, length=50)
    private String username;

    @Column(nullable=false, unique=true)
    private String email;

    @Column(name="password_hash", nullable=false)
    private String passwordHash;

}
