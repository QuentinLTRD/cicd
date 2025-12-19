FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

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
      https://a
