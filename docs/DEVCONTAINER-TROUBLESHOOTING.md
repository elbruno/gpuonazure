# DevContainer Troubleshooting Guide

## Common Issues and Solutions

### GPU-Related Issues

#### Issue: "nvidia-container-cli: initialization error: WSL environment detected but no adapters were found"

**Cause**: The DevContainer is trying to use GPU support but your system doesn't have an NVIDIA GPU or the drivers aren't properly configured.

**Solution**: This has been fixed in the latest devcontainer.json. The container now runs in CPU-only mode when GPU is not available.

- **For Development**: CPU-only mode is perfectly fine. The application will work without GPU, just slower for inference.
- **For Production**: Deploy to Azure Container Apps with GPU profiles (NC8as_T4_v3 or NC24ads_A100_v4) where GPU will be available.

#### Manually Enabling GPU Support

If you have an NVIDIA GPU and want to enable it in the DevContainer:

1. **Install NVIDIA Container Toolkit** in WSL2:

   ```bash
   # In WSL2 terminal
   distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
   curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
   curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | \
     sudo tee /etc/apt/sources.list.d/nvidia-docker.list
   
   sudo apt-get update
   sudo apt-get install -y nvidia-container-toolkit
   sudo systemctl restart docker
   ```

2. **Verify GPU is accessible**:

   ```bash
   docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi
   ```

3. **Uncomment GPU configuration** in [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json):

   ```json
   "hostRequirements": { "gpu": true }
   ```

4. **Rebuild the DevContainer** in VS Code:
   - Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
   - Select "Dev Containers: Rebuild Container"

### Docker Build Takes Too Long (16+ minutes)

**Cause**: The DevContainer installs:

- Java 21 JDK
- .NET 10 SDK
- NVIDIA CUDA Toolkit (2.2GB)
- Node.js
- Azure CLI
- Docker-in-Docker

**Solutions**:

1. **Use Layer Caching**: Docker caches layers, so subsequent builds are much faster
2. **Use Pre-built Image**: Consider building a base image and pushing to a container registry
3. **Adjust Dockerfile**: Remove tools you don't need for your workflow

### Maven Dependencies Download Slowly

**Cause**: First-time Maven dependency download can take several minutes.

**Solution**: Maven dependencies are cached in Docker volumes, so they only download once.

### .NET Aspire Not Found

**Cause**: Aspire CLI installation may fail or not be in PATH.

**Solution**:

1. Check if Aspire is installed:

   ```bash
   aspire --version
   ```

2. If not found, install manually:

   ```bash
   curl -sSL https://aspire.dev/install.sh | bash
   echo 'export PATH="$HOME/.aspire/bin:$PATH"' >> ~/.bashrc
   source ~/.bashrc
   ```

### Port Already in Use

**Cause**: Another process is using one of the forwarded ports (8080, 5000, 5001, 15000, 18888).

**Solution**:

1. **Find and stop the conflicting process**:

   ```bash
   # Windows
   netstat -ano | findstr :8080
   taskkill /PID <PID> /F
   
   # Linux/Mac
   lsof -i :8080
   kill <PID>
   ```

2. **Change port in configuration**:
   - Java Backend: [src/main/resources/application.yml](../src/main/resources/application.yml)
   - Blazor: [src/BlazorFrontend/BlazorFrontend/appsettings.json](../src/BlazorFrontend/BlazorFrontend/appsettings.json)
   - Aspire Dashboard: Auto-assigned, no change needed

### Container Fails to Start with "Mount Error"

**Cause**: The `models` directory doesn't exist or has permission issues.

**Solution**:

1. Create the models directory:

   ```bash
   mkdir -p models
   ```

2. Rebuild the container:
   - Press `Ctrl+Shift+P`
   - Select "Dev Containers: Rebuild Container"

### Java Extension Not Working

**Cause**: Java Language Server may not have started properly.

**Solution**:

1. **Check Java installation**:

   ```bash
   java --version
   which java
   echo $JAVA_HOME
   ```

2. **Reload VS Code window**:
   - Press `Ctrl+Shift+P`
   - Select "Developer: Reload Window"

3. **Clean Java workspace**:
   - Press `Ctrl+Shift+P`
   - Select "Java: Clean Java Language Server Workspace"

### Performance Issues

#### Slow File I/O

**Cause**: Bind mounts on Windows/WSL2 can be slow.

**Solutions**:

1. **Use WSL2 file system**: Clone repository inside WSL2, not Windows

   ```bash
   # In WSL2
   cd ~
   git clone https://github.com/yourrepo/gpuonazure.git
   code gpuonazure
   ```

2. **Use named volumes**: Already configured for Docker-in-Docker and VSCode extensions

#### High CPU Usage

**Cause**: Background processes (Java Language Server, .NET OmniSharp, TypeScript compiler).

**Solution**: These are normal and will settle down after initial indexing.

## Recommended Workflow

### For Local Development (No GPU)

1. Work in DevContainer with CPU-only mode
2. Focus on application logic, API endpoints, UI
3. Use smaller models or mock data for testing
4. Deploy to Azure for GPU-accelerated testing

### For GPU Development

1. Use Azure VM with GPU (NC-series)
2. Install NVIDIA drivers and CUDA
3. Use Docker with `--gpus all` flag
4. Or deploy directly to Azure Container Apps with GPU profile

## Getting Help

If you encounter issues not covered here:

1. Check the logs:
   - VS Code: View → Output → Dev Containers
   - Docker: `docker logs <container-id>`
   - Application: Check console output

2. Rebuild from scratch:

   ```bash
   # Remove all containers and volumes
   docker system prune -a --volumes
   
   # Rebuild DevContainer
   Ctrl+Shift+P → "Dev Containers: Rebuild Container Without Cache"
   ```

3. Check documentation:
   - [HOW-TO-RUN-DEVCONTAINER.md](./HOW-TO-RUN-DEVCONTAINER.md)
   - [DEVCONTAINER-BLAZOR-ASPIRE-GUIDE.md](./DEVCONTAINER-BLAZOR-ASPIRE-GUIDE.md)
   - [ARCHITECTURE.md](./ARCHITECTURE.md)

---

**Last Updated**: December 2, 2025  
**Project Version**: 1.0.0
