# GitHub Copilot Instructions

## Project Overview

This is a **GPU-accelerated AI inference application** built with:
- **Backend**: Java 21, Spring Boot 3.2.5, LangChain4j 0.34.0, ONNX Runtime 1.18.0, CUDA 12.6
- **Frontend**: .NET 10, Blazor WebAssembly, JavaScript/HTML
- **Orchestration**: .NET Aspire 13
- **Deployment**: Azure Container Apps with GPU profiles (T4/A100), DevContainer support

The application generates images using Stable Diffusion v1.5 and computes text embeddings using All-MiniLM-L6-v2, with multiple frontend options and full service orchestration.

## Technology Stack

### Backend
- **Language**: Java 21 LTS (with `--enable-preview` for virtual threads)
- **Framework**: Spring Boot 3.2.5
- **AI Framework**: LangChain4j 0.34.0 with ONNX Runtime integration
- **Inference Engine**: ONNX Runtime 1.18.0 (CPU + GPU/CUDA 12.6)
- **Build Tool**: Maven 3.9+
- **Models**: Stable Diffusion v1.5 ONNX, All-MiniLM-L6-v2 ONNX
- **Container Base**: nvidia/cuda:12.6.0-cudnn-runtime-ubuntu24.04

### Frontend
- **.NET Version**: .NET 10
- **Blazor**: WebAssembly + Server
- **JavaScript**: Vanilla JS (HTML/CSS/JS WebUI)
- **Styling**: Bootstrap 5.3

### Orchestration & DevOps
- **Service Orchestration**: .NET Aspire 13
- **Development**: DevContainer (VS Code/Codespaces)
- **Cloud Platform**: Azure Container Apps with GPU profiles

## Documentation Structure

**IMPORTANT**: All documentation MUST be placed in the `docs/` folder, except for:
- `README.md` (root directory - main project overview)
- `LICENSE` (root directory - project license)

### Documentation Files Location

```
gpuonazure/
├── README.md                                    # Main project documentation
├── LICENSE                                      # Project license
├── SETUP.md                                     # Quick setup guide (can be in root)
│
└── docs/                                        # All other documentation here
    ├── ARCHITECTURE.md                          # System architecture
    ├── BLAZOR-FRONTEND.md                       # Blazor frontend documentation
    ├── HOW-TO-RUN-DEVCONTAINER.md              # DevContainer step-by-step guide
    ├── DEVCONTAINER-BLAZOR-ASPIRE-GUIDE.md     # Integration guide
    ├── AZURE-DEPLOYMENT-GUIDE.md               # Azure deployment
    ├── AZURE-QUICK-REFERENCE.md                # Quick reference
    ├── AZURE-DEPLOYMENT-CHECKLIST.md           # Deployment checklist
    ├── DOCKER-BUILD-REFERENCE.md               # Docker build guide
    └── [any other documentation]               # All other docs
```

### When Creating Documentation

1. **Always create documentation in `docs/` folder** unless it's README.md or LICENSE
2. **Use descriptive filenames** with UPPERCASE and hyphens (e.g., `HOW-TO-RUN-DEVCONTAINER.md`)
3. **Include table of contents** for long documents
4. **Cross-reference other docs** using relative paths: `[Architecture](./ARCHITECTURE.md)`
5. **Keep README.md concise** and link to detailed docs in `docs/` folder

## Project Structure

```
gpuonazure/
├── .devcontainer/                              # DevContainer configuration
│   ├── devcontainer.json                       # VS Code/Codespaces settings
│   ├── Dockerfile                              # Dev environment image
│   └── post-create.sh                          # Setup script
│
├── src/
│   ├── main/                                   # Java backend
│   │   ├── java/com/azure/gpudemo/
│   │   │   ├── GpuLangchain4jDemoApplication.java
│   │   │   ├── config/
│   │   │   │   └── LangChain4jGpuConfiguration.java
│   │   │   ├── service/
│   │   │   │   ├── LangChain4jGpuService.java
│   │   │   │   ├── SD4JImageGenerationService.java
│   │   │   │   └── ModelManagementService.java
│   │   │   └── controller/
│   │   │       └── ImageController.java
│   │   └── resources/
│   │       ├── application.yml
│   │       └── static/                         # JavaScript WebUI
│   │           ├── index.html
│   │           ├── css/styles.css
│   │           └── js/app.js
│   │
│   ├── BlazorFrontend/                         # .NET Blazor frontend
│   │   ├── BlazorFrontend/                     # Server project
│   │   │   ├── Components/
│   │   │   │   ├── Pages/
│   │   │   │   │   └── Home.razor
│   │   │   │   └── Layout/
│   │   │   │       ├── MainLayout.razor
│   │   │   │       └── NavMenu.razor
│   │   │   ├── Program.cs
│   │   │   └── appsettings.json
│   │   └── BlazorFrontend.Client/              # WASM client project
│   │       ├── Pages/
│   │       │   ├── ImageGenerator.razor
│   │       │   ├── Embeddings.razor
│   │       │   └── SystemMetrics.razor
│   │       ├── Services/
│   │       │   └── GpuBackendService.cs
│   │       └── Program.cs
│   │
│   ├── GpuAzure.AppHost/                       # Aspire orchestration
│   │   ├── AppHost.cs
│   │   └── appsettings.json
│   │
│   ├── GpuAzure.ServiceDefaults/               # Aspire defaults
│   │   └── Extensions.cs
│   │
│   ├── GpuAzure.sln                            # .NET solution
│   └── README.md                               # Aspire-specific docs
│
├── docs/                                       # All documentation here
│   ├── ARCHITECTURE.md
│   ├── BLAZOR-FRONTEND.md
│   ├── HOW-TO-RUN-DEVCONTAINER.md
│   └── [other documentation files]
│
├── scripts/                                    # Build and deployment scripts
├── models/                                     # AI models (gitignored)
├── pom.xml                                     # Maven configuration
├── Dockerfile                                  # Multi-stage build
└── README.md                                   # Main project documentation
```

