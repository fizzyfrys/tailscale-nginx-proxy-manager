# Base ningx-proxy-manager image
FROM jc21/nginx-proxy-manager:latest

# Install dependencies for Tailscale and ping cus useful
RUN apt-get update && \
    apt-get install -y curl gnupg2 apt-transport-https iproute2 iputils-ping

# Create directory for tailscale
RUN mkdir -p /var/lib/tailscale

# Install Tailscale using the official install script
RUN curl -fsSL https://tailscale.com/install.sh | sh

# Create directory for s6-overlay service
RUN mkdir -p /etc/services.d/tailscaled

# Create the run script for the tailscaled service using printf
RUN printf '#!/bin/bash\n tailscaled --port 41741 --state=/var/lib/tailscale/tailscaled.state --socket=/run/tailscale/tailscaled.sock\n' > /etc/services.d/tailscaled/run

# Make the run script executable
RUN chmod +x /etc/services.d/tailscaled/run

# Expose ports
EXPOSE 80 81 443 41741
