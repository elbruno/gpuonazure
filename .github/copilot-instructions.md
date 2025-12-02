# GitHub Copilot Instructions

## Project Overview

**GPU-accelerated AI inference platform** combining Java Spring Boot with .NET Aspire orchestration:

- **Backend**: Java 21 + Spring Boot 3.2.5 + LangChain4j 0.34.0 + Oracle SD4J + ONNX Runtime 1.18.0
- **Frontend**: .NET 10 Blazor WebAssembly + JavaScript WebUI
- **Orchestration**: .NET Aspire 13 with service discovery
- **Deployment**: Azure Container Apps with GPU profiles (T4/A100), DevContainer support

### Core Capabilities

1. **Image Generation**: Stable Diffusion v1.5 via Oracle's SD4J (complete pipeline: CLIP tokenizer, U-Net, VAE decoder)
2. **Text Embeddings**: All-MiniLM-L6-v2 for semantic similarity (packaged with LangChain4j)
3. **GPU Acceleration**: CUDA 12.6 with ONNX Runtime (10-15x speedup)
4. **CPU Fallback**: Graceful degradation when GPU unavailable

## Architecture Deep Dive

### Service Composition (.NET Aspire)

Located in `src/GpuAzure.AppHost/AppHost.cs`:

- Java backend runs as **executable** (`mvn spring-boot:run`), not container, for faster inner loop
- Blazor frontend gets backend URL via **service discovery**: `services__java-backend__http__0`
- JavaScript WebUI served directly by Java backend at `http://localhost:8080`
- Default: GPU disabled (`GPU_LANGCHAIN4J_GPU_ENABLED=false`) - safe for laptops

### ONNX Model Loading (CRITICAL Pattern)

`src/main/java/com/azure/gpudemo/config/LangChain4jGpuConfiguration.java`:

```java
@Bean
public OrtEnvironment ortEnvironment() {
    return OrtEnvironment.getEnvironment(); // Singleton per JVM
}

@Bean
public OrtSession.SessionOptions ortSessionOptions() throws Exception {
    var options = new OrtSession.SessionOptions();
    if (gpuEnabled) {
        options.addCUDA(gpuDeviceId); // MUST be called before session creation
    }
    options.setInterOpNumThreads(4);
    options.setIntraOpNumThreads(4);
    return options;
}
```

**CRITICAL**: `OrtEnvironment` is a singleton - never create multiple instances or GPU will fail.

### Maven Dependency Management (CRITICAL)

From `pom.xml`:

```xml
<!-- CRITICAL: Exclude onnxruntime (CPU-only) to prevent conflict with onnxruntime_gpu -->
<dependency>
    <groupId>dev.langchain4j</groupId>
    <artifactId>langchain4j-embeddings-all-minilm-l6-v2</artifactId>
    <exclusions>
        <exclusion>
            <groupId>com.microsoft.onnxruntime</groupId>
            <artifactId>onnxruntime</artifactId>
        </exclusion>
    </exclusions>
</dependency>

<!-- Only include onnxruntime_gpu, NEVER both! -->
<dependency>
    <groupId>com.microsoft.onnxruntime</groupId>
    <artifactId>onnxruntime_gpu</artifactId>
    <version>1.18.0</version>
</dependency>
```

**Why**: LangChain4j dependencies pull in CPU-only `onnxruntime`. Having both causes "CUDA execution provider is not enabled" error at runtime.

### Image Generation via SD4J (Oracle)

`src/main/java/com/azure/gpudemo/service/SD4JImageGenerationService.java`:

- SD4J provides **complete** Stable Diffusion pipeline (no manual tokenization needed)
- Model directory structure (from `download-missing-models.sh`):
  ```
  models/stable-diffusion/
  ├── text_encoder/model.onnx    # CLIP tokenizer (492MB)
  ├── unet/model.onnx             # Diffusion model (3.4GB)
  └── vae_decoder/model.onnx      # VAE decoder (198MB)
  ```
