FROM centos:7

ENV TERRAFORM_VERSION=1.9.5
ENV VAULT_VERSION=1.17.5
ENV AZURE_CLI_VERSION=2.64.0
ENV PYTHON_VERSION=3.9.18

# Install base dependencies
RUN yum -y update && \
    yum -y install \
        # yum-utils \
        curl \
        unzip \
        # git \
        gcc \
        # make \
        # openssl-devel \
        bzip2-devel \
        libffi-devel \
        zlib-devel \
        # readline-devel \
        sqlite-devel \
        wget && \
    yum clean all

# -----------------------------
# Install Python 3.9 (from source)
# -----------------------------
RUN cd /usr/src && \
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz && \
    tar xzf Python-${PYTHON_VERSION}.tgz && \
    cd Python-${PYTHON_VERSION} && \
    ./configure --enable-optimizations && \
    make altinstall && \
    ln -sf /usr/local/bin/python3.9 /usr/bin/python3 && \
    ln -sf /usr/local/bin/pip3.9 /usr/bin/pip3 && \
    cd / && rm -rf /usr/src/Python-${PYTHON_VERSION}*

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
RUN curl -fsSL https://releases.hashicorp.com/vault/${VAULT_VERSION}/vault_${VAULT_VERSION}_linux_amd64.zip \
    -o vault.zip && \
    unzip vault.zip && \
    mv vault /usr/local/bin/vault && \
    chmod +x /usr/local/bin/vault && \
    rm vault.zip

# -----------------------------
# Install Azure CLI
# -----------------------------
RUN rpm --import https://packages.microsoft.com/keys/microsoft.asc && \
    sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo' && \
    yum install -y azure-cli-${AZURE_CLI_VERSION} && \
    yum clean all

# -----------------------------
# Verify installations
# -----------------------------
RUN terraform version && \
    vault version && \
    az version && \
    python3 --version

WORKDIR /workspace

CMD ["/bin/bash"]
