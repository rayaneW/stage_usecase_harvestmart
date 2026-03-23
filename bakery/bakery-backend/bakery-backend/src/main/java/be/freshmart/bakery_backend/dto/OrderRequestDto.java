package be.freshmart.bakery_backend.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class OrderRequestDto {
    private String customerName;
    private String branch;
    private LocalDate requestedDate;
    private List<OrderItemRequestDto> items;
    private BigDecimal totalPrice;
}
