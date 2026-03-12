# ── Efectech Website – Docker image ──────────────────────────────
# Stage 1: serve static files with Nginx (Alpine, ~25 MB total)
FROM nginx:1.27-alpine

# Run nginx workers as root (needed for UGREEN NAS bind mount permissions)
RUN sed -i 's/user\s*nginx;/user  root;/' /etc/nginx/nginx.conf

# Remove default Nginx page
RUN rm -rf /usr/share/nginx/html/*

# Copy website
COPY index.html /usr/share/nginx/html/index.html

# Copy custom Nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose HTTP (Cloudflare proxy handles HTTPS)
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD wget -qO- http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
