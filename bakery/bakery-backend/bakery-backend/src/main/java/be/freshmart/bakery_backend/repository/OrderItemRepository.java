package be.freshmart.bakery_backend.repository;

import be.freshmart.bakery_backend.model.OrderItem;
import org.springframework.data.jpa.repository.JpaRepository;

public interface OrderItemRepository extends JpaRepository<OrderItem, Long> {
}
