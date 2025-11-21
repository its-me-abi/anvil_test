FROM python:3.10-slim

# Fix missing repo metadata and install Java
RUN sed -i 's|deb.debian.org|deb.debian.org|g' /etc/apt/sources.list && \
    apt-get update && apt-get install -y \
        build-essential \
        default-jre-headless \
    && rm -rf /var/lib/apt/lists/*

# Install Anvil App Server
RUN pip install anvil-app-server

WORKDIR /app
COPY . /app

EXPOSE 3030

CMD ["anvil-app-server", "--app", ".", "--port", "3030", "--origin", "*"]