## Coding Standards

### Java Conventions

1. **Java Version**: Always use Java 21 features
   - Virtual threads: `Thread.startVirtualThread(() -> {})`
   - Pattern matching for switch
   - Record patterns
   - Enable preview features: `--enable-preview`

2. **Spring Boot Patterns**:
   - Use `@Configuration` for bean definitions
   - Use `@Service` for business logic
   - Use `@RestController` with `@RequestMapping` for APIs
   - Use `@Value` or `@ConfigurationProperties` for configuration
   - Use constructor injection (not field injection)

3. **Error Handling**:
   - Use `@ControllerAdvice` for global exception handling
   - Return proper HTTP status codes (400, 404, 500)
   - Log errors with context using SLF4J
   - Use custom exceptions for business logic errors

4. **Resource Management**:
   - Use try-with-resources for closeable resources
   - Implement `@PreDestroy` for cleanup in services
   - Close ONNX sessions properly

5. **Null Safety**:
   - Use `Optional<T>` for nullable return values
   - Validate inputs with `@Valid` and `@NotNull`
   - Check preconditions with `Objects.requireNonNull()`

### LangChain4j Integration

1. **Model Configuration**:
   - Define models as Spring beans in `LangChain4jGpuConfiguration`
   - Use `OrtEnvironment` for ONNX Runtime session management
   - Configure GPU device ID and thread pools

2. **Service Layer**:
   - Keep inference logic in `LangChain4jGpuService`
   - Use model management in `ModelManagementService`
   - Implement warmup methods for model loading

3. **ONNX Runtime**:
   - Always specify execution provider: `ExecutionProvider.CUDA`
   - Set device ID: `OrtSession.SessionOptions().setGpuDeviceId(0)`
   - Configure thread pools for optimal performance

### REST API Design

1. **Endpoints**:
   - Use `/api/langchain4j/*` as base path
   - POST `/image` - Generate images from text prompts
   - POST `/embeddings` - Compare text similarity
   - GET `/metrics` - System health and model status
   - GET `/health` - Simple health check
   - Return proper HTTP status codes

2. **Request/Response**:
   - Use DTOs (records) for request/response bodies
   - Validate inputs with Jakarta Bean Validation
   - Return `ResponseEntity<T>` with proper status
   - Use `produces = MediaType.IMAGE_PNG_VALUE` for images

3. **Error Responses**:
   ```java
   {
     "error": "Error message",
     "status": 400,
     "timestamp": "2025-09-29T12:00:00Z"
   }
   ```

### Configuration

1. **application.yml Structure**:
   ```yaml
   spring:
     application:
       name: gpu-langchain4j-demo
   
   gpu:
     langchain4j:
       gpu:
         enabled: true
         device-id: 0
       model:
         dir: ./models
   ```

2. **Externalization**:
   - Use environment variables for secrets
   - Use profiles for environment-specific config
   - Document all configuration properties

### Testing

1. **Unit Tests**:
   - Use JUnit 5
   - Mock external dependencies with Mockito
   - Test error scenarios
   - Target 80%+ code coverage

2. **Integration Tests**:
   - Use `@SpringBootTest` for full context
   - Use `@WebMvcTest` for controller tests
   - Mock ONNX models in tests (too large to include)

### Docker

1. **Multi-stage Builds**:
   - Stage 1: Maven build (eclipse-temurin-21)
   - Stage 2: Runtime (nvidia/cuda:12.2.0-runtime-ubuntu22.04)

