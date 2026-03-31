// Instana Backend Correlation interceptor
// This intercepts fetch calls to read trace ID from Server-Timing header

const originalFetch = window.fetch;

window.fetch = function(...args) {
  return originalFetch.apply(this, args)
    .then(response => {
      // Read the server-timing header which contains the trace ID
      const serverTiming = response.headers.get('Server-Timing');
      
      if (serverTiming && window.ineum) {
        // Extract trace ID from: intid;desc=1c8ce48cbc5b8673
        const match = serverTiming.match(/intid;desc=([a-f0-9]+)/);
        if (match && match[1]) {
          window.ineum('backendTraceId', match[1]);
        }
      }
      
      return response;
    });
};

export {};
