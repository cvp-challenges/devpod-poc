# Start from a base image that has common tools and the devcontainer user setup
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Use safer APT settings and retry mirrors
RUN rm -rf /var/lib/apt/lists/* && \
    sed -i 's|archive.ubuntu.com|mirrors.edge.kernel.org|' /etc/apt/sources.list && \
    apt-get clean && apt-get update -y --allow-releaseinfo-change && \
    apt-get upgrade -y && \
    apt-get install -y ca-certificates curl gnupg lsb-release wget postgresql-client vim less nano

RUN mkdir -p /home/vscode/.cache/yarn /home/vscode/.cache/Cypress && \
    chown -R vscode:vscode /home/vscode/.cache

RUN mkdir -p /workspace && chown vscode:vscode /workspace

USER vscode

WORKDIR /workspace
