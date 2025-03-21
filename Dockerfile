FROM node:16-slim AS build

SHELL ["/bin/bash", "-c"]
# Install system dependencies and clean up in the same layer
RUN apt-get update && apt-get install -y --no-install-recommends \
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

# Install Noir using noirup
RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash
ENV PATH="/root/.noirup/env:${PATH}"
RUN bash -c "source /root/.bashrc && noirup"

# Install BB using bbup
RUN curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/refs/heads/master/barretenberg/bbup/install | bash 
ENV PATH="/root/.bbup/env:${PATH}"
RUN bash -c "source /root/.bashrc && bbup"

# Create a smaller runtime image
FROM node:16-slim

SHELL ["/bin/bash", "-c"]
# Install only the runtime dependencies needed
RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    gzip \
    jq \
    ca-certificates \
    libc++1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy the tools from the build stage
COPY --from=build /root/.cargo /root/.cargo
COPY --from=build /root/.noirup /root/.noirup
COPY --from=build /root/.bbup /root/.bbup
ENV PATH="/root/.cargo/bin:/root/.noirup/env:/root/.bbup/env:${PATH}"

# Set working directory
WORKDIR /zk

# Copy package files first to leverage Docker cache
COPY api/package*.json ./api/

# Install Node.js dependencies for API
WORKDIR /zk/api
RUN npm ci --only=production && npm cache clean --force

# Copy the rest of the project files
WORKDIR /zk
COPY . .

# Create target directory if it doesn't exist
RUN mkdir -p target

# Make script executable
RUN chmod +x /zk/prouver_nombre.sh

# Test that commands are available to verify everything works
RUN bash -c 'source $HOME/.bashrc && which nargo || echo "nargo not found"'
RUN bash -c 'source $HOME/.bashrc && which bb || echo "bb not found"'

# Expose API port
EXPOSE 3000

WORKDIR /zk
CMD ["bash", "-c", "source /root/.bashrc && cd /zk && node api/server.js"] 