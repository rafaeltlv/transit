# Multi-stage Dockerfile to build both frontend and backend

# ================== FRONTEND BUILD STAGE ================== #
FROM node:20 AS svelte-builder

WORKDIR /svelte-app/ ./

# Copy package.json and package-lock.json first for efficient caching
COPY package.json .
RUN npm install

# Copy the rest of the frontend files
COPY . .

# Build the frontend
RUN npm run build

# ================== BACKEND BUILD STAGE ================== #
FROM rust:1.72.0 AS rust-builder

WORKDIR /backend

# Copy Rust files and build the Rust application
COPY . .
RUN cargo build --release

# ================== FINAL STAGE ================== #
FROM ubuntu:22.04

# Environment variables
ENV RUST_VERSION=1.72.0
ENV NODE_VERSION=20

# Update and install necessary dependencies
RUN apt update && apt upgrade -y && \
    apt install -y curl build-essential ca-certificates gnupg && \
    curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list && \
    apt-get update && \
    apt-get install -y nodejs && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Create a new user for our application
RUN useradd appuser

# Copy the frontend build
COPY --from=svelte-builder /frontend/public /app/public

# Copy the Rust binary
COPY --from=rust-builder /backend/target/release/transit /app/

# Switch to the app user
USER appuser

# Expose the port that our application will run on
EXPOSE 8080

# Health check to ensure our service is running
HEALTHCHECK CMD curl --fail http://localhost:8080/ || exit 1

# Command to run our application
CMD ["./transit"]
