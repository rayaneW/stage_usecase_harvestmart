package be.freshmart.bakery_backend.service;

import be.freshmart.bakery_backend.exception.RestockProcessingException;
import be.freshmart.bakery_backend.model.Product;
import be.freshmart.bakery_backend.model.RestockRequest;
import be.freshmart.bakery_backend.model.RestockStatus;
import be.freshmart.bakery_backend.repository.ProductRepository;
import be.freshmart.bakery_backend.repository.RestockRequestRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class RestockService {

    private final RestockRequestRepository restockRepository;
    private final ProductRepository productRepository;

    public RestockService(RestockRequestRepository restockRepository, ProductRepository productRepository) {
        this.restockRepository = restockRepository;
        this.productRepository = productRepository;
    }

    public List<RestockRequest> getAllRestocks() {
        return restockRepository.findAll();
    }

    @Transactional
    public RestockRequest createRestock(RestockRequest request) {
        if (request.getProductId() == null) {
            throw new RestockProcessingException("productId is verplicht.");
        }

        if (request.getRequestedQuantity() == null || request.getRequestedQuantity() <= 0) {
            throw new RestockProcessingException("requestedQuantity moet groter zijn dan 0.");
        }

        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new RestockProcessingException(
                        "Product niet gevonden met id " + request.getProductId()
                ));

        RestockRequest newRequest = new RestockRequest();
        newRequest.setProductId(product.getId());
        newRequest.setProductName(product.getName());
        newRequest.setRequestedQuantity(request.getRequestedQuantity());
        newRequest.setStatus(RestockStatus.PENDING);

        return restockRepository.save(newRequest);
    }

    @Transactional
    public RestockRequest approveRestock(Long restockId) {
        RestockRequest request = findRestockById(restockId);

        if (request.getStatus() == RestockStatus.DELIVERED) {
            throw new RestockProcessingException("Geleverde restock requests kunnen niet meer goedgekeurd worden.");
        }

        request.setStatus(RestockStatus.APPROVED);
        return restockRepository.save(request);
    }

    @Transactional
    public RestockRequest deliverRestock(Long restockId) {
        RestockRequest request = findRestockById(restockId);

        if (request.getStatus() == RestockStatus.DELIVERED) {
            throw new RestockProcessingException("Deze restock request is al geleverd.");
        }

        if (request.getStatus() != RestockStatus.APPROVED) {
            throw new RestockProcessingException("Restock request moet eerst APPROVED zijn voor levering.");
        }

        Product product = productRepository.findById(request.getProductId())
                .orElseThrow(() -> new RestockProcessingException(
                        "Product niet gevonden met id " + request.getProductId()
                ));

        int currentStock = product.getStock() == null ? 0 : product.getStock();
        product.setStock(currentStock + request.getRequestedQuantity());
        productRepository.save(product);

        request.setStatus(RestockStatus.DELIVERED);
        return restockRepository.save(request);
    }

    private RestockRequest findRestockById(Long id) {
        return restockRepository.findById(id)
                .orElseThrow(() -> new RestockProcessingException(
                        "Restock request niet gevonden met id " + id
                ));
    }
}
