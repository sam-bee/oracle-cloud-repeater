# Start with an Ubuntu 22.04 base image
FROM ubuntu:22.04



### INSTALL OCI TOOL ###

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



### INSTALL UTILITY FOR RETRYING COMMANDS ###

# Install Go
RUN apt-get update && apt-get install -y \
    wget

RUN wget https://go.dev/dl/go1.21.1.linux-amd64.tar.gz -O /tmp/go.tar.gz -q && \
    tar -C /usr/local -xzf /tmp/go.tar.gz && \
    rm /tmp/go.tar.gz

# Set Go environment variables
ENV PATH="/usr/local/go/bin:$PATH"
ENV GOPATH="/go"
ENV PATH="$GOPATH/bin:$PATH"

# Create a directory for the Go project
RUN mkdir -p /app/repeat-command

# Copy the Go source code from the local directory to the container
COPY ./repeat-command /app/repeat-command

# Build the Go project (assumes your Go code has a main.go file)
RUN go build -o /app/repeat-command/main /app/repeat-command/main.go



### IMPORT USER'S OTHER FILES, E.G. TERRAFORM FILES ETC. ###

# Whatever the user wants to put in ./other-files/ should end up on the container in /app/other-files/
RUN mkdir -p /app/other-files/
COPY ./other-files /app/other-files



### GIVE USER A SHELL ###

# Set the default command to run when the container starts
CMD ["/bin/bash"]
