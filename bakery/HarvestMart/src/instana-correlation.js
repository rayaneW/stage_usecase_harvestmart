// Instana Backend Correlation interceptor
// This intercepts fetch calls to read trace ID from response headers

const originalFetch = window.fetch;

window.fetch = function(...args) {
  return originalFetch.apply(this, args)
    .then(response => {
      // Read the trace ID header from the response
      const traceId = response.headers.get('X-Instana-Trace-Id');
      
      if (traceId && window.ineum) {
        // Set the backend trace ID for this request
        window.ineum('backendTraceId', traceId);
      }
      
      return response;
    });
};

export {};
