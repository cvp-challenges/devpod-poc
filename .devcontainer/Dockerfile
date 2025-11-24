# Start from a base image that has common tools and the devcontainer user setup
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install basics
RUN apt-get update && \
    apt-get install -y \
      curl wget postgresql-client \
      vim less nano \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /home/vscode/.cache/yarn /home/vscode/.cache/Cypress && \
    chown -R vscode:vscode /home/vscode/.cache

USER vscode

WORKDIR /workspace
