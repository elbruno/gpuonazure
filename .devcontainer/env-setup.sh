#!/bin/bash
# Lightweight environment setup script (Fix F applied)
# Ensures system PATH is sane and exports domain-specific vars.
set -e

echo "[env-setup] Initial PATH: $PATH"
DEFAULT_SYSTEM_PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"
# If /usr/bin not visible, prepend defaults
if ! echo "$PATH" | grep -q "/usr/bin"; then
  export PATH="$DEFAULT_SYSTEM_PATH:$PATH"
  echo "[env-setup] Repaired PATH => $PATH"
fi

# Domain env vars
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
export MAVEN_HOME=/usr/share/maven
# DOTNET installed by post-install to /usr/local/share/dotnet
export DOTNET_ROOT=/usr/local/share/dotnet
export CUDA_HOME=/usr/local/cuda
export LD_LIBRARY_PATH=/usr/local/cuda/lib64:${LD_LIBRARY_PATH}

# Idempotent .bashrc augmentation
append_unique() {
  local line="$1"
  local file="$2"
  grep -qxF "$line" "$file" || echo "$line" >> "$file"
}

append_unique "export JAVA_HOME=$JAVA_HOME" "$HOME/.bashrc"
append_unique "export MAVEN_HOME=$MAVEN_HOME" "$HOME/.bashrc"
append_unique "export DOTNET_ROOT=$DOTNET_ROOT" "$HOME/.bashrc"
append_unique "export CUDA_HOME=$CUDA_HOME" "$HOME/.bashrc"
append_unique "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH" "$HOME/.bashrc"
append_unique "export PATH=$DEFAULT_SYSTEM_PATH:$PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin:$DOTNET_ROOT" "$HOME/.bashrc"

echo "[env-setup] Environment variables staged."
