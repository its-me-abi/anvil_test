FROM debian:bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

# --------------------------
# Install dependencies
# --------------------------
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip python3-venv \
    wget gnupg ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN ln -s /usr/bin/python3 /usr/bin/python

# --------------------------
# Install Amazon Corretto 8
# --------------------------
RUN wget -O- https://apt.corretto.aws/corretto.key \
    | gpg --dearmor \
    | tee /etc/apt/keyrings/corretto.gpg > /dev/null && \
    echo "deb [signed-by=/etc/apt/keyrings/corretto.gpg] https://apt.corretto.aws stable main" \
    | tee /etc/apt/sources.list.d/corretto.list && \
    apt-get update

# --------------------------
# Install Chrome (Render requires no-sandbox)
# --------------------------
RUN wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && \
    apt-get install -y --no-install-recommends \
    ./google-chrome-stable_current_amd64.deb \
    java-1.8.0-amazon-corretto-jdk \
    ghostscript && \
    rm google-chrome-stable_current_amd64.deb && \
    rm -rf /var/lib/apt/lists/*

# --------------------------
# Install Anvil App Server
# --------------------------
RUN pip3 install --break-system-packages anvil-app-server

# --------------------------
# Create anvil user + dirs
# --------------------------
RUN useradd -m anvil && \
    mkdir -p /home/anvil/.anvil /anvil-data && \
    chown -R anvil:anvil /home/anvil /anvil-data

# --------------------------
# Copy your Anvil app
# --------------------------
WORKDIR /home/anvil/app
COPY . /home/anvil/app
RUN chown -R anvil:anvil /home/anvil/app

# --------------------------
# Switch to non-root user
# --------------------------
USER anvil

# --------------------------
# Disable Chrome sandbox for Render
# --------------------------
ENV CHROME_ARGS="--no-sandbox --disable-dev-shm-usage"
ENV ANVIL_PORT=443

EXPOSE 443

# --------------------------
# ENTRYPOINT (correct)
# --------------------------
ENTRYPOINT ["anvil-app-server"]

CMD ["--origin", "*", "--app", "/home/anvil/app"]
