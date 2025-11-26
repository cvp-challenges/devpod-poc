# Base devcontainer image
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Update packages and install tools
RUN rm -rf /var/lib/apt/lists/* && \
    sed -i 's|archive.ubuntu.com|mirrors.edge.kernel.org|' /etc/apt/sources.list && \
    apt-get clean && apt-get update -y --allow-releaseinfo-change && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates curl gnupg lsb-release wget git postgresql-client vim less nano

# Create writable directories for DevPod AWS
RUN mkdir -p /home/vscode/projects /home/vscode/.cache && \
    chown -R vscode:vscode /home/vscode/projects /home/vscode/.cache

# Create /workspace mount point (read-only)
RUN mkdir -p /workspace

# Add vscode to docker group
RUN groupadd -f docker && usermod -aG docker vscode

# Set working directory and user
WORKDIR /workspace
USER vscode
