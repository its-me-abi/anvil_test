FROM python:3.10-slim

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential openjdk-8-jdk \
    && rm -rf /var/lib/apt/lists/*

# Install Anvil App Server
RUN pip install anvil-app-server

# Copy your Anvil app
WORKDIR /app
COPY . /app

EXPOSE 3030

CMD ["anvil-app-server", "--app", ".", "--port", "3030", "--origin", "*"]
