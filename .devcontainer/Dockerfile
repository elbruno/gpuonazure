# DevContainer for GPU-accelerated AI development with Java 21, .NET 10, and CUDA support
FROM mcr.microsoft.com/devcontainers/base:ubuntu-22.04

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Install essential utilities FIRST (required by docker-in-docker feature)
RUN apt-get update && apt-get install -y \
    coreutils \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Configure apt and install base packages
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    wget \
    gnupg \
    lsb-release \
    software-properties-common \
    git \
    build-essential \
    cmake \
    python3 \
    python3-pip \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Install Java 21 (OpenJDK)
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk \
    openjdk-21-jre \
    maven \
    && rm -rf /var/lib/apt/lists/*

# Set Java environment variables
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH="${JAVA_HOME}/bin:${PATH}"

# Install .NET 10 SDK
RUN wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh \
    && chmod +x /tmp/dotnet-install.sh \
    && /tmp/dotnet-install.sh --channel 10.0 --install-dir /usr/share/dotnet \
    && rm /tmp/dotnet-install.sh

# Add .NET to PATH
ENV DOTNET_ROOT=/usr/share/dotnet
ENV PATH="${DOTNET_ROOT}:${PATH}"

# Install .NET Aspire CLI as native executable (recommended method)
# This installs Aspire CLI as a standalone binary instead of using dotnet workload
# See: https://aspire.dev/get-started/install-cli/#install-as-a-native-executable
RUN curl -sSL https://aspire.dev/install.sh | bash \
    && echo 'export PATH="$HOME/.aspire/bin:$PATH"' >> /home/vscode/.bashrc

# Add Aspire to PATH for the build process
ENV PATH="/home/vscode/.aspire/bin:${PATH}"

# Install NVIDIA CUDA Toolkit (for GPU support)
# Note: Full GPU support requires running on a host with NVIDIA drivers
# Installation is optional and will not fail if CUDA is unavailable
RUN apt-get update && \
    (apt-get install -y nvidia-cuda-toolkit || echo "CUDA toolkit not available - continuing with CPU-only support") && \
    rm -rf /var/lib/apt/lists/*

# Set CUDA environment variables (paths may not exist if CUDA not installed)
# Applications should gracefully handle missing CUDA
ENV CUDA_HOME=/usr/local/cuda
ENV PATH=/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/cuda/lib64

# Install Node.js and npm (for frontend tooling if needed)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Create workspace directory
RUN mkdir -p /workspace/models \
    && chown -R vscode:vscode /workspace

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# Set working directory
WORKDIR /workspace

# Default user
USER vscode