2. **Best Practices**:
   - Use layer caching for dependencies
   - Create non-root user for runtime
   - Set proper CUDA environment variables
   - Include health check in Dockerfile

### Azure Deployment

1. **Container Apps**:
   - Use GPU workload profiles (NC8as_T4_v3 or NC24ads_A100_v4)
   - Set appropriate CPU/memory (4 CPU, 16GB RAM minimum)
   - Configure autoscaling (min: 1, max: 3)
   - Enable ingress with external access

2. **Environment Variables**:
   ```bash
   SPRING_PROFILES_ACTIVE=production
   GPU_LANGCHAIN4J_GPU_ENABLED=true
   GPU_LANGCHAIN4J_GPU_DEVICE_ID=0
   JAVA_OPTS=-Xmx8g -XX:+UseZGC
   ```

## Common Patterns

### 1. Adding New Inference Endpoint

```java
@PostMapping("/new-inference")
public ResponseEntity<?> performInference(@Valid @RequestBody RequestDTO request) {
    try {
        var result = gpuService.performInference(request);
        return ResponseEntity.ok(result);
    } catch (Exception e) {
        log.error("Inference failed", e);
        return ResponseEntity.status(500)
            .body(Map.of("error", e.getMessage()));
    }
}
```

### 2. Loading New ONNX Model

```java
@Bean
public OrtSession newModel(OrtEnvironment env) throws OrtException {
    var options = new OrtSession.SessionOptions();
    options.setExecutionMode(OrtSession.SessionOptions.ExecutionMode.PARALLEL);
    options.addCUDA(gpuDeviceId);
    options.setInterOpNumThreads(4);
    options.setIntraOpNumThreads(8);
    
    String modelPath = modelDir + "/new-model/model.onnx";
    return env.createSession(modelPath, options);
}
```

### 3. GPU Resource Management

```java
@PreDestroy
public void cleanup() {
    try {
        if (stableDiffusionSession != null) {
            stableDiffusionSession.close();
        }
        if (ortEnvironment != null) {
            ortEnvironment.close();
        }
    } catch (Exception e) {
        log.error("Error during cleanup", e);
    }
}
```

### 4. Error Handling

```java
@ControllerAdvice
public class GlobalExceptionHandler {
    
    @ExceptionHandler(OrtException.class)
    public ResponseEntity<?> handleOrtException(OrtException e) {
        log.error("ONNX Runtime error", e);
        return ResponseEntity.status(500)
            .body(Map.of("error", "Inference failed: " + e.getMessage()));
    }
}
```

## Performance Optimization

1. **JVM Options**:
   - Use ZGC for low-latency GC: `-XX:+UseZGC -XX:+ZGenerational`
   - Set appropriate heap size: `-Xmx8g`
   - Enable preview features: `--enable-preview`

2. **ONNX Runtime**:
   - Use GPU execution provider
   - Configure thread pools (inter-op: 4, intra-op: 8)
   - Implement model warmup on startup

3. **Spring Boot**:
   - Use virtual threads for async operations
   - Configure graceful shutdown
   - Enable HTTP compression

## Security Considerations

1. **Input Validation**:
   - Validate all user inputs
   - Limit prompt length (max 500 chars)
   - Sanitize file paths

2. **Resource Limits**:
   - Implement rate limiting
   - Set request timeouts
   - Limit concurrent requests

3. **Secrets Management**:
   - Never commit secrets to git
   - Use Azure Key Vault for production
   - Use environment variables

## Debugging Tips

1. **GPU Issues**:
   - Check CUDA availability: `nvidia-smi`
   - Verify ONNX Runtime GPU: Check health endpoint
   - Review GPU memory usage

2. **Model Loading**:
   - Verify model file paths
   - Check file permissions
   - Review model download logs

3. **Performance**:
   - Enable DEBUG logging for ONNX Runtime
   - Monitor JVM heap usage
   - Check thread pool utilization

## Git Workflow

1. **Branch Naming**:
   - `feature/description` for new features
   - `bugfix/description` for bug fixes
   - `docs/description` for documentation

2. **Commit Messages**:
   - Use conventional commits: `feat:`, `fix:`, `docs:`, `refactor:`
   - Include context and reasoning
   - Reference issue numbers

3. **Before Commit**:
   - Run tests: `mvn test`
   - Check formatting: `mvn spotless:check`
   - Build successfully: `mvn clean package`

## Additional Resources

