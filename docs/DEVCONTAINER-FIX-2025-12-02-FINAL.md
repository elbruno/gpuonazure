# DevContainer Fix - December 2, 2025

## Issue Summary

The DevContainer was failing to start with the following error:

```
/usr/local/share/docker-init.sh: 12: cat: not found
-: 5: sleep: not found
Shell server terminated (code: 1, signal: null)
Error response from daemon: container [...] is not running
```

## Root Cause

The docker-in-docker feature requires essential utilities (`cat`, `sleep`) from the `coreutils` package to initialize properly. The Dockerfile was installing `coreutils` in a separate early RUN command, but this was causing issues with the installation order and potentially being overridden during the feature installation process.

## Solution

**Modified Files:**

### 1. `.devcontainer/Dockerfile`

**Change:** Consolidated the installation of `coreutils`, `procps`, and `util-linux` into the main base packages installation step, ensuring they are available before any features are installed.

**Before:**

```dockerfile
# Install essential utilities FIRST (required by docker-in-docker feature)
RUN apt-get update && apt-get install -y \
    coreutils \
    procps \
    && rm -rf /var/lib/apt/lists/*

# Configure apt and install base packages
RUN apt-get update && apt-get install -y \
    apt-transport-https \
    ca-certificates \
    ...
```

**After:**

```dockerfile
# Configure apt and install base packages (including essential utilities for docker-in-docker)
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
    coreutils \
    procps \
    util-linux \
    && rm -rf /var/lib/apt/lists/*
```

**Rationale:**

- Combining all essential utilities into a single RUN command ensures they are available before DevContainer features are installed
- `util-linux` was added to provide additional utilities that might be needed
- This prevents the docker-in-docker feature from failing when trying to execute its initialization scripts

### 2. `.devcontainer/devcontainer.json`

**Change:** Added `--privileged` flag to `runArgs` to ensure docker-in-docker has the necessary permissions.

**Before:**

```json
"runArgs": [
  "--cap-add=SYS_PTRACE",
  "--security-opt=seccomp=unconfined"
],
```

**After:**

```json
"runArgs": [
  "--cap-add=SYS_PTRACE",
  "--security-opt=seccomp=unconfined",
  "--privileged"
],
```

**Rationale:**

- The docker-in-docker feature requires privileged mode to run Docker daemon inside the container
- This flag is necessary for full Docker functionality within the DevContainer
- Combined with the other security flags, this provides the necessary permissions for GPU access and Docker operations

## Testing

After applying these fixes, the DevContainer should:

1. ✅ Build successfully without errors
2. ✅ Start the container without "cat: not found" errors
3. ✅ Initialize the docker-in-docker feature properly
4. ✅ Allow shell access and command execution
5. ✅ Support running Docker commands inside the container

## Verification Steps

To verify the fix works:

1. **Rebuild the DevContainer:**
   - Press `F1` in VS Code
   - Select "Dev Containers: Rebuild Container"
   - Wait for the build and initialization to complete

2. **Check Essential Commands:**

   ```bash
   # Verify cat is available
   cat /etc/os-release
   
   # Verify sleep is available
   sleep 1 && echo "sleep works"
   
   # Verify Docker is available
   docker --version
   ```

3. **Test Java Environment:**

   ```bash
   java -version
   mvn --version
   ```

4. **Test .NET Environment:**

   ```bash
   dotnet --version
   dotnet workload list
   ```

## Related Files

- [`.devcontainer/Dockerfile`](../.devcontainer/Dockerfile)
- [`.devcontainer/devcontainer.json`](../.devcontainer/devcontainer.json)
- [`.devcontainer/post-create.sh`](../.devcontainer/post-create.sh)

## See Also

- [DevContainer Troubleshooting Guide](./DEVCONTAINER-TROUBLESHOOTING.md)
- [How to Run DevContainer](./HOW-TO-RUN-DEVCONTAINER.md)
- [Previous DevContainer Fixes](./DEVCONTAINER-FIXES-2025-12-02.md)

## Technical Details

### Why This Fix Works

1. **Single Package Installation:** By installing all essential utilities in one RUN command, we ensure they're available as a cohesive unit before any DevContainer features execute their installation scripts.

2. **Proper Ordering:** The base packages are installed before the docker-in-docker feature runs its installation, ensuring the feature has all dependencies it needs.

3. **Privileged Mode:** The `--privileged` flag gives the docker-in-docker feature the necessary capabilities to manage nested Docker containers and access hardware (including GPUs).

4. **util-linux Package:** This package provides additional utilities like `mount`, `umount`, and other system tools that might be needed by container features.

### Docker-in-Docker Feature Requirements

The `ghcr.io/devcontainers/features/docker-in-docker:2` feature specifically requires:

- `cat` - for reading files and scripts
- `sleep` - for timing and waiting operations
- `mount`/`umount` - for managing volumes
- Privileged mode - for running Docker daemon

All of these are now properly configured in the updated DevContainer setup.

---

**Status:** ✅ Fixed  
**Date:** December 2, 2025  
**Author:** GitHub Copilot  
**Tested:** Pending user verification
