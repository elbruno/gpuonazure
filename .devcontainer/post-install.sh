#!/bin/bash
# DevContainer Post-Installation Script
# Installs Java 21, .NET 10, Aspire, CUDA, and other development tools

set -e

echo "=========================================="
echo "Starting DevContainer Post-Installation"
echo "=========================================="

# Update package lists
echo "Updating package lists..."
sudo apt-get update

# Install Java 21 (OpenJDK)
echo "Installing Java 21..."
sudo apt-get install -y openjdk-21-jdk openjdk-21-jre maven

# Verify Java installation
echo "Java version:"
java -version
echo "Maven version:"
mvn -version

# Install .NET 10 SDK
echo "Installing .NET 10 SDK..."
wget https://dot.net/v1/dotnet-install.sh -O /tmp/dotnet-install.sh
chmod +x /tmp/dotnet-install.sh
/tmp/dotnet-install.sh --channel 10.0 --install-dir /usr/local/share/dotnet
rm /tmp/dotnet-install.sh

# Add .NET to PATH for current session
export DOTNET_ROOT=/usr/local/share/dotnet
export PATH="$DOTNET_ROOT:$PATH"

# Add .NET to user's bashrc
if ! grep -q "DOTNET_ROOT=/usr/local/share/dotnet" ~/.bashrc; then
    echo 'export DOTNET_ROOT=/usr/local/share/dotnet' >> ~/.bashrc
    echo 'export PATH="$DOTNET_ROOT:$PATH"' >> ~/.bashrc
fi

# Verify .NET installation
echo ".NET version:"
/usr/local/share/dotnet/dotnet --version

# Install .NET Aspire CLI as native executable
echo "Installing .NET Aspire CLI..."
curl -sSL https://aspire.dev/install.sh | bash

# Add Aspire to PATH in bashrc if not already present
if ! grep -q ".aspire/bin" ~/.bashrc; then
    echo 'export PATH="$HOME/.aspire/bin:$PATH"' >> ~/.bashrc
fi

# Add Aspire to current session PATH
export PATH="$HOME/.aspire/bin:$PATH"

# Verify Aspire installation
echo "Aspire CLI version:"
if [ -f "$HOME/.aspire/bin/aspire" ]; then
    $HOME/.aspire/bin/aspire --version || echo "Aspire installed but version check unavailable"
else
    echo "Aspire CLI installed but binary not found in expected location"
fi

# Install NVIDIA CUDA Toolkit (optional - will not fail if unavailable)
echo "Attempting to install NVIDIA CUDA Toolkit (optional)..."
if sudo apt-get install -y nvidia-cuda-toolkit 2>/dev/null; then
    echo "CUDA toolkit installed successfully"
    
    # Set CUDA environment variables
    if ! grep -q "CUDA_HOME=/usr/local/cuda" ~/.bashrc; then
        echo 'export CUDA_HOME=/usr/local/cuda' >> ~/.bashrc
        echo 'export PATH="/usr/local/cuda/bin:$PATH"' >> ~/.bashrc
        echo 'export LD_LIBRARY_PATH="/usr/local/cuda/lib64:$LD_LIBRARY_PATH"' >> ~/.bashrc
    fi
else
    echo "CUDA toolkit not available - continuing with CPU-only support"
fi

# Install Node.js 20 and npm (for frontend tooling)
echo "Installing Node.js 20..."
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify Node installation
echo "Node.js version:"
node --version
echo "npm version:"
npm --version

# Install Azure CLI
echo "Installing Azure CLI..."
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify Azure CLI installation
echo "Azure CLI version:"
az --version | head -n 1

# Create workspace directories
echo "Creating workspace directories..."
sudo mkdir -p /workspace/models
sudo chown -R $(whoami):$(whoami) /workspace

# Clean up
echo "Cleaning up..."
sudo apt-get clean
sudo rm -rf /var/lib/apt/lists/*

# GPU detection for post-create info
echo ""
echo "=========================================="
echo "Installation Complete!"
echo "=========================================="
echo ""
echo "GPU Detection:"
if command -v nvidia-smi &> /dev/null; then
    echo "✓ nvidia-smi found - GPU support available"
    nvidia-smi --query-gpu=name,driver_version --format=csv,noheader 2>/dev/null || echo "  (nvidia-smi installed but GPU not detected)"
else
    echo "✗ nvidia-smi not found - CPU-only mode"
    echo "  To enable GPU support, ensure you're running on a host with NVIDIA drivers"
fi

echo ""
echo "Installed Tools:"
echo "  Java:    $(java -version 2>&1 | head -n 1)"
echo "  Maven:   $(mvn -version 2>&1 | head -n 1)"
echo "  .NET:    $(/usr/local/share/dotnet/dotnet --version)"
echo "  Node.js: $(node --version)"
echo "  npm:     $(npm --version)"
echo "  Azure CLI: $(az --version | head -n 1)"
echo ""
echo "Environment configured! Please reload your shell or restart the DevContainer."
echo ""