- Initialize **lazily** on first use to avoid startup delays
- Thread pool sizing: 4 inter-op, 8 intra-op (optimal for SD)

### GPU Configuration Strategy

From `application.yml`:

```yaml
langchain4j:
  onnx:
    gpu:
      enabled: ${ENABLE_GPU:false} # Default FALSE (CPU-safe)
```

**Rationale**:

- Development: Run on CPU (laptops, DevContainers without GPU)
- Production: Set `ENABLE_GPU=true` in Azure Container Apps
- DevContainer: GPU auto-detected if nvidia-smi available (see `.devcontainer/post-create.sh`)

## Critical Workflows

### Local Development Commands

```bash
# Start with Aspire (recommended)
cd src/GpuAzure.AppHost && dotnet run

# Java backend only
mvn spring-boot:run

# Blazor frontend only
cd src/BlazorFrontend/BlazorFrontend && dotnet run

# Access Aspire Dashboard: http://localhost:15000
```

### Model Setup (First Time)

```bash
# Download SD models (~5.2GB total)
./scripts/download-missing-models.sh

# Build ONNX Runtime Extensions (for CLIP tokenizer)
./scripts/download-ortextensions.sh

# Verify structure
ls -R models/stable-diffusion/
# Must have: text_encoder/, unet/, vae_decoder/
```

### Docker Build Gotchas

From `Dockerfile`:

- Base image: `nvidia/cuda:12.6.0-cudnn-runtime-ubuntu24.04`
- **MUST** match ONNX Runtime CUDA version (12.6)
- Models NOT in image (5GB+ - mount at runtime)
- Health check required for Container Apps

## Project-Specific Patterns

### Java 21 Virtual Threads

`GpuLangchain4jDemoApplication.java`:

```java
@Bean(name = "imageGenerationExecutor")
public Executor imageGenerationExecutor() {
    return Executors.newVirtualThreadPerTaskExecutor(); // Java 21
}
```

Use for image generation (I/O-bound during model loading), not embeddings (CPU-bound).

### Blazor Service Discovery

`BlazorFrontend.Client/Services/GpuBackendService.cs`:

```csharp
public GpuBackendService(HttpClient httpClient, IConfiguration configuration)
{
    _httpClient = httpClient;
    // Aspire injects: "services__java-backend__http__0"
    var backendUrl = configuration["services:java-backend:http:0"]
                  ?? "http://localhost:8080";
    _httpClient.BaseAddress = new Uri(backendUrl);
}
```

**Never hardcode URLs** - always use Aspire service discovery keys.

### DevContainer GPU Handling

`.devcontainer/devcontainer.json`:

```json
"runArgs": [
  "--cap-add=SYS_PTRACE",
  "--security-opt=seccomp=unconfined",
  "--privileged"
]
// GPU auto-detected by VS Code - no --gpus=all needed
```

**Why no `--gpus=all`**: Causes startup failure on machines without GPU. VS Code auto-adds when available.

## Azure Deployment Essentials

### Container Apps GPU Profile Selection

```bash
# T4 GPU (16GB VRAM) - $0.526/hour
az containerapp create --workload-profile-name NC8as_T4_v3

# A100 GPU (80GB VRAM) - $3.672/hour
az containerapp create --workload-profile-name NC24ads_A100_v4
```

**Performance**: T4 generates 512x512 image in ~2.3s, A100 in ~0.8s

### Required Environment Variables

```bash
ENABLE_GPU=true                    # Enable CUDA
GPU_LANGCHAIN4J_MODEL_DIR=/app/models
JAVA_OPTS=-Xmx8g -XX:+UseZGC      # 8GB heap for models
SPRING_PROFILES_ACTIVE=production
```

### Model Storage Strategy

Models stored in Azure Blob Storage or mounted volume (NOT in container image):

