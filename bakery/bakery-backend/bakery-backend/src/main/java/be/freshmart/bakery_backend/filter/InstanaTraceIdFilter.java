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

        // Try getting trace ID from different sources
        String traceId = request.getHeader("X-INSTANA-T");
        
        if (traceId == null) {
            Object traceIdObj = request.getAttribute("X-INSTANA-T");
            if (traceIdObj != null) {
                traceId = traceIdObj.toString();
            }
        }
        
        if (traceId != null) {
            // Add it to the response header so the frontend JavaScript can read it
            response.setHeader("X-Instana-Trace-Id", traceId);
        }

        filterChain.doFilter(request, response);
    }
}
