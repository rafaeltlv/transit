#Dockerfile
# Use the official Rust image as a base
FROM rust:latest

# Set the working directory inside the container
WORKDIR /Users/Apikorus/transit/svelte-app/src/App

# Copy the current directory contents into the container
COPY . .

# Build the Rust application
RUN cargo build --release

# Set the command to run your application
CMD curl http://localhost:8080

