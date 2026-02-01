# ==============================================================================
# Multi-stage Dockerfile for Flutter Web Application
# ==============================================================================
# Stage 1: Build Flutter web release
# Stage 2: Serve with nginx
# ==============================================================================

# ==============================================================================
# STAGE 1: Build Flutter Web
# ==============================================================================
FROM ghcr.io/cirruslabs/flutter:3.24.0 AS build

WORKDIR /app

# Copy dependency files first for better caching
COPY pubspec.yaml pubspec.lock* ./

# Get Flutter dependencies
RUN flutter pub get

# Copy the rest of the source code
COPY . .

# Build arguments for environment configuration
# These can be passed at build time: docker build --build-arg API_BASE_URL=...
ARG API_BASE_URL=http://localhost:3000/api
ARG ENV=production
ARG ENABLE_ANALYTICS=true
ARG ENABLE_CRASH_REPORTING=true
ARG ENABLE_VERBOSE_LOGGING=false

# Create .env file from build arguments
# This allows environment-specific builds without modifying source
RUN echo "API_BASE_URL=$API_BASE_URL" > .env && \
    echo "ENV=$ENV" >> .env && \
    echo "ENABLE_ANALYTICS=$ENABLE_ANALYTICS" >> .env && \
    echo "ENABLE_CRASH_REPORTING=$ENABLE_CRASH_REPORTING" >> .env && \
    echo "ENABLE_VERBOSE_LOGGING=$ENABLE_VERBOSE_LOGGING" >> .env

# Build Flutter web release
# --release: Production optimized build
# --base-href "/": Serve from root path
RUN flutter build web --release --base-href "/"

# ==============================================================================
# STAGE 2: Serve with Nginx
# ==============================================================================
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy built Flutter web files from build stage
COPY --from=build /app/build/web /usr/share/nginx/html

# Health check to verify nginx is responding
# Used by container orchestration (Docker Compose, Kubernetes, etc.)
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:80/ || exit 1

# Expose port 80 for HTTP traffic
EXPOSE 80

# Start nginx in foreground mode
CMD ["nginx", "-g", "daemon off;"]
