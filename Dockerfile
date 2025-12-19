# Base image
FROM ubuntu:22.04

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Versions
ENV TERRAFORM_VERSION=1.9.5
ENV VAULT_VERSION=1.17.5
ENV AZURE_CLI_VERSION=2.64.0
ENV PYTHON_VERSION=3.9

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    gnupg \
    lsb-release \
    ca-certificates \
    software-properties-common \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# Install Python 3.9
# -------------------------
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && \
    apt-get install -y \
        python3.9 \
        python3.9-distutils \
        python3.9-venv \
        python3-pip \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1 \
    && rm -rf /var/lib/apt/lists/*

# -------------------------
# Install Terraform
# -------------------------
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    rm terraform.zip

# -------------------------
# Install Vault (buildx-safe, dependency-safe)
# -------------------------
ARG TARGETARCH

RUN set -eux; \
    apt-get update; \
    apt-get install -y unzip ca-certificates; \
    case "${TARGETARCH}" in \
        amd64) VAULT_ARCH="amd64" ;; \
        arm64) VAULT_ARCH="arm64" ;; \
        *) echo "Unsupported architecture: ${TARGETARCH}" && exit 1 ;; \
    esac; \
    echo "Downloading Vault for ${VAULT_ARCH}"; \
    curl -L \
      "https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_${VAULT_ARCH}.zip" \
      -o vault.zip; \
    ls -lh vault.zip; \
    unzip vault.zip; \
    install -m 0755 vault /usr/local/bin/vault; \
    vault version; \
    rm -f vault vault.zip; \
    rm -rf /var/lib/apt/lists/*



# -------------------------
# Install Azure CLI
# -------------------------
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg && \
    install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/ && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/azure-cli.list && \
    rm microsoft.gpg && \
    apt-get update && \
    apt-get install -y azure-cli=${AZURE_CLI_VERSION}-1~$(lsb_release -cs) && \
    rm -rf /var/lib/apt/lists/*

# -------------------------
# Verify installations
# -------------------------
RUN terraform version && \
    vault version && \
    az version && \
    python --version

# Default command
CMD ["/bin/bash"]
