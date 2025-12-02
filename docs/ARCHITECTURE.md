# Architecture Documentation

This document provides a comprehensive overview of the GPU-accelerated AI platform architecture, including all components, interactions, and deployment patterns.

## Table of Contents

- [System Overview](#system-overview)
- [Architecture Diagram](#architecture-diagram)
- [Component Details](#component-details)
- [Data Flow](#data-flow)
- [Deployment Architectures](#deployment-architectures)
- [Technology Stack](#technology-stack)
- [Integration Patterns](#integration-patterns)

---

## System Overview

The GPU-accelerated AI platform is a modern microservices application that combines:
- **Java Spring Boot** backend for AI inference using LangChain4j and ONNX Runtime
- **Blazor WebAssembly** frontend for modern interactive UI
- **JavaScript/HTML** frontend for lightweight browser interface
- **.NET Aspire** orchestration for service discovery and observability
- **NVIDIA CUDA** for GPU-accelerated inference

The platform generates AI images using Stable Diffusion v1.5 and computes text embeddings using All-MiniLM-L6-v2, all accelerated by GPU when available.

---

## Architecture Diagram

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                         User Interface Layer                         │
├──────────────────────────┬──────────────────────────────────────────┤
│   Blazor WebAssembly     │         JavaScript WebUI                 │
│   (.NET 10 + WASM)       │      (HTML/CSS/JavaScript)               │
│   Port: 5000/5001        │         Port: 8080                       │
└──────────────┬───────────┴────────────────┬─────────────────────────┘
               │                            │
               │ HTTP REST API              │ HTTP REST API
               │                            │
               └────────────┬───────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────────┐
│                    .NET Aspire Dashboard                             │
│         Service Discovery • Health Checks • Telemetry                │
│                      Port: 15000 / 18888                             │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────────┐
│                  Java Spring Boot Backend                            │
│                  Port: 8080 (REST API + Static Files)                │
├─────────────────────────────────────────────────────────────────────┤
│  Controllers:                                                        │
│  • ImageController       - /api/langchain4j/image                    │
│  • EmbeddingsController  - /api/langchain4j/embeddings               │
│  • HealthController      - /api/langchain4j/health                   │
│  • MetricsController     - /api/langchain4j/metrics                  │
├─────────────────────────────────────────────────────────────────────┤
│  Services:                                                           │
│  • LangChain4jGpuService       - AI inference coordination           │
│  • SD4JImageGenerationService  - Stable Diffusion generation         │
│  • ModelManagementService      - Model loading and caching           │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────────┐
│                        LangChain4j Layer                             │
├─────────────────────────────────────────────────────────────────────┤
│  • EmbeddingModel (All-MiniLM-L6-v2)                                 │
│  • SD4J (Stable Diffusion for Java)                                  │
│    - TextEmbedder (CLIP tokenizer)                                   │
│    - UNet (Diffusion model)                                          │
│    - VAEDecoder (Image decoder)                                      │
│    - Schedulers (LMS, Euler Ancestral)                               │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────────┐
│                      ONNX Runtime 1.18.0                             │
├─────────────────────────────────────────────────────────────────────┤
│  Execution Providers:                                                │
│  • CUDA Execution Provider (GPU)                                     │
│  • CPU Execution Provider (Fallback)                                 │
│                                                                       │
│  Models:                                                             │
│  • stable-diffusion/unet/model.onnx                                  │
│  • stable-diffusion/vae_decoder/model.onnx                           │
│  • stable-diffusion/text_encoder/model.onnx                          │
│  • all-MiniLM-L6-v2/model.onnx                                       │
│                                                                       │
│  Libraries:                                                          │
│  • libortextensions.so (CLIP tokenizer)                              │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────────┐
│                       NVIDIA CUDA 12.6                               │
├─────────────────────────────────────────────────────────────────────┤
│  • cuDNN 8.9.7 (Deep Learning Primitives)                            │
│  • CUDA Kernels for GPU Acceleration                                 │
│  • Memory Management (Unified Memory, Streams)                       │
└───────────────────────────┬─────────────────────────────────────────┘
                            │
┌───────────────────────────▼─────────────────────────────────────────┐
│                    NVIDIA GPU Hardware                               │
│              (T4, A100, or compatible CUDA 12+ GPU)                  │
└─────────────────────────────────────────────────────────────────────┘
```

### Service Interaction Diagram

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│   Blazor     │         │  JavaScript  │         │   Aspire     │
│   Frontend   │         │    WebUI     │         │  Dashboard   │
└──────┬───────┘         └──────┬───────┘         └──────┬───────┘
       │                        │                        │
       │ HTTP GET /             │ HTTP GET /             │ Service
       │ HTTP POST /api         │ HTTP POST /api         │ Discovery
       │                        │                        │
       └────────────────────────┼────────────────────────┘
                                │
                ┌───────────────▼────────────────┐
                │   Java Spring Boot Backend     │
                │   (Port 8080)                  │
                │                                │
                │  Static Files: /               │
                │  REST APIs: /api/langchain4j   │
                └───────────────┬────────────────┘
                                │
                    ┌───────────┴───────────┐
                    │                       │
            ┌───────▼────────┐     ┌───────▼────────┐
            │  LangChain4j   │     │     SD4J       │
            │  Embeddings    │     │ Image Gen      │
            └───────┬────────┘     └───────┬────────┘
                    │                      │
            ┌───────▼──────────────────────▼────────┐
            │        ONNX Runtime                   │
            │    CPU Provider | CUDA Provider       │
            └───────┬──────────────────┬────────────┘
                    │                  │
            ┌───────▼────────┐  ┌──────▼───────────┐
            │   CPU Cores    │  │  NVIDIA GPU      │
            │   (Fallback)   │  │  (Accelerated)   │
            └────────────────┘  └──────────────────┘
```

---

## Component Details

### 1. Frontend Layer

#### Blazor WebAssembly Frontend

**Technology:** .NET 10, Blazor WebAssembly, C#

**Components:**
- `ImageGenerator.razor`: Image generation interface with prompt input, style selection
- `Embeddings.razor`: Text similarity comparison with visual scoring
- `SystemMetrics.razor`: Real-time health and metrics dashboard
- `Home.razor`: Landing page with navigation and overview

**Service Layer:**
- `GpuBackendService.cs`: HTTP client for Java backend APIs
  - `GenerateImageAsync()`: POST /api/langchain4j/image
  - `CompareEmbeddingsAsync()`: POST /api/langchain4j/embeddings
  - `GetMetricsAsync()`: GET /api/langchain4j/metrics
  - `IsHealthyAsync()`: GET /api/langchain4j/health

**Configuration:**
- Service discovery via Aspire: `services__java-backend__http__0`
- Fallback configuration: `appsettings.json` BackendUrl
- CORS enabled for cross-origin requests

**Ports:**
- HTTP: 5000
- HTTPS: 5001

#### JavaScript WebUI

**Technology:** HTML5, CSS3, Vanilla JavaScript

**Files:**
- `index.html`: Main UI with image generation form
- `app.js`: API calls and UI interactions
- `styles.css`: Custom styling

**Features:**
- Lightweight, no build process required
- Direct API calls to Java backend
- Real-time metrics display
- Image generation with progress tracking

**Served by:** Java Spring Boot static file handler

**URL:** http://localhost:8080/

### 2. Orchestration Layer

#### .NET Aspire 13

**Technology:** .NET 10, Aspire Hosting

**Components:**
- `GpuAzure.AppHost`: Orchestration host project
- `GpuAzure.ServiceDefaults`: Shared configuration (health checks, telemetry)

**Features:**
- **Service Discovery:** Automatic endpoint resolution
- **Health Checks:** Built-in health monitoring for all services
- **Telemetry:** Distributed tracing with OpenTelemetry
- **Logging:** Centralized log aggregation
- **Metrics:** Performance metrics collection
- **Dashboard:** Web UI for monitoring (ports 15000/18888)

**Configuration:**
```csharp
var javaBackend = builder.AddExecutable("java-backend", "mvn", ...)
    .WithHttpEndpoint(port: 8080, name: "http");

var blazorFrontend = builder.AddProject<Projects.BlazorFrontend>("blazor-frontend")
    .WithEnvironment("services__java-backend__http__0", javaBackend.GetEndpoint("http"));
```

**Benefits:**
- Single command startup: `dotnet run`
- No hardcoded URLs
- Automatic service lifecycle management
- Production-ready observability

### 3. Backend Layer

#### Java Spring Boot Backend

**Technology:** Java 21, Spring Boot 3.2.5, Maven

**Controllers:**

1. **ImageController** (`/api/langchain4j`)
   - `POST /image`: Generate image from prompt
   - `POST /embeddings`: Compare text embeddings
   - `GET /metrics`: System metrics and health
   - `GET /health`: Simple health check

**Services:**

1. **LangChain4jGpuService**
   - Coordinates AI inference operations
   - Manages ONNX session lifecycle
   - Handles GPU/CPU fallback logic

2. **SD4JImageGenerationService**
   - Stable Diffusion image generation
   - CLIP tokenization
   - U-Net diffusion
   - VAE decoding
   - Scheduler integration (LMS, Euler Ancestral)

3. **ModelManagementService**
   - Model loading and caching
   - Path resolution
   - Model health checks

**Configuration:**
- `application.yml`: Service configuration
- Environment variables: GPU settings, model paths
- CORS configuration for frontend access

**Static File Serving:**
- JavaScript WebUI files served from `src/main/resources/static/`

### 4. AI Inference Layer

#### LangChain4j Integration

**Technology:** LangChain4j 0.34.0

**Components:**

1. **Embedding Model (All-MiniLM-L6-v2)**
   - Text to vector embeddings (384 dimensions)
   - Cosine similarity comparison
   - Used for semantic text analysis

2. **SD4J (Stable Diffusion for Java)**
   - Oracle's Java implementation of Stable Diffusion
   - Components:
     - **TextEmbedder**: CLIP tokenizer for prompt encoding
     - **UNet**: Core diffusion model for iterative denoising
     - **VAEDecoder**: Converts latent space to RGB images
     - **Schedulers**: Control denoising process
       - LMS (Linear Multistep)
       - Euler Ancestral

**Model Format:** ONNX (Open Neural Network Exchange)

**Inference Flow:**
```
Text Prompt → CLIP Tokenizer → Text Embeddings
                                      ↓
Random Noise + Text Embeddings → UNet (50 steps)
                                      ↓
                           Latent Representation
                                      ↓
                              VAE Decoder
                                      ↓
                            RGB Image (512x512)
```

### 5. Runtime Layer

#### ONNX Runtime 1.18.0

**Execution Providers:**
1. **CUDA Execution Provider** (Primary, GPU)
   - CUDA 12.6 compatible
   - cuDNN 8.9.7 required
   - GPU memory management
   - Kernel optimization

2. **CPU Execution Provider** (Fallback)
   - Multi-threaded execution
   - SIMD optimizations
   - Used when GPU unavailable

**Configuration:**
```yaml
onnx:
  gpu:
    enabled: true
    device-id: 0
  runtime:
    execution-providers: [cuda, cpu]
    cuda:
      gpu-mem-limit: 8589934592  # 8GB
      arena-extend-strategy: kNextPowerOfTwo
```

**Models Loaded:**
- `stable-diffusion/text_encoder/model.onnx` (~500 MB)
- `stable-diffusion/unet/model.onnx` (~3.5 GB)
- `stable-diffusion/vae_decoder/model.onnx` (~200 MB)
- `all-MiniLM-L6-v2/model.onnx` (~90 MB)

**Extensions:**
- `libortextensions.so`: CLIP tokenizer implementation

### 6. GPU Layer

#### NVIDIA CUDA 12.6

**Components:**
- **CUDA Runtime:** GPU kernel execution
- **cuDNN 8.9.7:** Deep learning primitives
- **Memory Management:** Unified memory, streams, events

**GPU Workloads:**
- Matrix multiplications (UNet, VAE)
- Convolutions (UNet layers)
- Attention mechanisms (CLIP, UNet)
- Tensor operations (element-wise ops)

**Supported GPUs:**
- NVIDIA T4 (16 GB VRAM)
- NVIDIA A100 (80 GB VRAM)
- Any CUDA Compute Capability 7.0+ GPU

**Performance:**
- **T4 GPU:** ~2-3 seconds per 512x512 image
- **A100 GPU:** ~0.8-1 second per 512x512 image
- **CPU (16 cores):** ~30-60 seconds per 512x512 image

---

## Data Flow

### Image Generation Flow

```
1. User Input (Frontend)
   ├─ Prompt: "A friendly robot"
   ├─ Style: "CLASSIC"
   └─ Parameters: Width=512, Height=512, Steps=50

2. HTTP Request
   POST /api/langchain4j/image
   Content-Type: application/json
   Body: {"prompt": "A friendly robot", "style": "CLASSIC"}

3. Java Backend (ImageController)
   ├─ Validate input
   ├─ Apply style modifiers
   └─ Call SD4JImageGenerationService

4. SD4J Processing
   ├─ CLIP Tokenizer: Text → Token IDs
   ├─ Text Encoder: Token IDs → Text Embeddings (77x768)
   ├─ Initialize Latent: Random noise (4x64x64)
   └─ Iterative Denoising Loop (50 steps):
       ├─ UNet Forward Pass: Latent + Text → Noise Prediction
       ├─ Scheduler: Apply denoising step
       └─ Update Latent

5. VAE Decoding
   └─ Latent (4x64x64) → RGB Image (3x512x512)

6. Post-Processing
   ├─ Denormalize pixel values
   ├─ Convert to PNG format
   └─ Return byte array

7. HTTP Response
   Content-Type: image/png
   Body: <PNG image bytes>

8. Frontend Display
   └─ Render image in <img> tag
```

### Text Embeddings Flow

```
1. User Input (Frontend)
   ├─ Text1: "GPU acceleration"
   └─ Text2: "CUDA processing"

2. HTTP Request
   POST /api/langchain4j/embeddings
   Body: {"text1": "GPU acceleration", "text2": "CUDA processing"}

3. Java Backend (ImageController)
   └─ Call LangChain4jGpuService.compareEmbeddings()

4. Embedding Generation
   ├─ Text1 → Tokenize → Embed → Vector1 (384 dims)
   └─ Text2 → Tokenize → Embed → Vector2 (384 dims)

5. Similarity Calculation
   └─ Cosine Similarity: dot(Vector1, Vector2) / (norm(V1) * norm(V2))

6. HTTP Response
   Body: {"similarity": 0.87, "text1": "...", "text2": "..."}

7. Frontend Display
   └─ Show similarity percentage with color-coded bar
```

---

## Deployment Architectures

### Local Development (DevContainer)

```
┌─────────────────────────────────────────────────────────┐
│                   Docker Container                      │
│  ┌───────────────────────────────────────────────────┐  │
│  │             VS Code Server                        │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐          │  │
│  │  │  Java   │  │  .NET   │  │ Aspire  │          │  │
│  │  │ Backend │  │ Blazor  │  │Dashboard│          │  │
│  │  │  :8080  │  │  :5000  │  │ :15000  │          │  │
│  │  └─────────┘  └─────────┘  └─────────┘          │  │
│  └───────────────────────────────────────────────────┘  │
│                                                          │
│  Volume Mounts:                                          │
│  • ./models → /workspace/models (AI models)              │
│  • ./src → /workspace/src (source code)                  │
└─────────────────────────────────────────────────────────┘
```

### Azure Container Apps (Production)

```
┌─────────────────────────────────────────────────────────┐
│              Azure Container Apps Environment           │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │         Container App (Java Backend)               │ │
│  │  Image: gpu-langchain4j-demo:latest                │ │
│  │  GPU: NC8as_T4_v3 (NVIDIA T4, 8 vCPU, 56GB RAM)   │ │
│  │  Storage: Azure Files (models)                     │ │
│  │  Ingress: External (HTTPS)                         │ │
│  │  Replicas: 1-3 (autoscaling)                       │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │     Container App (Blazor Frontend)                │ │
│  │  Image: blazor-frontend:latest                     │ │
│  │  CPU: 1 vCPU, 2GB RAM                              │ │
│  │  Ingress: External (HTTPS)                         │ │
│  │  Replicas: 1-5 (autoscaling)                       │ │
│  │  Backend Discovery: Via environment variables      │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  Components:                                             │
│  • Azure Application Insights (Telemetry)                │
│  • Azure Log Analytics (Logging)                         │
│  • Azure CDN (Static assets)                             │
│  • Azure Key Vault (Secrets)                             │
└─────────────────────────────────────────────────────────┘
```

### Kubernetes Deployment (Alternative)

```
┌─────────────────────────────────────────────────────────┐
│                  Kubernetes Cluster                     │
│                                                          │
│  Namespace: gpu-ai-platform                              │
│  ┌────────────────────────────────────────────────────┐ │
│  │              Deployment: java-backend              │ │
│  │  Replicas: 2                                       │ │
│  │  NodeSelector: gpu=true                            │ │
│  │  Resources: 4 CPU, 16GB RAM, 1 GPU                 │ │
│  │  PVC: models-volume (ReadOnlyMany)                 │ │
│  └────────────────────────────────────────────────────┘ │
│  │                                                      │ │
│  │  Service: java-backend-svc (ClusterIP)              │ │
│  │  Port: 8080                                          │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │           Deployment: blazor-frontend              │ │
│  │  Replicas: 3                                       │ │
│  │  Resources: 0.5 CPU, 512MB RAM                     │ │
│  │  Env: BACKEND_URL=java-backend-svc:8080            │ │
│  └────────────────────────────────────────────────────┘ │
│  │                                                      │ │
│  │  Service: blazor-frontend-svc (ClusterIP)           │ │
│  │  Port: 5000                                          │ │
│  └────────────────────────────────────────────────────┘ │
│                                                          │
│  ┌────────────────────────────────────────────────────┐ │
│  │              Ingress Controller                    │ │
│  │  Rules:                                            │ │
│  │  • /api/* → java-backend-svc:8080                  │ │
│  │  • /* → blazor-frontend-svc:5000                   │ │
│  │  TLS: letsencrypt-prod                             │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
```

---

## Technology Stack

### Backend Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Language | Java | 21 LTS | Application runtime |
| Framework | Spring Boot | 3.2.5 | Web framework |
| AI Library | LangChain4j | 0.34.0 | AI orchestration |
| Inference | ONNX Runtime | 1.18.0 | Model execution |
| GPU | CUDA | 12.6 | GPU acceleration |
| Deep Learning | cuDNN | 8.9.7 | Neural network primitives |
| Build Tool | Maven | 3.9+ | Dependency management |
| SD Implementation | SD4J | Custom | Stable Diffusion in Java |

### Frontend Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Blazor Language | C# | 12 | Application logic |
| Blazor Framework | .NET | 10 | Runtime platform |
| UI Framework | Blazor WebAssembly | 10 | Client-side UI |
| Styling | Bootstrap | 5.3 | CSS framework |
| Icons | Bootstrap Icons | 1.11 | Icon library |
| JavaScript | Vanilla JS | ES6+ | Static WebUI |

### Orchestration Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| Orchestration | .NET Aspire | 13 | Service management |
| Telemetry | OpenTelemetry | Built-in | Distributed tracing |
| Logging | Serilog | Built-in | Structured logging |
| Metrics | Prometheus | Built-in | Metrics collection |

### Development Technologies

| Component | Technology | Version | Purpose |
|-----------|-----------|---------|---------|
| IDE | VS Code | Latest | Code editor |
| Containers | Docker | 24+ | Containerization |
| DevContainer | Dev Containers | Latest | Development environment |
| Cloud | Azure | Latest | Cloud platform |
| Source Control | Git | 2.40+ | Version control |

---

## Integration Patterns

### 1. Service Discovery Pattern

**Aspire-Based Discovery:**
```csharp
// AppHost configuration
var backend = builder.AddExecutable("java-backend", ...)
    .WithHttpEndpoint(port: 8080, name: "http");

var frontend = builder.AddProject<Projects.BlazorFrontend>("blazor-frontend")
    .WithEnvironment("services__java-backend__http__0", backend.GetEndpoint("http"));
```

**Client Resolution:**
```csharp
// Blazor client reads from configuration
var backendUrl = builder.Configuration["BackendUrl"] ?? "http://localhost:8080";
```

### 2. Health Check Pattern

**Backend Health Endpoint:**
```java
@GetMapping("/health")
public ResponseEntity<Map<String, String>> health() {
    return ResponseEntity.ok(Map.of("status", "UP"));
}
```

**Aspire Health Monitoring:**
- Automatic health check registration
- Dashboard visualization
- Alert on service degradation

### 3. CORS Pattern

**Backend Configuration:**
```java
@Configuration
public class CorsConfig {
    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();
        configuration.setAllowedOrigins(Arrays.asList(
            "http://localhost:5000",
            "http://localhost:5001",
            "https://localhost:5001"
        ));
        configuration.setAllowedMethods(Arrays.asList("GET", "POST", "PUT", "DELETE"));
        return source;
    }
}
```

### 4. Error Handling Pattern

**Backend:**
```java
@ControllerAdvice
public class GlobalExceptionHandler {
    @ExceptionHandler(Exception.class)
    public ResponseEntity<ErrorResponse> handleException(Exception e) {
        return ResponseEntity.status(500)
            .body(new ErrorResponse(e.getMessage()));
    }
}
```

**Frontend:**
```csharp
try {
    var result = await BackendService.GenerateImageAsync(prompt, style);
} catch (HttpRequestException ex) {
    errorMessage = "Backend service unavailable";
    Logger.LogError(ex, "Failed to generate image");
}
```

### 5. Caching Pattern

**Model Caching:**
```java
@Service
public class ModelManagementService {
    private final Map<String, OrtSession> sessionCache = new ConcurrentHashMap<>();
    
    public OrtSession getSession(String modelPath) {
        return sessionCache.computeIfAbsent(modelPath, this::loadModel);
    }
}
```

---

## Security Considerations

### 1. Input Validation

- Prompt length limits (max 500 characters)
- Style enum validation
- File path sanitization

### 2. API Security

- CORS configuration
- Rate limiting (planned)
- Request timeout enforcement

### 3. Secrets Management

- Azure Key Vault for production
- Environment variables for configuration
- No hardcoded credentials

### 4. Network Security

- HTTPS enforcement in production
- Internal service communication via private network
- Firewall rules for port access

---

## Performance Optimization

### 1. GPU Optimization

- **Memory Management:** Pre-allocate GPU memory
- **Batch Processing:** Batch inference for multiple requests
- **Model Caching:** Keep models loaded in GPU memory
- **Mixed Precision:** Use FP16 where possible

### 2. Backend Optimization

- **Connection Pooling:** Reuse HTTP connections
- **Thread Pools:** Virtual threads (Java 21) for concurrency
- **Model Warmup:** Pre-load models on startup
- **Response Compression:** Gzip/Brotli for large responses

### 3. Frontend Optimization

- **Assembly Trimming:** Remove unused .NET assemblies
- **Lazy Loading:** Load components on demand
- **Asset Caching:** Cache static assets with versioning
- **WebAssembly AOT:** Ahead-of-time compilation

---

## Monitoring and Observability

### Aspire Dashboard Metrics

1. **Service Health:**
   - Uptime percentage
   - Request success rate
   - Error rates

2. **Performance Metrics:**
   - Response times (p50, p95, p99)
   - Throughput (requests/second)
   - CPU and memory usage

3. **Traces:**
   - End-to-end request tracing
   - Service dependencies
   - Bottleneck identification

4. **Logs:**
   - Centralized log aggregation
   - Structured logging with context
   - Log level filtering

### Custom Application Metrics

- Image generation time
- GPU utilization percentage
- Model inference latency
- Cache hit/miss ratios

---

## Future Architecture Enhancements

### Planned Features

1. **Caching Layer:**
   - Redis for prompt caching
   - Generated image caching
   - Embedding result caching

2. **Message Queue:**
   - Async job processing with RabbitMQ
   - Background image generation
   - Batch processing support

3. **API Gateway:**
   - Centralized API management
   - Authentication and authorization
   - Rate limiting and throttling

4. **Multi-GPU Support:**
   - Load balancing across multiple GPUs
   - Model parallelism
   - Pipeline parallelism

5. **Model Versioning:**
   - A/B testing different models
   - Gradual rollout of new models
   - Model performance comparison

---

## Conclusion

This architecture provides a modern, scalable foundation for GPU-accelerated AI applications with:

- **Flexibility:** Multiple frontend options (Blazor, JavaScript)
- **Observability:** Built-in monitoring via Aspire
- **Performance:** GPU acceleration with CPU fallback
- **Developer Experience:** DevContainer, hot reload, service discovery
- **Production-Ready:** Health checks, telemetry, error handling

For more details, refer to:
- [Blazor Frontend Documentation](./BLAZOR-FRONTEND.md)
- [DevContainer Guide](./HOW-TO-RUN-DEVCONTAINER.md)
- [Aspire Integration](./DEVCONTAINER-BLAZOR-ASPIRE-GUIDE.md)
