# Stage 1: Build Flutter web app
FROM ghcr.io/cirruslabs/flutter:stable AS builder

WORKDIR /app

# Copy dependency files first for better caching
COPY pubspec.* ./
RUN flutter pub get

# Copy all source files
COPY . .

# Build Flutter web release
RUN flutter build web --release

# Stage 2: Serve with nginx (alpine for small image size)
FROM nginx:alpine

# Copy built web assets from builder stage
COPY --from=builder /app/build/web /usr/share/nginx/html

# Copy custom nginx configuration for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Expose port 80 for HTTP traffic
EXPOSE 80

# Run nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
