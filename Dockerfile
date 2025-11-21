FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

# Install Python only (no development tools)
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3 python3-pip python3-venv ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Optional: set python3 as default "python"
RUN ln -s /usr/bin/python3 /usr/bin/python


# 1. Install necessary dependencies (wget, gnupg, software-properties-common) 
#    and update packages in a single 'RUN' layer.
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    wget \
    gnupg \
    software-properties-common \
    && rm -rf /var/lib/apt/lists/*

# --- Install Amazon Corretto 8 (Java 8) ---
# 2. Use the correct, modern way to add a GPG key: 'curl/wget | gpg --dearmor | tee'
#    'apt-key add' is deprecated.
#    Note: 'software-properties-common' (installed above) is needed for 'add-apt-repository'.
RUN wget -O- https://apt.corretto.aws/corretto.key | gpg --dearmor | tee /etc/apt/keyrings/corretto.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/corretto.gpg] https://apt.corretto.aws stable main" | tee /etc/apt/sources.list.d/corretto.list && \
    apt-get update

# 3. Install Google Chrome (required for Anvil's PDF/image generation) and Java.
#    Run 'apt-get update' again to ensure the Corretto package list is fresh.
#    Use --no-install-recommends to keep the image size down.
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ./google-chrome-stable_current_amd64.deb \
    java-1.8.0-amazon-corretto-jdk \
    ghostscript \
    && rm google-chrome-stable_current_amd64.deb \
    && rm -rf /var/lib/apt/lists/*

RUN pip install anvil-app-server


# Create directory where Anvil stores the JAR file
RUN mkdir -p /home/anvil/.anvil && \
    chown -R anvil:anvil /home/anvil


# 5. Set up Anvil user and data directories
RUN mkdir ./anvil-data && \
    useradd --no-create-home --shell /bin/false anvil && \
    chown -R anvil:anvil ./anvil-data

# Set environment variables for better logging/operation
ENV ANVIL_DATA_DIR="./anvil-data"
ENV ANVIL_PORT="443"

VOLUME /apps ./anvil-data
WORKDIR /

# 6. Switch to the non-root user
USER anvil

EXPOSE 443

# 7. Use the correct ENTRYPOINT and CMD format.
#    CMD is used for arguments to the ENTRYPOINT.
ENTRYPOINT ["anvil-app-server"]
CMD ["--data-dir", "/anvil-data", "--port", "443", "--origin", "https://[your_domain]", "--letsencrypt-staging", "--app", "."]
