# Start with an Ubuntu 22.04 base image
FROM ubuntu:22.04

# Set environment variables to prevent interactive prompts during package installations
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    python3 \
    python3-pip \
    python3-distutils \
    python3-venv \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install OCI CLI
RUN bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)" -- --accept-all-defaults

# Set OCI CLI installation directory to PATH
ENV PATH="$HOME/bin:$PATH"

# Create .oci directory and copy the config file (from the build context)
RUN mkdir -p /root/.oci
COPY config /root/.oci/config

# Test the OCI CLI installation
RUN  /root/bin/oci --version

# Set the default command to run when the container starts
CMD ["/bin/bash"]
