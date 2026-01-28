FROM debian:bookworm

# Install utils
RUN apt-get update && apt-get install -y \
    nginx \
    openssl \
    openssh-client \
    ca-certificates \
    dpkg-dev \
    apt-utils \
    gnupg \
    curl \
    vim \
    && rm -rf /var/lib/apt/lists/*

# Create directory for the repo
RUN mkdir -p /var/www/html/etnz/reserve/releases/download/repo

# SPOOFING STRATEGY EXPLANATION
# This container spoofs 'github.com' to serve local files instead of the real GitHub.
#
# 1. DNS Spoofing: The entrypoint script modifies /etc/hosts to point github.com to 127.0.0.1.
# 2. SSL Trust: We generate a custom Certificate Authority (CA) and explicitly add it to the 
#    OS trust store (/usr/local/share/ca-certificates/).
# 3. Certificate Issuance: We issue a certificate for 'github.com' signed by this trusted CA 
#    and configure Nginx to use it.
#
# Why this is NOT a "Man-in-the-Middle" (MITM) attack:
# A MITM attack implies intercepting traffic between two parties without their knowledge or consent,
# usually relying on lack of validation or compromised routing. Here, we are the administrator of 
# the system (the container). We are explicitly configuring the OS to trust our custom CA. 
# This is a standard "Private PKI" setup, similar to how corporate environments inspect traffic 
# or how development environments use self-signed certs. The OS validation mechanisms (OpenSSL, 
# ca-certificates) are working exactly as designed, verifying a chain of trust that we intentionally 
# established. It is robust and does not rely on security vulnerabilities or backdoors.

# SSL Setup for github.com spoofing (Inlined)
RUN mkdir -p /etc/nginx/ssl
RUN openssl genrsa -out /etc/nginx/ssl/ca.key 2048 && \
    openssl req -x509 -new -nodes -key /etc/nginx/ssl/ca.key -sha256 -days 3650 -out /etc/nginx/ssl/ca.crt -subj "/CN=MyLabCA" && \
    cp /etc/nginx/ssl/ca.crt /usr/local/share/ca-certificates/mylabca.crt && \
    update-ca-certificates && \
    echo "subjectAltName=DNS:github.com" > /etc/nginx/ssl/extfile.cnf && \
    openssl genrsa -out /etc/nginx/ssl/github.key 2048 && \
    openssl req -new -key /etc/nginx/ssl/github.key -out /etc/nginx/ssl/github.csr -subj "/CN=github.com" && \
    openssl x509 -req -in /etc/nginx/ssl/github.csr -CA /etc/nginx/ssl/ca.crt -CAkey /etc/nginx/ssl/ca.key -CAcreateserial -out /etc/nginx/ssl/github.crt -days 3650 -sha256 -extfile /etc/nginx/ssl/extfile.cnf

# Nginx Config (Inlined)
RUN echo 'server {' > /etc/nginx/sites-available/default && \
    echo '    listen 443 ssl;' >> /etc/nginx/sites-available/default && \
    echo '    server_name github.com;' >> /etc/nginx/sites-available/default && \
    echo '' >> /etc/nginx/sites-available/default && \
    echo '    ssl_certificate /etc/nginx/ssl/github.crt;' >> /etc/nginx/sites-available/default && \
    echo '    ssl_certificate_key /etc/nginx/ssl/github.key;' >> /etc/nginx/sites-available/default && \
    echo '' >> /etc/nginx/sites-available/default && \
    echo '    root /var/www/html;' >> /etc/nginx/sites-available/default && \
    echo '    autoindex on;' >> /etc/nginx/sites-available/default && \
    echo '' >> /etc/nginx/sites-available/default && \
    echo '    location / {' >> /etc/nginx/sites-available/default && \
    echo '        try_files $uri $uri/ =404;' >> /etc/nginx/sites-available/default && \
    echo '    }' >> /etc/nginx/sites-available/default && \
    echo '}' >> /etc/nginx/sites-available/default

# Entrypoint to handle /etc/hosts hack (Inlined)
RUN echo '#!/bin/bash' > /entrypoint.sh && \
    echo '# Add github.com to hosts pointing to localhost' >> /entrypoint.sh && \
    echo 'echo "127.0.0.1 github.com" >> /etc/hosts' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo '# Start Nginx' >> /entrypoint.sh && \
    echo 'service nginx start' >> /entrypoint.sh && \
    echo '' >> /entrypoint.sh && \
    echo 'exec "$@"' >> /entrypoint.sh && \
    chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
CMD ["bash"]