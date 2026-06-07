# ── Stage 1: Build Vue app ────────────────────────────────────────
FROM registry.access.redhat.com/ubi9/nodejs-20 AS build
WORKDIR /app

# Install dependencies and build the Vue app
COPY package*.json ./
# Switch to root in case the base image runs as non-root so we can write node_modules
USER 0
RUN mkdir -p /app/node_modules && npm ci --no-audit --no-fund && chown -R 1001:0 /app

USER 1001

COPY . .
RUN npm run build

# ── Stage 2: Serve with nginx installed on UBI minimal ───────────
FROM registry.access.redhat.com/ubi9/ubi-minimal AS runtime

ENV BACKEND_UPSTREAM=http://bakery-backend-service:8080

# Install nginx
RUN microdnf install -y nginx && microdnf clean all

# Copy nginx config and built assets
# Use nginx default include path so config does not need a full nginx.conf file
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist /usr/share/nginx/html

# OpenShift compatibility: ensure writable dirs and run as non-root user
RUN mkdir -p /var/log/nginx /var/cache/nginx/client_temp /var/run /usr/share/nginx/html && \
    chmod -R 0777 /var/log/nginx /var/cache/nginx /var/run /etc/nginx /usr/share/nginx/html

EXPOSE 8080

USER 1001

CMD ["nginx", "-g", "daemon off;"]
