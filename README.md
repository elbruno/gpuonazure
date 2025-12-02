# GPU-Accelerated AI Platform with .NET Aspire Orchestration

![Java](https://img.shields.io/badge/Java-21-orange?style=flat-square)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-3.2.5-green?style=flat-square)
![LangChain4j](https://img.shields.io/badge/LangChain4j-0.34.0-blue?style=flat-square)
![ONNX Runtime](https://img.shields.io/badge/ONNX%20Runtime-1.18.0-purple?style=flat-square)
![CUDA](https://img.shields.io/badge/CUDA-12.6-brightgreen?style=flat-square)
![.NET](https://img.shields.io/badge/.NET-10-blueviolet?style=flat-square)
![Blazor](https://img.shields.io/badge/Blazor-WebAssembly-512BD4?style=flat-square)
![Aspire](https://img.shields.io/badge/Aspire-13-00ADD8?style=flat-square)

A production-ready demonstration of GPU-accelerated AI inference using **LangChain4j** with **ONNX Runtime** and **CUDA**, featuring a modern **Blazor WebAssembly** frontend orchestrated by **.NET Aspire 13**, deployable to **Azure Container Apps** with GPU support.

## 🚀 Features

- **GPU-Accelerated Inference**: CUDA 12.6 with ONNX Runtime for high-performance AI
- **Stable Diffusion Image Generation**: Powered by Oracle's **SD4J** (Stable Diffusion for Java) 🎉
  - Complete CLIP tokenizer, U-Net, VAE decoder, and scheduler implementation
  - Multiple scheduler algorithms (LMS, Euler Ancestral)
  - Optional NSFW safety checker
  - Generate high-quality cartoon-style images from text prompts
- **Text Embeddings**: Semantic similarity with All-MiniLM-L6-v2 model via LangChain4j
- **Modern Stack**: 
  - Backend: Java 21, Spring Boot 3.2.5, LangChain4j 0.34.0, SD4J
  - Frontend: .NET 10, Blazor WebAssembly
  - Orchestration: .NET Aspire 13
- **Blazor WebAssembly UI**: Modern, interactive frontend with real-time updates
- **.NET Aspire Orchestration**: Service discovery, health checks, distributed tracing
- **DevContainer Support**: Ready-to-use development environment with VS Code/GitHub Codespaces
- **Cloud-Ready**: Containerized with Docker, deployable to Azure Container Apps
- **Production-Grade**: Health checks, graceful shutdown, monitoring endpoints

## 🎨 Example Output

![Image Generator Example](images/image%20generator%20example.jpeg)

## 📖 Complete Setup Guide

**👉 See [SETUP.md](SETUP.md) for detailed step-by-step installation instructions, including:**
- Prerequisites and build tools installation
- Model downloads and directory structure
- ONNX Runtime Extensions build process
- Local development and Azure deployment
- Comprehensive troubleshooting guide

## 📋 Table of Contents

- [Architecture](#architecture)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Running with Aspire](#running-with-aspire)
- [DevContainer Setup](#devcontainer-setup)
- [Local Development](#local-development)
- [Azure Deployment](#azure-deployment)
- [API Documentation](#api-documentation)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Performance](#performance)
- [Contributing](#contributing)

## 🏗️ Architecture

### Modern Microservices Architecture with .NET Aspire

```
┌─────────────────────────────────────────────────────────────────┐
│                     .NET Aspire Dashboard                       │
│        (Service Discovery, Health Checks, Telemetry)            │
└────────────────┬──────────────────────────┬─────────────────────┘
                 │                          │
    ┌────────────▼──────────┐  ┌───────────▼────────────┐
    │   Java Backend        │  │   Blazor Frontend      │
    │   Spring Boot 3.2.5   │  │   .NET 10 WebAssembly  │
    │   Port: 8080          │◄─┤   Port: 5000/5001      │
    └────────────┬───────────┘  └────────────────────────┘
                 │
    ┌────────────▼──────────────────────────────────────┐
    │           LangChain4j GPU Service                 │
    │        (LangChain4jGpuService.java)               │
    └────────────┬──────────────────────────────────────┘
                 │
    ┌────────────▼──────────────────────────────────────┐
    │           ONNX Runtime (GPU)                      │
    │    • Stable Diffusion v1.5 (Image Gen)            │
    │    • All-MiniLM-L6-v2 (Embeddings)                │
    └────────────┬──────────────────────────────────────┘
                 │
    ┌────────────▼──────────────────────────────────────┐
    │           NVIDIA CUDA 12.6                        │
    │        (GPU Acceleration Layer)                   │
    └───────────────────────────────────────────────────┘
```

## 🔧 Prerequisites

### Local Development
- **Java 21 LTS** (with `--enable-preview` flag)
- **Maven 3.9+**
- **.NET 10 SDK** ([Download](https://dotnet.microsoft.com/download/dotnet/10.0))
- **.NET Aspire 13 CLI** (install native executable: `curl -sSL https://aspire.dev/install.sh | bash`)
- **NVIDIA GPU** with CUDA 12.6+ support (optional, for GPU acceleration)
- **CUDA Toolkit 12.6** (optional)
- **Docker** (optional, for containerization)
- **Git**

### Azure Deployment
- **Azure CLI** ([Install](https://docs.microsoft.com/cli/azure/install-azure-cli))
- **Azure Subscription** with GPU quota enabled
- **Docker** for building images

## 🚀 Quick Start

> **📘 For detailed setup instructions, see [SETUP.md](SETUP.md)**

### Option A: Using .NET Aspire (Recommended) ⚡

Run the entire application stack with one command:

```bash
# From repository root
cd src/GpuAzure.AppHost
dotnet run
```

This will:
- ✅ Start Java Spring Boot backend (port 8080)
- ✅ Start Blazor WebAssembly frontend (port 5000/5001)
- ✅ Open Aspire Dashboard with service monitoring (port 15000)
- ✅ Configure service discovery automatically

**Access the application:**
- **Blazor Frontend**: http://localhost:5000
- **Java Backend API**: http://localhost:8080
- **Aspire Dashboard**: http://localhost:15000

### Option B: Manual Setup (Traditional)

#### 1. Clone Repository

```bash
git clone https://github.com/your-org/gpuonazure.git
cd gpuonazure
```

#### 2. Install Build Tools

```bash
# Linux
sudo apt-get update && sudo apt-get install -y cmake build-essential

# macOS
brew install cmake
```

#### 3. Download Models

```bash
./scripts/download-missing-models.sh
```

Downloads Stable Diffusion v1.5 models (~5.2 GB):
- Text Encoder, U-Net, VAE Decoder

#### 4. Build ONNX Runtime Extensions

```bash
./scripts/download-ortextensions.sh
```

Builds `libortextensions.so` (~3 MB, required for CLIP tokenizer).

#### 5. Run Java Backend

```bash
mvn spring-boot:run
```

#### 6. Run Blazor Frontend (in separate terminal)

```bash
cd src/BlazorFrontend/BlazorFrontend
dotnet run
```

#### 7. Access Applications

- **Blazor Frontend**: http://localhost:5000
- **Java Backend API**: http://localhost:8080

**🎨 Generate your first image!**

## 🐳 DevContainer Setup

This project includes a complete DevContainer configuration for VS Code and GitHub Codespaces with all required tools pre-installed.

### Using VS Code

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. Install [VS Code Dev Containers extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)
3. Open the project in VS Code
4. Click "Reopen in Container" when prompted

### Using GitHub Codespaces

1. Click "Code" → "Codespaces" → "Create codespace on main"
2. Wait for the environment to build (~5 minutes first time)
3. Everything is pre-configured and ready to use!

### What's Included

The DevContainer includes:
- ✅ Java 21 JDK with Maven
- ✅ .NET 10 SDK with Aspire workload
- ✅ CUDA Toolkit (for GPU support on compatible hosts)
- ✅ Azure CLI
- ✅ Docker-in-Docker
- ✅ All VS Code extensions (Java, C#, Blazor, Docker, Azure)
- ✅ Pre-configured debugging and tasks

**Note**: GPU support requires a host with NVIDIA drivers. CPU mode works everywhere.

## 🌟 Running with .NET Aspire

.NET Aspire 13 provides orchestration, service discovery, and observability for the entire application.

### Start with Aspire Dashboard

```bash
cd src/GpuAzure.AppHost
dotnet run
```

This will automatically:
1. Start the Java Spring Boot backend on port 8080
2. Start the Blazor frontend on port 5000/5001
3. Configure service discovery between them
4. Open the Aspire Dashboard at http://localhost:15000

### Aspire Dashboard Features

The dashboard provides:
- **Service Status**: Real-time health of all services
- **Logs**: Aggregated logs from Java and .NET applications
- **Metrics**: Performance metrics and resource usage
- **Traces**: Distributed tracing across service boundaries
- **Environment**: View and modify environment variables

### Service Discovery

Services automatically discover each other:

```csharp
// In AppHost.cs
var javaBackend = builder.AddExecutable("java-backend", "mvn", ...)
    .WithHttpEndpoint(port: 8080, name: "http");

var blazorFrontend = builder.AddProject<Projects.BlazorFrontend>("blazor-frontend")
    .WithEnvironment("BackendUrl", javaBackend.GetEndpoint("http"));
```

No hardcoded URLs needed!

### Benefits of Aspire

- 🚀 **Fast Inner Loop**: Start entire stack with one command
- 🔍 **Observability**: Built-in telemetry and monitoring
- 🔌 **Service Discovery**: Automatic endpoint resolution
- 🏥 **Health Checks**: Automated health monitoring
- 📊 **Unified Dashboard**: Single view of all services

**See [src/README.md](src/README.md) for complete Aspire documentation.**

## 🔨 Local Development

> **📘 For troubleshooting and advanced configuration, see [SETUP.md](SETUP.md)**

### Running with Maven

```bash
mvn spring-boot:run
```

### Running with Docker

```bash
# Build image
docker build -t gpu-langchain4j-demo:latest .

# Run with GPU (if CUDA available)
docker run --gpus all -p 8080:8080 \
  -v $(pwd)/models:/app/models \
  gpu-langchain4j-demo:latest
```

### Configuration

Edit `src/main/resources/application.yml`:

```yaml
gpu:
  langchain4j:
    gpu:
      enabled: true  # Set to false for CPU-only mode
      device-id: 0
    model:
      dir: ./models
```

### Health Check

```bash
curl http://localhost:8080/actuator/health
```

**Expected Response:**
```json
{
  "status": "UP",
  "gpuAvailable": false,
  "modelsLoaded": true,
  "stableDiffusion": "Ready (SD4J)"
}
```

## ☁️ Azure Deployment

### 🎯 Quick Deploy (Automated)

Deploy to Azure Container Apps with GPU in one command:

```bash
./deploy-azure-aca.sh
```

This script will:
- ✅ Create Azure Container Registry
- ✅ Build and push Docker image (~5GB)
- ✅ Create Container Apps Environment with GPU
- ✅ Deploy application
- ✅ Output application URL

**Total time**: 15-20 minutes

### ⚙️ Configuration

Customize deployment with environment variables:

```bash
export RESOURCE_GROUP="gpu-demo-rg"
export LOCATION="eastus"
export ACR_NAME="gpudemoregistry"
export GPU_PROFILE="NC8as_T4_v3"  # or NC24ads_A100_v4

./deploy-azure-aca.sh
```

**GPU Options**:
- `NC8as_T4_v3` - NVIDIA T4 (16GB), $0.526/hour
- `NC24ads_A100_v4` - NVIDIA A100 (80GB), $3.672/hour

### 📖 Complete Guide

For detailed instructions, see:
- **[AZURE-DEPLOYMENT-GUIDE.md](./AZURE-DEPLOYMENT-GUIDE.md)** - Complete deployment guide
- **[AZURE-QUICK-REFERENCE.md](./AZURE-QUICK-REFERENCE.md)** - Quick reference commands

### 🧪 Test Deployment

```bash
# Get application URL
APP_URL=$(az containerapp show --name gpu-langchain4j-demo --resource-group gpu-demo-rg --query properties.configuration.ingress.fqdn -o tsv)

# Health check
curl https://$APP_URL/actuator/health

# Generate test image
curl -X POST https://$APP_URL/api/langchain4j/image \
  -H "Content-Type: application/json" \
  -d '{"prompt": "sunset over mountains", "style": "CLASSIC"}' \
  --output test-azure.png
```

### 🗑️ Cleanup

```bash
az group delete --name gpu-demo-rg --yes
```

## 📚 API Documentation

### Base URL

```
http://localhost:8080/api/langchain4j
```

### Endpoints

#### 1. Generate Image

**POST** `/image`

Generate a cartoon-style image from text prompt using Stable Diffusion.

**Request:**
```json
{
  "prompt": "A friendly robot helping with Azure deployment",
  "style": "HAPPY"
}
```

**Response:** `image/png` (binary)

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/langchain4j/image \
  -H "Content-Type: application/json" \
  -d '{"prompt":"A friendly robot at a computer","style":"CLASSIC"}' \
  --output generated-image.png
```

#### 2. Compare Embeddings

**POST** `/embeddings`

Compare semantic similarity between two text snippets.

**Request:**
```json
{
  "text1": "Azure Container Apps",
  "text2": "Cloud container platform"
}
```

**Response:**
```json
{
  "text1": "Azure Container Apps",
  "text2": "Cloud container platform",
  "similarity": 0.8532,
  "processingTimeMs": 45
}
```

**cURL Example:**
```bash
curl -X POST http://localhost:8080/api/langchain4j/embeddings \
  -H "Content-Type: application/json" \
  -d '{
    "text1": "GPU acceleration",
    "text2": "CUDA processing"
  }'
```

#### 3. Health Check

**GET** `/health`

Get system health and GPU status.

**Response:**
```json
{
  "status": "UP",
  "gpuAvailable": true,
  "modelsLoaded": true,
  "timestamp": "2025-09-29T12:00:00Z"
}
```

#### 4. List Models

**GET** `/models`

Get information about loaded models.

**Response:**
```json
{
  "models": {
    "stableDiffusion": {
      "name": "Stable Diffusion v1.5",
      "path": "/app/models/stable-diffusion/model.onnx",
      "available": true,
      "sizeBytes": 3442332160
    },
    "allMiniLmL6V2": {
      "name": "All-MiniLM-L6-v2",
      "path": "/app/models/all-MiniLM-L6-v2/model.onnx",
      "available": true,
      "sizeBytes": 90000000
    }
  },
  "gpuAvailable": true,
  "modelsLoaded": true
}
```

## ⚙️ Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `GPU_LANGCHAIN4J_GPU_ENABLED` | `true` | Enable GPU acceleration |
| `GPU_LANGCHAIN4J_GPU_DEVICE_ID` | `0` | CUDA device ID |
| `GPU_LANGCHAIN4J_MODEL_DIR` | `./models` | Model directory path |
| `JAVA_OPTS` | `-Xmx8g -XX:+UseZGC` | JVM options |
| `SPRING_PROFILES_ACTIVE` | `default` | Spring profile |

### GPU Configuration

```yaml
gpu:
  langchain4j:
    gpu:
      enabled: true
      device-id: 0
      inter-op-threads: 4
      intra-op-threads: 8
```

### Model Configuration

```yaml
gpu:
  langchain4j:
    model:
      dir: /app/models
      download:
        enabled: true
        azure-storage-account: mystorageaccount
        azure-storage-container: onnx-models
```

## 🐛 Troubleshooting

> **📘 For comprehensive troubleshooting, see [SETUP.md](SETUP.md#troubleshooting)**

### Common Issues

#### 1. libortextensions.so not found

**Error:** `Failed to load library ./libortextensions.so`

**Solution:**
```bash
# Build the library (takes ~10 minutes)
./download-ortextensions.sh
```

#### 2. Models Not Found

**Error:** `Stable Diffusion model not found`

**Solution:**
```bash
# Download models and organize structure
./download-missing-models.sh

# Verify structure
ls -R models/stable-diffusion/
```

#### 3. Out of Memory

**Error:** `OutOfMemoryError` during generation

**Solution:**
```bash
# Increase JVM heap (requires 6-8GB for CPU mode)
export JAVA_OPTS="-Xmx8g -XX:+UseZGC"
mvn spring-boot:run
```

#### 4. Slow Image Generation

**CPU Mode Expected Times:**
- First generation: ~60 seconds (model loading)
- Subsequent: ~30-45 seconds per image

**Optimization:**
```yaml
# Reduce inference steps for faster generation
gpu:
  langchain4j:
    inference-steps: 20  # Default 40
```

### Logs

```bash
# Application logs
mvn spring-boot:run --debug

# Azure Container Apps logs
az containerapp logs show --name gpu-langchain4j-app \
  --resource-group gpu-langchain4j-rg --follow
```

## 📊 Performance

### Benchmarks (T4 GPU)

| Operation | Average Time | Throughput |
|-----------|-------------|------------|
| Image Generation (512x512) | 2.3s | ~0.43 img/s |
| Text Embedding (single) | 15ms | ~66 req/s |
| Text Embedding (batch of 10) | 45ms | ~222 req/s |

### Benchmarks (A100 GPU)

| Operation | Average Time | Throughput |
|-----------|-------------|------------|
| Image Generation (512x512) | 0.8s | ~1.25 img/s |
| Text Embedding (single) | 8ms | ~125 req/s |
| Text Embedding (batch of 10) | 25ms | ~400 req/s |

## 🔒 Security

- **HTTPS**: Enabled by default in Azure Container Apps
- **CORS**: Configured for web UI access
- **Secrets**: Use Azure Key Vault for sensitive configuration
- **Authentication**: Add Azure AD authentication for production

## 📝 License

This project is licensed under the MIT License - see [LICENSE](LICENSE) file.

## 🤝 Contributing

Contributions welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) first.

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open a Pull Request

## 📧 Support

- **Issues**: [GitHub Issues](https://github.com/your-org/gpuonazure/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/gpuonazure/discussions)
- **Email**: support@example.com

## 🙏 Acknowledgments

- [LangChain4j](https://github.com/langchain4j/langchain4j) - Java AI framework
- [ONNX Runtime](https://onnxruntime.ai/) - Cross-platform inference engine
- [Stable Diffusion](https://stability.ai/) - Image generation model
- [Sentence Transformers](https://www.sbert.net/) - Text embeddings

## 🗺️ Roadmap

- [ ] Add more ONNX models (BERT, GPT, etc.)
- [ ] Implement model quantization for faster inference
- [ ] Add batch processing endpoints
- [ ] Support for multi-GPU deployment
- [ ] Implement caching layer with Redis
- [ ] Add Prometheus metrics export
- [ ] Create Helm chart for Kubernetes deployment

---

**Made with ❤️ using Java 21, Spring Boot, LangChain4j, and Azure**