```bash
# Mount Azure File Share
az containerapp create \
  --azure-file-account-name gpumodels \
  --azure-file-account-key $KEY \
  --azure-file-share-name models \
  --azure-file-volume-name models \
  --volume-mount models:/app/models
```

## Common Gotchas

### 1. "CUDA execution provider is not enabled"

**Cause**: Both `onnxruntime` and `onnxruntime_gpu` in classpath
**Fix**: Check `pom.xml` exclusions (see Maven section above)

### 2. Model Directory Structure Wrong

SD4J expects:

```
models/stable-diffusion/
├── text_encoder/model.onnx    # NOT model/stable-diffusion/text_encoder.onnx
├── unet/model.onnx
└── vae_decoder/model.onnx
```

Run `download-missing-models.sh` to fix structure.

### 3. OutOfMemoryError During Image Generation

**Cause**: Insufficient heap (SD requires ~6GB in CPU mode)
**Fix**: Set `JAVA_OPTS=-Xmx8g` or reduce `num_inference_steps` in `application.yml`

### 4. Aspire Can't Find Java Backend

**Symptom**: Blazor shows "Backend unavailable"
**Cause**: Maven not in PATH or wrong working directory
**Fix**: Check `AppHost.cs` - `workingDirectory: "../.."` must point to `pom.xml` location

### 5. DevContainer Build Takes 16+ Minutes

**Normal**: First build installs:

- Java 21 JDK
- .NET 10 SDK
- CUDA Toolkit (2.2GB)
- Azure CLI
  Subsequent rebuilds use Docker layer cache (~2 minutes).

## Testing Patterns

### Health Check Endpoint

```bash
curl http://localhost:8080/api/langchain4j/health
# Returns: {"gpuAvailable": false, "modelsLoaded": true, "stableDiffusionReady": true}
```

### Image Generation Test

```bash
curl -X POST http://localhost:8080/api/langchain4j/image \
  -H "Content-Type: application/json" \
  -d '{"prompt":"sunset over mountains","style":"CLASSIC"}' \
  --output test.png
```

## Documentation Structure

**CRITICAL**: Place all docs in `docs/` folder except `README.md` and `LICENSE`.

Use descriptive UPPERCASE filenames:

- `HOW-TO-RUN-DEVCONTAINER.md` ✓
- `devcontainer-guide.md` ✗

Cross-reference: `[Architecture](./docs/ARCHITECTURE.md)`

## IDE Configuration

### VS Code Extensions (in DevContainer)

- `vscjava.vscode-java-pack` - Java LSP
- `ms-dotnettools.csdevkit` - C# LSP
- `ms-azuretools.vscode-azurecontainerapps` - Azure deployment

### Debugging

- Java: `mvn spring-boot:run` with remote debugger on port 5005
- Blazor: `F5` in VS Code (launch.json configured)
- Aspire: Dashboard logs at `http://localhost:15000`

## Git Workflow

Conventional commits:

- `feat:` - New feature (e.g., `feat: add NSFW filter support`)
- `fix:` - Bug fix (e.g., `fix: resolve GPU memory leak`)
- `docs:` - Documentation only
- `refactor:` - Code restructure without behavior change

Branch naming:

- `feature/description`
- `bugfix/description`
- `docs/description`

## Performance Benchmarks

### Image Generation (512x512, 40 steps)

- **CPU mode**: ~45 seconds
- **T4 GPU**: ~2.3 seconds (20x faster)
- **A100 GPU**: ~0.8 seconds (56x faster)

### Text Embeddings (batch of 10)

- **CPU mode**: ~100ms
- **GPU mode**: ~25ms (4x faster)

---

**Last Updated**: December 2, 2025  
**Project Version**: 1.0.0  
**Active Branch**: copilot/add-devcontainer-support  
**Stack**: Java 21 + Spring Boot 3.2.5 + LangChain4j 0.34.0 + .NET 10 + Aspire 13
