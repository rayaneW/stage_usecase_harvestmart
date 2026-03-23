package be.freshmart.bakery_backend.service;

import be.freshmart.bakery_backend.dto.OrderItemRequestDto;
import be.freshmart.bakery_backend.dto.OrderItemResponseDto;
import be.freshmart.bakery_backend.dto.OrderRequestDto;
import be.freshmart.bakery_backend.dto.OrderResponseDto;
import be.freshmart.bakery_backend.exception.OrderProcessingException;
import be.freshmart.bakery_backend.model.Order;
import be.freshmart.bakery_backend.model.OrderItem;
import be.freshmart.bakery_backend.model.Product;
import be.freshmart.bakery_backend.repository.OrderRepository;
import be.freshmart.bakery_backend.repository.ProductRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class OrderService {
    private final OrderRepository repository;
    private final ProductRepository productRepository;

    public OrderService(OrderRepository repository, ProductRepository productRepository) {
        this.repository = repository;
        this.productRepository = productRepository;
    }

    @Transactional
    public OrderResponseDto createOrder(OrderRequestDto orderRequest){
        Order order = new Order();
        order.setCustomerName(orderRequest.getCustomerName());
        order.setBranch(orderRequest.getBranch());
        order.setRequestedDate(orderRequest.getRequestedDate());
        order.setTotalPrice(orderRequest.getTotalPrice());

        List<OrderItem> orderItems = new ArrayList<>();

        if (orderRequest.getItems() != null) {
            for (OrderItemRequestDto itemRequest : orderRequest.getItems()) {
        if (itemRequest.getQuantity() == null || itemRequest.getQuantity() <= 0) {
            throw new OrderProcessingException("Ongeldige hoeveelheid voor productId " + itemRequest.getProductId());
        }

        Product product = productRepository.findById(itemRequest.getProductId())
            .orElseThrow(() -> new OrderProcessingException(
                "Product niet gevonden met id " + itemRequest.getProductId()
            ));

        int currentStock = product.getStock() == null ? 0 : product.getStock();
        int requestedQuantity = itemRequest.getQuantity();

        if (currentStock < requestedQuantity) {
            throw new OrderProcessingException(
                "Onvoldoende stock voor product '" + product.getName() + "'. Beschikbaar: "
                    + currentStock + ", gevraagd: " + requestedQuantity
            );
        }

        product.setStock(currentStock - requestedQuantity);
        productRepository.save(product);

                OrderItem item = new OrderItem();
                item.setProductId(itemRequest.getProductId());
                item.setProductName(itemRequest.getProductName());
                item.setQuantity(itemRequest.getQuantity());
                item.setPrice(itemRequest.getPrice());
                item.setOrder(order);
                orderItems.add(item);
            }
        }

        order.setItems(orderItems);

        Order savedOrder = repository.save(order);
        return toResponseDto(savedOrder);
    }

    public List<OrderResponseDto> getOrders(){
        return repository.findAll()
                .stream()
                .map(this::toResponseDto)
                .collect(Collectors.toList());
    }

    private OrderResponseDto toResponseDto(Order order) {
        List<OrderItemResponseDto> itemResponses = order.getItems()
                .stream()
                .map(item -> new OrderItemResponseDto(
                        item.getId(),
                        item.getProductId(),
                        item.getProductName(),
                        item.getQuantity(),
                        item.getPrice()
                ))
                .collect(Collectors.toList());

        return new OrderResponseDto(
                order.getId(),
                order.getCustomerName(),
                order.getBranch(),
                order.getRequestedDate(),
                order.getTotalPrice(),
                order.getCreatedAt(),
                itemResponses
        );
    }
}
