FROM node:16-slim

SHELL ["/bin/bash", "-c"]
# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    build-essential \
    ca-certificates \
    gnupg \
    jq \
    bash \
    gzip \
    wget \
    libssl-dev \
    pkg-config \
    libc++1

# Install Rust (required for nargo)
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH="/root/.cargo/bin:${PATH}"

# Install Noir using noirup and BB using bbup (proper sourcing of .bashrc)
RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash && ls -lah /root
ENV PATH="/root/.noirup/env:${PATH}"
RUN bash -c "source /root/.bashrc && noirup"

# Install BB using bbup
RUN curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/refs/heads/master/barretenberg/bbup/install | bash 
ENV PATH="/root/.bbup/env:${PATH}"
RUN bash -c "source /root/.bashrc && bbup"

# Make sure the PATH includes the tools
ENV PATH="/root/.noirup/env:/root/.bbup/env:${PATH}"

# Set working directory
WORKDIR /zk

# Copy all project files
COPY . .

# Install Node.js dependencies for API
WORKDIR /zk/api
RUN npm install

# Create target directory if it doesn't exist
WORKDIR /zk
RUN mkdir -p target

# Make script executable
RUN chmod +x /zk/prouver_nombre.sh

# Test that commands are available
RUN bash -c 'source $HOME/.bashrc && which nargo || echo "nargo not found"'
RUN bash -c 'source $HOME/.bashrc && which bb || echo "bb not found"'

# Expose API port
EXPOSE 3000

WORKDIR /zk
CMD ["bash", "-c", "source /root/.bashrc && cd /zk && node api/server.js"] 