package be.freshmart.bakery_backend.exception;

public class RestockProcessingException extends RuntimeException {
    public RestockProcessingException(String message) {
        super(message);
    }
}