- [LangChain4j Documentation](https://docs.langchain4j.dev/)
- [ONNX Runtime Java API](https://onnxruntime.ai/docs/api/java/api/)
- [Spring Boot Reference](https://docs.spring.io/spring-boot/docs/current/reference/html/)
- [Azure Container Apps](https://learn.microsoft.com/azure/container-apps/)
- [CUDA Programming Guide](https://docs.nvidia.com/cuda/)

## Notes for AI Assistants

- **Always** use Java 21 syntax and features
- **Always** check GPU availability before GPU operations
- **Always** implement proper resource cleanup
- **Always** validate user inputs
- **Always** handle ONNX Runtime exceptions
- **Never** commit model files to git (too large)
- **Never** hardcode secrets or credentials
- **Prefer** constructor injection over field injection
- **Prefer** records over classes for DTOs
- **Prefer** async operations with virtual threads

---

**Last Updated**: September 29, 2025  
**Project Version**: 0.0.1-SNAPSHOT

## .NET and Blazor Conventions

### 1. C# Coding Standards

1. **C# Version**: Use C# 12 features
   - Primary constructors
   - Collection expressions
   - Required properties
   - File-scoped types

2. **Blazor Patterns**:
   - Use `@page` directive for routable components
   - Use `@inject` for dependency injection
   - Use `@code` block for component logic
   - Keep component logic in code-behind when complex

3. **Service Layer**:
   - Use `IHttpClientFactory` for HTTP clients
   - Implement retry policies with Polly
   - Use strongly-typed configuration with `IOptions<T>`
   - Register services with appropriate lifetime (Scoped, Singleton, Transient)

### 2. Blazor Component Structure

```razor
@page "/component"
@using Namespace.Services
@inject ServiceName Service

<PageTitle>Component Title</PageTitle>

<div class="container">
    <!-- Component markup -->
</div>

@code {
    // Component logic
    private string property = "";
    
    protected override async Task OnInitializedAsync()
    {
        await LoadDataAsync();
    }
    
    private async Task LoadDataAsync()
    {
        // Load data
    }
}
```

### 3. API Client Pattern

```csharp
public class BackendService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<BackendService> _logger;
    
    public BackendService(HttpClient httpClient, ILogger<BackendService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }
    
    public async Task<Result?> GetDataAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            return await _httpClient.GetFromJsonAsync<Result>("/api/endpoint", cancellationToken);
        }
        catch (HttpRequestException ex)
        {
            _logger.LogError(ex, "Failed to fetch data");
            throw;
        }
    }
}
```

## .NET Aspire Orchestration

### 1. AppHost Configuration

```csharp
var builder = DistributedApplication.CreateBuilder(args);

// Add Java backend as executable
var javaBackend = builder.AddExecutable("java-backend", "mvn",
    workingDirectory: "../..", 
    args: ["spring-boot:run"])
    .WithHttpEndpoint(port: 8080, name: "http");

// Add Blazor frontend with service discovery
var blazorFrontend = builder.AddProject<Projects.BlazorFrontend>("blazor-frontend")
    .WithEnvironment("services__java-backend__http__0", javaBackend.GetEndpoint("http"));

builder.Build().Run();
```

### 2. Running with Aspire

```bash
# Start all services
cd src/GpuAzure.AppHost
dotnet run

# Access Aspire Dashboard
open http://localhost:15000
```

## Documentation Guidelines

### 1. File Organization

- **All documentation in `docs/` folder** except README.md and LICENSE
- Use descriptive UPPERCASE filenames with hyphens
- Include table of contents for long documents
- Cross-reference using relative paths

### 2. Required Documentation Files

- `README.md` (root) - Project overview and quick start
- `docs/ARCHITECTURE.md` - System architecture and components
- `docs/HOW-TO-RUN-DEVCONTAINER.md` - DevContainer setup guide
- `docs/BLAZOR-FRONTEND.md` - Blazor frontend documentation
- `docs/DEVCONTAINER-BLAZOR-ASPIRE-GUIDE.md` - Integration guide

## Notes for AI Assistants

### .NET
- **Always** use .NET 10 and C# 12 features
- **Always** implement proper error handling in Blazor components
- **Always** use cancellation tokens for async operations
- **Always** dispose of HttpClient properly (use IHttpClientFactory)
- **Prefer** scoped services for Blazor Server, singleton for static data
- **Prefer** async/await patterns over blocking calls

### Aspire
- **Always** use service discovery instead of hardcoded URLs
- **Always** implement health checks for services
- **Always** use structured logging
- **Prefer** Aspire AppHost for local development

### Documentation
- **Always** place documentation in `docs/` folder (except README.md and LICENSE)
- **Always** include table of contents for long documents
- **Always** use descriptive filenames (e.g., `HOW-TO-RUN-DEVCONTAINER.md`)
- **Never** duplicate content across multiple files (link instead)

---

**Last Updated**: December 2, 2025  
**Project Version**: 1.0.0  
**Stack**: Java 21 + Spring Boot 3.2.5 + .NET 10 + Blazor + Aspire 13
