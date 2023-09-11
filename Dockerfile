# Use Ubuntu 22.04 as the base image
FROM ubuntu:22.04 AS base

# Update and install necessary dependencies
RUN apt update && apt upgrade -y

# Install curl (useful for installing Rust and Node.js)
RUN apt install -y curl build-essential

# Install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Node.js for Svelte
RUN curl -sL https://deb.nodesource.com/setup_16.x | bash -
RUN apt install -y nodejs

# Build the Svelte frontend
FROM base AS svelte-builder
WORKDIR /app/svelte-app
COPY svelte-app/package.json ./
RUN npm install
COPY svelte-app/ ./
RUN npm run build

# Build the Rust backend
FROM base AS rust-builder
WORKDIR /app
COPY . .
COPY --from=svelte-builder /app/svelte-app/public /app/public
RUN cargo build --release

# Final image with Nginx (if you need it)
FROM base
WORKDIR /app
COPY --from=rust-builder /app/target/release/transit /app/
COPY --from=svelte-builder /app/svelte-app/public /app/public

# If you need Nginx and PHP, add their setup here as described in the tutorial

EXPOSE 8080
CMD ["./transit"]  # Change this to the name of your Rust binary
