FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TERRAFORM_VERSION=1.9.5
ENV VAULT_VERSION=1.17.5
ENV AZURE_CLI_VERSION=2.64.0

# -----------------------------
# Base dependencies
# -----------------------------
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    unzip \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Python 3.9
# -----------------------------
RUN add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update && apt-get install -y \
        python3.9 \
        python3.9-distutils \
        python3.9-venv \
        python3-pip \
    && update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.9 1 \
    && rm -rf /var/lib/apt/lists/*

# -----------------------------
# Install Terraform
# -----------------------------
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    -o terraform.zip && \
    unzip terraform.zip && \
    mv terraform /usr/local/bin/terraform && \
    chmod +x /usr/local/bin/terraform && \
    rm terraform.zip

# -----------------------------
# Install Vault
# -----------------------------
# RUN curl -fsSL https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
#     -o vault.zip && \
#     unzip vault.zip && \
#     mv vault /usr/local/bin/vault && \
#     chmod +x /usr/local/bin/vault && \
#     rm vault.zip



RUN wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list \
    sudo apt update && sudo apt install vault

# -----------------------------
# Install Azure CLI (Pinned version)
# -----------------------------
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg && \
    echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
        > /etc/apt/sources.list.d/azure-cli.list && \
    apt-get update && \
    apt-get install -y azure-cli=${AZURE_CLI_VERSION}-1~$(lsb_release -cs) && \
    rm -rf /var/lib/apt/lists/*

# -----------------------------
# Verify installations
# -----------------------------
RUN terraform version && \
    vault version && \
    az version && \
    python3 --version

WORKDIR /workspace

CMD ["/bin/bash"]
