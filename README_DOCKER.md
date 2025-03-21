# ZK Proof Service - Docker Setup

This document explains how to run the ZK Proof service using Docker.

## Prerequisites

- Docker
- Docker Compose

## Running the Service

1. Build and start the service:

```bash
docker build -t zk-proof-service .
docker run -d -p 3000:3000 -v $(pwd)/target:/zk/target --name zk-proof-service zk-proof-service
```

Or using docker-compose:

```bash
docker-compose up -d
```

2. The API will be available at http://localhost:3000

3. To generate a ZK proof, use:

```bash
curl http://localhost:3000/generate/42
```

Replace `42` with your chosen number.

## Stopping the Service

```bash
docker stop zk-proof-service
docker rm zk-proof-service
```

Or using docker-compose:

```bash
docker-compose down
```

## Volume Mounts

The `target` directory is mounted as a volume, so proof files will persist between container restarts.

## Technical Details

### Tool Installation

The Dockerfile uses the official noirup and bbup installers with proper .bashrc sourcing:

```dockerfile
# Install Noir using noirup and BB using bbup (proper sourcing of .bashrc)
RUN curl -L https://raw.githubusercontent.com/noir-lang/noirup/refs/heads/main/install | bash && \
    echo 'source $HOME/.bashrc' > /root/source_env.sh && \
    bash -c 'source $HOME/.bashrc && noirup' && \
    \
    curl -L https://raw.githubusercontent.com/AztecProtocol/aztec-packages/refs/heads/master/barretenberg/bbup/install | bash && \
    bash -c 'source $HOME/.bashrc && bbup'
```

The key is ensuring that `.bashrc` is properly sourced after the installation to make the commands available.

### Command Execution

Commands are executed with .bashrc sourcing to ensure the PATH includes the installed tools:

```dockerfile
# Test that commands are available
RUN bash -c 'source $HOME/.bashrc && which nargo || echo "nargo not found"'
RUN bash -c 'source $HOME/.bashrc && which bb || echo "bb not found"'

# Command to start the API server
CMD ["bash", "-c", "source /root/.bashrc && node /zk/api/server.js"]
```

### Logs

To view logs:

```bash
docker logs -f zk-proof-service
```

Or with docker-compose:

```bash
docker-compose logs -f
```

## Notes

- The first build might take significant time as it downloads and installs the tools.
- Make sure ports are not in use by other applications.
- The container has all dependencies (nargo, bb) properly installed via the official installation tools.

## API Documentation

See the [API README](api/README.md) for API usage details. 