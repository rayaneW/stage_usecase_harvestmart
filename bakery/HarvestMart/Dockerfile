# ── Stage 1: Build Vue app ────────────────────────────────────────
FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ── Stage 2: Serve with Nginx ─────────────────────────────────────
FROM nginx:1.27

# Replace default nginx config with ours (includes /api proxy + Vue Router fallback)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Vue app
COPY --from=build /app/dist /usr/share/nginx/html

# OpenShift compatibility: remove root user requirement and fix permissions
RUN mkdir -p /var/cache/nginx/client_temp && \
    chmod -R 777 /var/cache/nginx && \
    chmod -R 777 /var/run && \
    chmod -R 777 /etc/nginx && \
    chmod -R 777 /usr/share/nginx/html && \
    sed -i 's/^user nginx;/# user nginx;/' /etc/nginx/nginx.conf

EXPOSE 80

USER 1001
