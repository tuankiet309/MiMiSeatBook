package com.mimi.SeatBook.persistence.repository;

import com.mimi.SeatBook.persistence.entity.BaseEntity;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface  BaseEntityRepository extends JpaRepository<BaseEntity, Integer> {
    @Override
    Optional<BaseEntity> findById(Integer integer);

    @Override
    List<BaseEntity> findAllById(Iterable<Integer> integers);
}
