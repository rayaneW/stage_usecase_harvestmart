package be.freshmart.bakery_backend.repository;

import be.freshmart.bakery_backend.model.Product;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProductRepository extends JpaRepository<Product, Long> {
}