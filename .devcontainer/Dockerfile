# Start from a base image that has common tools and the devcontainer user setup
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

RUN rm -rf /var/lib/apt/lists/* && \
    sed -i 's|archive.ubuntu.com|mirrors.edge.kernel.org|' /etc/apt/sources.list && \
    apt-get clean && apt-get update -y --allow-releaseinfo-change && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates curl gnupg lsb-release wget postgresql-client vim less nano

RUN mkdir -p /home/vscode/scripts /home/vscode/projects /home/vscode/.cache && \
    chown -R vscode:vscode /home/vscode/scripts /home/vscode/projects /home/vscode/.cache

RUN mkdir -p /workspace

RUN groupadd -f docker && usermod -aG docker vscode

WORKDIR /workspace
USER vscode

COPY ./scripts /home/vscode/scripts
RUN chmod +x /home/vscode/scripts/*.sh