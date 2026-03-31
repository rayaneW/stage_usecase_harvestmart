package be.freshmart.bakery_backend.filter;

import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@Component
public class InstanaTraceIdFilter extends OncePerRequestFilter {

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        // Get the Instana trace ID from request header/attribute
        String traceId = request.getHeader("X-INSTANA-T");
        
        if (traceId == null) {
            Object traceIdObj = request.getAttribute("X-INSTANA-T");
            if (traceIdObj != null) {
                traceId = traceIdObj.toString();
            }
        }
        
        // Add it to response header for frontend JavaScript
        if (traceId != null) {
            response.setHeader("X-Instana-Trace-Id", traceId);
        }

        filterChain.doFilter(request, response);
    }
}
