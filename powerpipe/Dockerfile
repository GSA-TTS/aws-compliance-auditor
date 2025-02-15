FROM debian:bullseye-slim

# Install prerequisites
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    git \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN useradd -m -s /bin/bash powerpipe && \
    mkdir -p /workspace && \
    chown -R powerpipe:powerpipe /workspace

# Switch to non-root user
USER powerpipe
WORKDIR /home/powerpipe

# Copy and execute installation scripts
COPY --chown=powerpipe:powerpipe scripts/install_*.sh /tmp/
RUN chmod +x /tmp/install_*.sh && \
    /tmp/install_steampipe.sh && \
    /tmp/install_powerpipe.sh && \
    rm /tmp/install_*.sh

# Setup workspace and AWS plugin
WORKDIR /workspace
RUN mkdir -p ~/.steampipe/config && \
    ~/.local/bin/steampipe plugin install aws --progress=false && \
    ~/.local/bin/steampipe mod install github.com/turbot/steampipe-mod-aws-compliance --progress=false

# Copy AWS connection config
COPY --chown=powerpipe:powerpipe aws.spc ~/.steampipe/config/aws.spc

EXPOSE 9193 9033

# Start services with full paths
CMD ["sh", "-c", "~/.local/bin/steampipe service start && ~/.local/bin/powerpipe server --host 0.0.0.0 --port 9033"]