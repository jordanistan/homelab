<<<<<<< HEAD
# Tailscale Docker Setup

This repository contains a Dockerfile and an entrypoint script to set up a Docker container with Tailscale, allowing you to connect your host machine's traffic to the Tailscale network and route it through the exit node.

## Prerequisites

Before proceeding, ensure that you have the following prerequisites installed on your host machine:

- Docker

## Getting Started

Follow these steps to set up and run the Tailscale Docker container:

1. Clone this repository to your local machine:

   ```bash
   git clone https://github.com/your-username/tailscale-docker.git
=======
# Tailscale Docker Container README

This guide helps you create a Docker container to ensure Tailscale node registration using an authentication key. To do this, you'll need to modify the Dockerfile and the entrypoint script. 

## Dockerfile Setup

In your Dockerfile, add the following commands:

```Dockerfile
FROM debian:latest

# Install necessary packages
RUN apt-get update && apt-get install -y curl iptables

# Download and install Tailscale
RUN curl -fsSL https://pkgs.tailscale.com/stable/debian/buster.gpg | gpg --dearmor -o /usr/share/keyrings/tailscale-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/tailscale-archive-keyring.gpg] https://pkgs.tailscale.com/stable/debian/ buster main" | tee /etc/apt/sources.list.d/tailscale.list
RUN apt-get update && apt-get install -y tailscale

# Set up Tailscale configuration
ENV TS_LOG_FILE=/dev/stdout
ENV TS_SKIP_CONFIG_SETUP=1

# Copy authkey file
COPY authkey /authkey

# Entrypoint script to set up routing and register node
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
```

## Entrypoint.sh Script Setup

In the same directory as the Dockerfile, create an `entrypoint.sh` script with the following content:

```bash
#!/bin/bash

# Start Tailscale
tailscaled --state=/state/tailscaled.state --socket=/var/run/tailscale/tailscaled.sock

# Wait for tailscaled socket to be created
while [ ! -S /var/run/tailscale/tailscaled.sock ]; do
  sleep 1
done

# Configure Tailscale and register node with auth key
tailscale up --authkey="$(cat /authkey)" --accept-routes --advertise-exit-node

# Set up iptables to forward all traffic from host to Tailscale
iptables -P FORWARD ACCEPT
iptables -t nat -A POSTROUTING -j MASQUERADE
iptables -I FORWARD -j ACCEPT
iptables -I INPUT -i tailscale0 -j ACCEPT
iptables -I OUTPUT -o tailscale0 -j ACCEPT

# Wait indefinitely to keep the container running
tail -f /dev/null
```

## Auth Key Setup

In the same directory as the Dockerfile and `entrypoint.sh` script, create an `authkey` file. Add your Tailscale authentication key to this file.

## Build the Docker Image

To build the Docker image, navigate to the directory containing the Dockerfile, `authkey` file, and `entrypoint.sh` script, and run the following command:

```bash
docker build -t tailscale-container .
```

## Run the Docker Container

After the build process completes, you can run the container with the following command:

```bash
docker run -d --name tailscale --cap-add=NET_ADMIN --device=/dev/net/tun --network=host tailscale-container
```

This setup reads the auth key from the `authkey` file and passes it to the `tailscale up` command, allowing the node to register with Tailscale using the specified key.
>>>>>>> a81fa2f (first commit)
