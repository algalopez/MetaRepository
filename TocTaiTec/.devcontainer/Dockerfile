FROM debian:bullseye-slim

# Install required dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Install Elm directly
RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz \
    && gunzip elm.gz \
    && chmod +x elm \
    && mv elm /usr/local/bin/

# Set up workspace directory
WORKDIR /workspace

# Create a non-root user
RUN useradd -ms /bin/bash vscode
USER vscode

# Set default shell to bash
ENV SHELL=/bin/bash