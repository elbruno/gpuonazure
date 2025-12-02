# DevContainer, Blazor, and Aspire Integration Guide

This document provides a comprehensive guide to the new features added to the GPU Azure AI platform.

## 🎯 What's New

### 1. DevContainer Support
Complete development environment with all tools pre-configured for VS Code and GitHub Codespaces.

### 2. Blazor .NET 10 Frontend
Modern, interactive web UI built with Blazor WebAssembly for consuming the Java backend APIs.

### 3. .NET Aspire 13 Orchestration
Service orchestration platform that manages both Java and .NET services with built-in observability.

---

## 🚀 Quick Start Guide

### Option 1: Run Everything with Aspire (Recommended)

```bash
cd src/GpuAzure.AppHost
dotnet run
```

**What happens:**
- ✅ Java Spring Boot backend starts on port 8080
- ✅ Blazor frontend starts on ports 5000/5001
- ✅ Aspire Dashboard opens at http://localhost:15000
- ✅ All services automatically discover each other

**Access:**
- **Blazor UI**: http://localhost:5000
- **Java API**: http://localhost:8080  
- **Aspire Dashboard**: http://localhost:15000

### Option 2: Use DevContainer

**In VS Code:**
1. Install Docker Desktop
2. Install "Dev Containers" extension
3. Open project and click "Reopen in Container"
4. Run: `cd src/GpuAzure.AppHost && dotnet run`

**In GitHub Codespaces:**
1. Click "Code" → "Codespaces" → "Create codespace"
2. Wait for setup (5 minutes first time)
3. Run: `cd src/GpuAzure.AppHost && dotnet run`

### Option 3: Traditional Manual Setup

**Terminal 1 - Java Backend:**
```bash
# Download models first (if not already done)
./scripts/download-missing-models.sh
./scripts/download-ortextensions.sh

# Start backend
mvn spring-boot:run
```

**Terminal 2 - Blazor Frontend:**
```bash
cd src/BlazorFrontend/BlazorFrontend
dotnet run
```

---

## 📁 Project Structure

```
gpuonazure/
├── .devcontainer/                    # DevContainer configuration
│   ├── devcontainer.json            # VS Code/Codespaces config
│   ├── Dockerfile                   # Dev environment image
│   └── post-create.sh               # Setup script
│
├── src/
│   ├── GpuAzure.AppHost/            # Aspire orchestration
│   │   └── AppHost.cs               # Service configuration
│   │
│   ├── GpuAzure.ServiceDefaults/    # Shared Aspire config
│   │   └── Extensions.cs            # Health checks, telemetry
│   │
│   ├── BlazorFrontend/              # Blazor WebAssembly app
│   │   ├── BlazorFrontend/          # Server project
│   │   │   ├── Components/
│   │   │   │   ├── Pages/
│   │   │   │   │   └── Home.razor   # Landing page
│   │   │   │   └── Layout/
│   │   │   │       └── NavMenu.razor
│   │   │   └── Program.cs
│   │   │
│   │   └── BlazorFrontend.Client/   # Client project
│   │       ├── Pages/
│   │       │   ├── ImageGenerator.razor
│   │       │   ├── Embeddings.razor
│   │       │   └── SystemMetrics.razor
│   │       ├── Services/
│   │       │   └── GpuBackendService.cs
│   │       └── Program.cs
│   │
│   └── GpuAzure.sln                 # Solution file
│
├── src/main/java/                   # Existing Java backend
│   └── com/azure/gpudemo/
│       ├── controller/
│       ├── service/
│       └── config/
│
├── docs/
│   └── BLAZOR-FRONTEND.md           # Blazor documentation
│
└── README.md                        # Main documentation
```

---

## 🎨 Blazor Frontend Features

### 1. Image Generator (`/image-generator`)

**Generate AI images from text prompts**

Features:
- Text prompt input with character limit
- Style selection (Classic, Happy, Confused, Excited)
- Real-time progress indicator
- Image preview with download button
- Sample prompts for quick testing
- Generation time tracking

Example prompts:
- "A friendly robot helping with Azure deployment"
- "A futuristic data center with glowing servers"
- "An AI brain connected to GPU processors"

### 2. Text Embeddings (`/embeddings`)

**Compare semantic similarity between texts**

Features:
- Dual text input fields
- Similarity score (0-100%)
- Color-coded progress bar
- Interpretation guide
- Sample comparisons

