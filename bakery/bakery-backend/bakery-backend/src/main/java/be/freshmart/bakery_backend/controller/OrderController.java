package be.freshmart.bakery_backend.controller;

import be.freshmart.bakery_backend.dto.OrderRequestDto;
import be.freshmart.bakery_backend.dto.OrderResponseDto;
import be.freshmart.bakery_backend.exception.OrderProcessingException;
import be.freshmart.bakery_backend.service.OrderService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;
import java.util.List;

@RestController
@RequestMapping("/orders")
public class OrderController {
    private final OrderService service;

    public OrderController(OrderService service) {
        this.service = service;
    }

    @PostMapping
    public OrderResponseDto createOrder(@RequestBody OrderRequestDto order){
        return service.createOrder(order);
    }

    @GetMapping
    public List<OrderResponseDto> getOrders(){
        return service.getOrders();
    }

    @ExceptionHandler(OrderProcessingException.class)
    public ResponseEntity<Map<String, String>> handleOrderProcessingException(OrderProcessingException exception) {
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(Map.of("message", exception.getMessage()));
    }
}
