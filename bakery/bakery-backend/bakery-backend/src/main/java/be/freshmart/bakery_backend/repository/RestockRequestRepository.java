package be.freshmart.bakery_backend.repository;

import be.freshmart.bakery_backend.model.RestockRequest;
import org.springframework.data.jpa.repository.JpaRepository;

public interface RestockRequestRepository extends JpaRepository<RestockRequest, Long> {
}
