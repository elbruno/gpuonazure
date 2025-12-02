# How to Run in DevContainer - Step-by-Step Guide

This guide provides detailed step-by-step instructions for running the GPU-accelerated AI platform using DevContainers in Visual Studio Code or GitHub Codespaces.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Option 1: Visual Studio Code](#option-1-visual-studio-code)
- [Option 2: GitHub Codespaces](#option-2-github-codespaces)
- [Post-Setup: Running the Application](#post-setup-running-the-application)
- [Troubleshooting](#troubleshooting)

---

## Prerequisites

### Important: Works Without GPU! 🎉

**The DevContainer now works perfectly on laptops without GPU!** 
- ✅ No NVIDIA GPU required
- ✅ No CUDA drivers needed on host
- ✅ No special Docker configuration required
- ✅ CPU-only mode is fully supported

The container will automatically:
- Detect if GPU is available (via VS Code)
- Gracefully handle missing CUDA toolkit
- Run in CPU-only mode if GPU not present
- Still provide fast development experience

### For Visual Studio Code

**Required:**
- [Visual Studio Code](https://code.visualstudio.com/) installed
- [Docker Desktop](https://www.docker.com/products/docker-desktop) installed and running
- [Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) installed in VS Code
- At least 8 GB of free disk space
- 8 GB RAM minimum (16 GB recommended)

**Optional (for GPU support):**
- NVIDIA GPU with drivers installed
- NVIDIA Container Toolkit
- CUDA 12.6+ compatible GPU

### For GitHub Codespaces

**Required:**
- GitHub account
- Access to GitHub Codespaces (free tier available)
- Stable internet connection

**Note:** GPU support is not available in GitHub Codespaces. The application will run in CPU mode.

---

## Option 1: Visual Studio Code

### Step 1: Clone the Repository

```bash
git clone https://github.com/elbruno/gpuonazure.git
cd gpuonazure
```

### Step 2: Open in VS Code

```bash
code .
```

Or open VS Code and use **File** → **Open Folder** → select the `gpuonazure` folder.

### Step 3: Reopen in Container

When you open the project, VS Code will detect the `.devcontainer` configuration and show a notification:

**"Folder contains a Dev Container configuration file. Reopen folder to develop in a container."**

Click **"Reopen in Container"**

**Alternative method:**
1. Press `F1` or `Ctrl+Shift+P` (Windows/Linux) / `Cmd+Shift+P` (macOS)
2. Type: `Dev Containers: Reopen in Container`
3. Press Enter

### Step 4: Wait for Container Build

The first time you open the DevContainer, it will:
- Pull the base Ubuntu image (~500 MB)
- Install Java 21, .NET 10, Maven, Azure CLI, and other tools
- Run the post-create script to set up the environment
- Install VS Code extensions

**Expected time:** 5-10 minutes on first build

**Progress indicator:** You'll see the build progress in the VS Code notification and terminal.

### Step 5: Verify Installation

Once the container is ready, open a new terminal in VS Code (`Ctrl+`` or **Terminal** → **New Terminal**) and verify:

```bash
# Check Java
java --version
# Should show: openjdk 21.x.x

# Check .NET
dotnet --version
# Should show: 10.0.x

# Check Maven
mvn --version
# Should show: Apache Maven 3.9.x

# Check Azure CLI (optional)
az --version
# Should show: azure-cli 2.x.x
```

### Step 6: Download Models (First Time Only)

The AI models are not included in the repository due to size (~5 GB). Download them:

```bash
./scripts/download-missing-models.sh
```

**What this does:**
- Downloads Stable Diffusion v1.5 models
- Downloads All-MiniLM-L6-v2 embeddings model
- Organizes files in the `models/` directory

**Expected time:** 10-15 minutes depending on internet speed

### Step 7: Build ONNX Runtime Extensions (First Time Only)

```bash
./scripts/download-ortextensions.sh
```

**What this does:**
- Downloads ONNX Runtime Extensions source
- Compiles `libortextensions.so` library
- Required for CLIP tokenizer in Stable Diffusion

**Expected time:** 5-10 minutes

### Step 8: Run with Aspire

Start the entire application stack with one command:

```bash
cd src/GpuAzure.AppHost
dotnet run
```

**What happens:**
1. Aspire Dashboard starts
2. Java Spring Boot backend starts on port 8080
3. Blazor WebAssembly frontend starts on port 5000/5001
4. JavaScript WebUI is served by Java backend on port 8080
5. Your default browser opens to the Aspire Dashboard (http://localhost:15000)

**Wait for all services to start:** Look for "Application started" messages in the terminal.

### Step 9: Access the Applications

**Aspire Dashboard:**
- URL: http://localhost:15000
- Shows all services, logs, metrics, and traces

**Blazor Frontend (Modern UI):**
- URL: http://localhost:5000 or https://localhost:5001
- Features: Image Generation, Text Embeddings, System Metrics

**JavaScript WebUI (Original UI):**
- URL: http://localhost:8080
- Lightweight HTML/JavaScript interface

**Java Backend API:**
- URL: http://localhost:8080/api/langchain4j
- REST endpoints for image generation and embeddings

### Step 10: Test Image Generation

**In Blazor Frontend:**
1. Navigate to http://localhost:5000
2. Click **"Image Generator"** in the menu
3. Enter prompt: "A friendly robot helping with Azure deployment"
4. Select style: "Classic"
5. Click **"Generate Image"**
6. Wait 30-60 seconds (CPU mode) or 2-5 seconds (GPU mode)
7. Image appears with download option

**In JavaScript WebUI:**
1. Navigate to http://localhost:8080
2. Enter prompt in the text area
3. Select style from dropdown
4. Click **"Generate Image"**
5. Image appears below the form

---

## Option 2: GitHub Codespaces

### Step 1: Open Repository in GitHub

Navigate to: https://github.com/elbruno/gpuonazure

### Step 2: Create Codespace

1. Click the green **"Code"** button
2. Select the **"Codespaces"** tab
3. Click **"Create codespace on main"** (or your branch)

**Alternative:**
- Click **"+"** next to "Codespace" to create a new one
- Select machine type (4-core, 8 GB RAM recommended)

### Step 3: Wait for Codespace Creation

GitHub will:
- Create a cloud-based development environment
- Build the DevContainer configuration
- Install all required tools
- Run post-create scripts

**Expected time:** 3-5 minutes

**Progress:** You'll see "Setting up codespace..." with a progress bar.

### Step 4: Verify Environment

Once ready, the VS Code interface opens in your browser. Open a terminal and verify:

```bash
java --version
dotnet --version
mvn --version
```

### Step 5: Download Models

**Important:** Codespaces have limited storage. Check available space first:

```bash
df -h
# Look for available space on /workspaces

# Download models
./scripts/download-missing-models.sh
```

**Note:** If you're low on storage, models can be downloaded on-demand when the app starts (slower first generation).

### Step 6: Build ONNX Runtime Extensions

```bash
./scripts/download-ortextensions.sh
```

### Step 7: Run with Aspire

```bash
cd src/GpuAzure.AppHost
dotnet run
```

### Step 8: Access Applications

Codespaces automatically forwards ports. Look for port forwarding notifications or:

1. Click the **"Ports"** tab in VS Code (bottom panel)
2. Find forwarded ports:
   - `8080` - Java Backend + JavaScript WebUI
   - `5000` - Blazor Frontend (HTTP)
   - `5001` - Blazor Frontend (HTTPS)
   - `15000` - Aspire Dashboard
3. Click the **"Open in Browser"** icon (🌐) next to each port

**Example URLs:**
- Aspire Dashboard: https://yourusername-gpuonazure-randomid-15000.preview.app.github.dev
- Blazor Frontend: https://yourusername-gpuonazure-randomid-5000.preview.app.github.dev
- Java Backend: https://yourusername-gpuonazure-randomid-8080.preview.app.github.dev

### Step 9: Test the Application

Follow the same testing steps as Visual Studio Code (Step 10 above), but use the forwarded URLs.

---

## Post-Setup: Running the Application

### Quick Start (After Initial Setup)

Once models are downloaded and environment is ready:

```bash
# Navigate to AppHost
cd src/GpuAzure.AppHost

# Start everything
dotnet run
```

That's it! All services start automatically.

### Running Services Individually

**Java Backend Only:**
```bash
# From repository root
mvn spring-boot:run
```

**Blazor Frontend Only:**
```bash
cd src/BlazorFrontend/BlazorFrontend
dotnet run
```

**Note:** When running individually, you need to start the Java backend first so the frontend can connect to it.

### Stopping Services

**With Aspire:**
- Press `Ctrl+C` in the terminal where `dotnet run` is running
- All services stop automatically

**Individual Services:**
- Press `Ctrl+C` in each terminal

### Rebuilding After Code Changes

**Java Backend:**
```bash
# From repository root
mvn clean install
mvn spring-boot:run
```

**Blazor Frontend:**
```bash
cd src/BlazorFrontend/BlazorFrontend
dotnet build
dotnet run
```

**Aspire (rebuilds all):**
```bash
cd src/GpuAzure.AppHost
dotnet build
dotnet run
```

---

## Troubleshooting

### Issue: "Reopen in Container" Doesn't Appear

**Solution:**
1. Ensure Docker Desktop is running
2. Install "Dev Containers" extension
3. Reload VS Code window (`Ctrl+Shift+P` → "Reload Window")
4. Manually open: `Ctrl+Shift+P` → "Dev Containers: Reopen in Container"

### Issue: Container Build Fails

**Solution 1 - Docker Resources:**
```bash
# Check Docker is running
docker ps

# Check Docker disk space
docker system df

# Clean up if needed
docker system prune -a
```

**Solution 2 - Increase Docker Resources:**
- Open Docker Desktop
- Settings → Resources
- Increase Memory to 8 GB minimum
- Increase Disk space to 50 GB minimum
- Restart Docker Desktop

### Issue: Models Download Fails

**Solution:**
```bash
# Check internet connection
curl -I https://huggingface.co

# Manually download if needed
cd models
# Follow instructions in scripts/download-missing-models.sh
```

### Issue: Port Already in Use

**Error:** "Address already in use (port 8080/5000/15000)"

**Solution:**
```bash
# Find process using the port
lsof -i :8080  # or :5000, :15000

# Kill the process
kill -9 <PID>

# Or use different ports in appsettings.json
```

### Issue: HTTPS Certificate Errors (Blazor)

**Solution:**
```bash
# Trust development certificate
dotnet dev-certs https --trust

# Regenerate if needed
dotnet dev-certs https --clean
dotnet dev-certs https --trust
```

### Issue: Java Backend Won't Start

**Check:**
```bash
# Verify Java version
java --version  # Should be 21.x

# Check if models are downloaded
ls -la models/stable-diffusion/
ls -la models/all-MiniLM-L6-v2/

# Check if ONNX extensions are built
ls -la libortextensions.so

# Run with verbose logging
mvn spring-boot:run -X
```

### Issue: Blazor Frontend Can't Connect to Backend

**Check:**
1. Verify backend is running: `curl http://localhost:8080/api/langchain4j/health`
2. Check backend URL in `src/BlazorFrontend/BlazorFrontend.Client/wwwroot/appsettings.json`
3. Verify CORS is enabled in Java backend
4. Check Aspire Dashboard for service status

### Issue: Aspire Dashboard Won't Open

**Solution:**
```bash
# Check if port 15000 is available
lsof -i :15000

# Manually open dashboard
open http://localhost:15000  # macOS
xdg-open http://localhost:15000  # Linux
start http://localhost:15000  # Windows
```

### Issue: GPU Not Detected (VS Code with GPU)

**Check:**
```bash
# Verify NVIDIA drivers on host
nvidia-smi

# Check Docker has GPU access
docker run --rm --gpus all nvidia/cuda:12.6.0-base-ubuntu22.04 nvidia-smi

# Update devcontainer.json if needed
# Ensure "runArgs": ["--gpus=all"] is present
```

### Issue: Out of Memory

**For VS Code:**
- Increase Docker memory allocation (Docker Desktop → Settings → Resources)
- Close other applications
- Use CPU mode instead of GPU (uses less memory)

**For Codespaces:**
- Upgrade to larger machine type (8-core, 16 GB)
- Close other Codespaces
- Clear models/cache if needed

---

## Performance Tips

### For Faster Startup

1. **Keep models downloaded:** Don't delete the `models/` directory
2. **Use Aspire:** Starts all services together efficiently
3. **Enable hot reload:** Changes apply without full restart

### For Faster Image Generation

1. **Enable GPU mode:** Edit `src/GpuAzure.AppHost/AppHost.cs`
   ```csharp
   .WithEnvironment("GPU_LANGCHAIN4J_GPU_ENABLED", "true")
   ```

2. **Reduce inference steps:** Edit `src/main/resources/application.yml`
   ```yaml
   langchain4j:
     models:
       image-generation:
         stable-diffusion-v15:
           num-inference-steps: 20  # Default is 50
   ```

3. **Use smaller images:** Reduce resolution in configuration

### For Development Efficiency

1. **Use hot reload:**
   ```bash
   # Java (with Spring DevTools)
   mvn spring-boot:run
   
   # Blazor
   dotnet watch run
   ```

2. **Open multiple terminals:** One for backend, one for frontend, one for logs

3. **Use Aspire Dashboard:** Monitor logs, metrics, and traces in real-time

---

## Next Steps

- **Read:** [Architectural Overview](./ARCHITECTURE.md)
- **Explore:** [Blazor Frontend Documentation](./BLAZOR-FRONTEND.md)
- **Learn:** [Aspire Integration Guide](./DEVCONTAINER-BLAZOR-ASPIRE-GUIDE.md)
- **Deploy:** [Azure Deployment Guide](./AZURE-DEPLOYMENT-GUIDE.md)

---

## Quick Reference

### Essential Commands

```bash
# Start everything with Aspire
cd src/GpuAzure.AppHost && dotnet run

# Start Java backend only
mvn spring-boot:run

# Start Blazor frontend only
cd src/BlazorFrontend/BlazorFrontend && dotnet run

# Download models (first time)
./scripts/download-missing-models.sh

# Build ONNX extensions (first time)
./scripts/download-ortextensions.sh

# Check service health
curl http://localhost:8080/api/langchain4j/health
```

### Important URLs

- **Aspire Dashboard:** http://localhost:15000
- **Blazor Frontend:** http://localhost:5000
- **JavaScript WebUI:** http://localhost:8080
- **Java Backend API:** http://localhost:8080/api/langchain4j

### File Locations

- **DevContainer Config:** `.devcontainer/devcontainer.json`
- **Aspire Config:** `src/GpuAzure.AppHost/AppHost.cs`
- **Models:** `models/` directory
- **Java Backend:** `src/main/java/com/azure/gpudemo/`
- **Blazor Frontend:** `src/BlazorFrontend/`

---

**Congratulations! You're ready to develop with DevContainers!** 🎉
