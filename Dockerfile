FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH=/usr/local/bin:/usr/bin:/bin

# ---- Base dependencies ----
RUN apt-get update && apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    software-properties-common \
    unzip \
    apt-transport-https \
    && rm -rf /var/lib/apt/lists/*

# ---- Python 3.9 ----
RUN add-apt-repository ppa:deadsnakes/ppa -y \
    && apt-get update \
    && apt-get install -y \
       python3.9 \
       python3.9-distutils \
       python3-pip \
    && update-alternatives --install /usr/bin/python python /usr/bin/python3.9 1 \
    && rm -rf /var/lib/apt/lists/*

# ---- HashiCorp (Terraform & Vault) ----
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg \
      | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
      https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
      > /etc/apt/sources.list.d/hashicorp.list \
    && apt-get update \
    && apt-get install -y \
       terraform=1.9.5-1 \
       vault=1.17.5-1 \
    && rm -rf /var/lib/apt/lists/*

# ---- Azure CLI ----
RUN curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
      | gpg --dearmor -o /usr/share/keyrings/microsoft-archive-keyring.gpg \
    && echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] \
      https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" \
      > /etc/apt/sources.list.d/azure-cli.list \
    && apt-get update \
    && apt-get install -y \
       azure-cli=2.64.0-1~$(lsb_release -cs) \
    && rm -rf /var/lib/apt/lists/*

# ---- Safe verification only ----
RUN terraform version \
 && vault version \
 && python --version

WORKDIR /workspace

CMD ["/bin/bash"]
