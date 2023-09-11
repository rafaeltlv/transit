# Use a specific version of the Rust image as a base
FROM rust:1.72

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy the current directory contents into the container
COPY . .

# Build the Rust application
RUN cargo build --release

# Set the command to run your application (replace with your actual application command)
CMD ["./target/release/transit"]