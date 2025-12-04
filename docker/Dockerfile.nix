# Nix-based Dockerfile for terminal environment
# This uses Nix to provide reproducible builds

FROM nixos/nix:latest

# Enable flakes
RUN echo "experimental-features = nix-command flakes" >> /etc/nix/nix.conf

# Set working directory
WORKDIR /workspace

# Copy flake files
COPY flake.nix flake.lock ./
COPY home.nix ./

# Build the environment
RUN nix build .#docker --no-link

# Set environment variables
ENV TERM=xterm-256color
ENV LANGUAGE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV USERNAME=gfoster
ENV TTYPORT=8080

# Expose ttyd port
EXPOSE 8080

# Default command
CMD ["nix", "run", ".#docker"]