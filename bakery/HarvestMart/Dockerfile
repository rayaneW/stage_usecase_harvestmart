# ── Stage 1: Build Vue app ────────────────────────────────────────
FROM node:20-alpine AS build
WORKDIR /app

COPY package*.json ./
RUN npm ci

COPY . .
RUN npm run build

# ── Stage 2: Serve with Nginx ─────────────────────────────────────
FROM nginx:1.27-alpine

# Replace default nginx config with ours (includes /api proxy + Vue Router fallback)
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built Vue app
COPY --from=build /app/dist /usr/share/nginx/html

EXPOSE 80