Similarity levels:
- 90-100%: Very similar/identical meaning
- 70-90%: Strong semantic similarity
- 50-70%: Moderate similarity
- 0-50%: Low similarity/different topics

### 3. System Metrics (`/metrics`)

**Monitor system health in real-time**

Features:
- GPU availability status
- Model loading status
- ONNX Runtime version
- Backend connectivity
- Auto-refresh every 10 seconds

Displays:
- Stable Diffusion v1.5 status (SD4J provider)
- All-MiniLM-L6-v2 embeddings status
- Real-time health checks

---

## 🌐 .NET Aspire Benefits

### What is Aspire?

.NET Aspire is an opinionated, cloud-ready stack for building observable, production-ready distributed applications.

### Key Benefits

1. **Unified Development Experience**
   - Start all services with one command
   - Automatic service discovery
   - No hardcoded URLs

2. **Built-in Observability**
   - Distributed tracing
   - Metrics collection
   - Centralized logging
   - Health monitoring

3. **Dashboard**
   - Service status overview
   - Log aggregation
   - Real-time metrics
   - Environment management

4. **Production-Ready**
   - Service defaults (health checks, telemetry)
   - Resilience patterns
   - Configuration management

### Aspire Dashboard Features

Access at **http://localhost:15000**

**Tabs:**
- **Resources**: Service status and endpoints
- **Console**: Aggregated logs from all services
- **Traces**: Distributed tracing visualization
- **Metrics**: Performance metrics and charts
- **Environment**: Environment variables

---

## 🐳 DevContainer Details

### Included Tools

The DevContainer includes everything needed for development:

**Languages & Runtimes:**
- Java 21 JDK (OpenJDK)
- .NET 10 SDK
- Maven 3.9+
- Node.js 20 (for tooling)

**Cloud & Container:**
- Azure CLI
- Docker-in-Docker
- CUDA Toolkit (for GPU hosts)

**VS Code Extensions:**
- Java Extension Pack
- C# Dev Kit
- Blazor WASM Debugging
- Docker
- Azure Container Apps
- GitHub Copilot

### GPU Support in DevContainer

**Requirements:**
- NVIDIA GPU on host machine
- NVIDIA Container Toolkit installed
- Docker Desktop with GPU support

**Configuration:**
```json
"runArgs": [
  "--gpus=all"
]
```

**Note:** CPU mode works everywhere; GPU is optional.

---

## 🔧 Configuration

### Backend URL Configuration

**In Blazor (`appsettings.json`):**
```json
{
  "BackendUrl": "http://localhost:8080"
}
```

**With Aspire (automatic):**
```csharp
var blazorFrontend = builder.AddProject<Projects.BlazorFrontend>("blazor-frontend")
    .WithEnvironment("BackendUrl", javaBackend.GetEndpoint("http"));
```

### GPU Configuration

**Enable GPU in Aspire:**

Edit `src/GpuAzure.AppHost/AppHost.cs`:

```csharp
var javaBackend = builder.AddExecutable("java-backend", "mvn", ...)
    .WithEnvironment("GPU_LANGCHAIN4J_GPU_ENABLED", "true")  // Change to true
```

### CORS Configuration

**Java Backend (`ImageController.java`):**
```java
@CrossOrigin(origins = {"http://localhost:5000", "http://localhost:5001"})
```

**Blazor Server (`Program.cs`):**
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowBackend", policy =>
    {
        policy.WithOrigins("http://localhost:8080", "https://localhost:8080")
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});
```

---

## 🔍 Troubleshooting

### Aspire Won't Start

**Symptom:** `dotnet run` fails in AppHost

**Solutions:**
1. Verify .NET 10 SDK: `dotnet --version`
2. Install Aspire workload: `dotnet workload install aspire`
3. Check port availability (15000, 18888)
4. Update templates: `dotnet new install Aspire.ProjectTemplates@13.0.1`

### Blazor Can't Connect to Backend

**Symptom:** "Backend service is not responding"

**Solutions:**
1. Verify Java backend is running: `curl http://localhost:8080/api/langchain4j/health`
2. Check backend URL in `appsettings.json`
3. Verify CORS is enabled in Java backend
4. Check firewall settings

### DevContainer Build Fails

**Symptom:** Container fails to build

