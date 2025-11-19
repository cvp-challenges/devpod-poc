# Start from a base image that has common tools and the devcontainer user setup
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Install Node.js (using a Feature for simplicity and cleanliness)
# The 'base' image already includes apt-get, git, etc.
# We will install Node/Java using features in devcontainer.json

# If you need specific manual installs, add them here.
# Example for manual Node.js installation (generally better to use features)
# RUN apt-get update && apt-get install -y nodejs npm

# The devcontainer specification handles the installation of runtimes via 'features'
# so this Dockerfile can remain minimal.

COPY ./scripts/workspace-startup.sh /usr/local/bin/startup.sh

# RUN chmod +x /usr/local/bin/startup.sh

# ENTRYPOINT ["/workspace/.devcontainer/scripts/workspace-startup.sh"]
ENTRYPOINT [ "tail -f /dev/null" ]
