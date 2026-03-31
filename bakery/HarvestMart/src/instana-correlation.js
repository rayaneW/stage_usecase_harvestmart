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
        const serverTiming = response.headers.get('Server-Timing');
        
        if (serverTiming && window.ineum) {
          const match = serverTiming.match(/intid;desc=([a-f0-9]+)/);
          if (match && match[1]) {
            window.ineum('backendTraceId', match[1]);
          }
        }
        
        return response;
      });
  };
}

waitForInstana();

export {};