**Solutions:**
1. Update Docker Desktop to latest version
2. Increase Docker memory limit (8GB minimum)
3. Check internet connection (downloads .NET, Java)
4. Try: `docker system prune -a` (clean Docker cache)

### Models Not Found

**Symptom:** "Stable Diffusion model not found"

**Solutions:**
```bash
# Download models
./scripts/download-missing-models.sh

# Verify structure
ls -R models/stable-diffusion/

# Should see:
# models/stable-diffusion/
# ├── text_encoder/
# ├── unet/
# └── vae_decoder/
```

---

## 📊 Performance Considerations

### Blazor WebAssembly

**First Load:**
- Downloads ~2-3 MB of .NET runtime
- Cached for subsequent visits
- Can take 2-5 seconds on slow connections

**Optimizations:**
- Use compression (Brotli/Gzip)
- Enable assembly trimming
- Use AOT compilation for production

### Aspire Overhead

**Development:**
- Minimal overhead (~50-100 MB RAM)
- Dashboard adds ~30 MB
- Worth it for developer experience

**Production:**
- Use service defaults without dashboard
- Deploy services independently
- Aspire is for development orchestration

---

## 🚀 Deployment

### Azure Container Apps

**With Aspire Integration:**

The Aspire manifest can be deployed to Azure:

```bash
# Generate deployment manifest
cd src/GpuAzure.AppHost
dotnet run --publisher manifest --output-path ../aspire-manifest.json

# Deploy with Azure Developer CLI
azd init
azd up
```

### Separate Deployment

**Java Backend:**
```bash
# Use existing Docker deployment
docker build -t gpu-langchain4j-demo:latest .
# Push and deploy to Azure Container Apps
```

**Blazor Frontend:**
```bash
cd src/BlazorFrontend/BlazorFrontend
dotnet publish -c Release
# Deploy to Azure App Service or Static Web Apps
```

---

## 📚 Additional Resources

### Documentation
- [Blazor Frontend Guide](./docs/BLAZOR-FRONTEND.md)
- [Aspire Setup README](./src/README.md)
- [Main README](./README.md)
- [Setup Guide](./SETUP.md)

### External Links
- [.NET Aspire Documentation](https://learn.microsoft.com/dotnet/aspire/)
- [Blazor Documentation](https://learn.microsoft.com/aspnet/core/blazor/)
- [DevContainers Specification](https://containers.dev/)
- [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/)

---

## 🎓 Learning Path

**For .NET Developers:**
1. Start with Aspire orchestration
2. Explore Blazor frontend components
3. Understand service discovery
4. Review backend API integration

**For Java Developers:**
1. Start with backend API endpoints
2. Explore how Blazor consumes REST APIs
3. Understand CORS configuration
4. Review Aspire orchestration setup

**For Both:**
1. Use DevContainer for consistent environment
2. Explore Aspire Dashboard features
3. Monitor service interactions
4. Experiment with GPU/CPU modes

---

## ✅ Checklist for First Run

- [ ] .NET 10 SDK installed
- [ ] Java 21 JDK installed
- [ ] Maven installed
- [ ] Models downloaded (`./scripts/download-missing-models.sh`)
- [ ] ONNX Runtime Extensions built (`./scripts/download-ortextensions.sh`)
- [ ] Aspire workload installed (`dotnet workload install aspire`)
- [ ] Port 8080 available (Java backend)
- [ ] Port 5000/5001 available (Blazor frontend)
- [ ] Port 15000 available (Aspire Dashboard)
- [ ] (Optional) NVIDIA drivers for GPU support

**Once ready:**
```bash
cd src/GpuAzure.AppHost
dotnet run
```

Navigate to http://localhost:5000 and enjoy! 🎉

---

## 💡 Tips & Tricks

1. **Use Aspire Dashboard for Debugging**
   - View real-time logs from all services
   - Trace requests across service boundaries
   - Monitor resource usage

2. **Hot Reload in Development**
   ```bash
   # Blazor: Changes reload automatically
   dotnet watch run
   
   # Java: Use Spring DevTools
   mvn spring-boot:run
   ```

3. **DevContainer Persistence**
   - Models directory is mounted, not copied
   - Changes persist across container rebuilds
   - Use `.gitignore` to avoid committing models

4. **Keyboard Shortcuts**
   - `Ctrl+F5`: Start without debugging
   - `F5`: Start with debugging
   - `Ctrl+C`: Stop services

---

**Happy Coding! 🚀**
