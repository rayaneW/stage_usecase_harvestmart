// Instana Backend Correlation interceptor
// Wait for Instana to be ready before intercepting fetch

function waitForInstana() {
  if (typeof window.ineum === 'undefined') {
    setTimeout(waitForInstana, 100);
    return;
  }

  const originalFetch = window.fetch;

  window.fetch = function(...args) {
    return originalFetch.apply(this, args)
      .then(response => {
        // Get the Instana trace ID from response header
        const instanaTraceId = response.headers.get('x-instana-t');
        
        if (instanaTraceId && window.ineum) {
          window.ineum('backendTraceId', instanaTraceId);
        }
        
        return response;
      });
  };
}

waitForInstana();

export {};
