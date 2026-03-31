package be.freshmart.bakery_backend.controller;

import be.freshmart.bakery_backend.exception.RestockProcessingException;
import be.freshmart.bakery_backend.model.RestockRequest;
import be.freshmart.bakery_backend.service.RestockService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/restocks")
public class RestockController {

    private final RestockService restockService;

    public RestockController(RestockService restockService) {
        this.restockService = restockService;
    }

    @GetMapping
    public List<RestockRequest> getAllRestocks() {
        return restockService.getAllRestocks();
    }

    @PostMapping
    public RestockRequest createRestock(@RequestBody RestockRequest request) {
        return restockService.createRestock(request);
    }

    @PatchMapping("/{id}/approve")
    public RestockRequest approveRestock(@PathVariable Long id) {
        return restockService.approveRestock(id);
    }

    @PatchMapping("/{id}/deliver")
    public RestockRequest deliverRestock(@PathVariable Long id) {
        return restockService.deliverRestock(id);
    }

    @ExceptionHandler(RestockProcessingException.class)
    public ResponseEntity<Map<String, String>> handleRestockException(RestockProcessingException exception) {
        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(Map.of("message", exception.getMessage()));
    }
}
