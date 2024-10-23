# Start with an Ubuntu 22.04 base image
FROM ubuntu:22.04


### IMPORT THE USER'S FILES ###

# Give user the whole folder with their stuff in it on the container
COPY ./resources /app/resources
# The config file is for the Oracle Cloud Interface (OCI) CLI
RUN mkdir -p /root/.oci
RUN ln -s /app/resources/config /root/.oci/config



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

# Test the OCI CLI installation
RUN  /root/bin/oci --version



### INSTALL UTILITY FOR RETRYING COMMANDS ###

# Install Go
RUN apt-get update && apt-get install -y wget
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



### INSTALL TERRAFORM ###

RUN wget -q https://releases.hashicorp.com/terraform/1.5.7/terraform_1.5.7_linux_amd64.zip && \
    apt install -y zip && \
    unzip terraform_1.5.7_linux_amd64.zip && \
    mv terraform /usr/local/bin/ && \
    terraform --version



### SHELL ###

CMD ["/bin/bash"]
