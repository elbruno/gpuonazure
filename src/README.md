# GPU Azure - .NET Aspire Orchestration

This directory contains the .NET Aspire orchestration projects for the GPU-accelerated AI application.

## Projects

- **GpuAzure.AppHost** - Aspire orchestration host that manages all services
- **GpuAzure.ServiceDefaults** - Shared service defaults for health checks, telemetry, etc.
- **BlazorFrontend** - Blazor WebAssembly frontend application
- **BlazorFrontend.Client** - Blazor WebAssembly client-side components

## Prerequisites

- .NET 10 SDK
- .NET Aspire 13 workload (install with `dotnet workload install aspire`)
- Java 21 JDK
- Maven 3.9+

## Running with Aspire

### Option 1: Using Aspire Dashboard (Recommended)

This will start both the Java backend and Blazor frontend orchestrated by Aspire:

```bash
# From the repository root
cd src/GpuAzure.AppHost
dotnet run
```

The Aspire dashboard will open automatically showing:
- Java Backend API (running on port 8080)
- Blazor Frontend (running on port 5000/5001)
- Health checks, metrics, and logs for all services

**Aspire Dashboard URL:** http://localhost:15000 or https://localhost:18888

### Option 2: Running Services Individually

**Java Backend:**
```bash
# From repository root
mvn spring-boot:run
```

**Blazor Frontend:**
```bash
# From repository root
cd src/BlazorFrontend/BlazorFrontend
dotnet run
```

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      .NET Aspire AppHost                        │
│                    (Service Orchestration)                      │
└────────────────┬──────────────────────────┬─────────────────────┘
                 │                          │
    ┌────────────▼──────────┐  ┌───────────▼────────────┐
    │   Java Backend        │  │   Blazor Frontend      │
    │   Spring Boot 3.2.5   │  │   .NET 10 WebAssembly  │
    │   Port: 8080          │◄─┤   Port: 5000/5001      │
    │                       │  │                         │
    │  - Image Generation   │  │  - Modern UI           │
    │  - Text Embeddings    │  │  - API Client          │
    │  - ONNX Runtime       │  │  - Real-time Updates   │
    └───────────────────────┘  └────────────────────────┘
```

## Features

### Service Discovery
- Automatic service discovery between frontend and backend
- No hardcoded URLs - Aspire manages endpoint references

### Health Checks
- Automated health monitoring for all services
- Visible in Aspire dashboard

### Telemetry
- Distributed tracing across services
- Metrics and logging aggregation
- OpenTelemetry integration

### Development Experience
- Single command to start entire application
- Automatic service restart on code changes
- Unified logging and monitoring

## Configuration

### Backend Configuration

The Java backend is configured via environment variables:

```bash
GPU_LANGCHAIN4J_MODEL_DIR=./models
GPU_LANGCHAIN4J_GPU_ENABLED=false  # Set to true for GPU mode
SPRING_PROFILES_ACTIVE=default
```

Edit `src/GpuAzure.AppHost/AppHost.cs` to modify these settings.

### Frontend Configuration

The Blazor frontend automatically receives the backend URL from Aspire:

```csharp
var blazorFrontend = builder.AddProject<Projects.BlazorFrontend>("blazor-frontend")
    .WithReference(javaBackend)
    .WithEnvironment("BackendUrl", javaBackend.GetEndpoint("http"));
```

## GPU Support

By default, the orchestration runs in CPU mode for safety. To enable GPU:

1. Edit `src/GpuAzure.AppHost/AppHost.cs`
2. Change `GPU_LANGCHAIN4J_GPU_ENABLED` to `"true"`
3. Ensure NVIDIA drivers and CUDA are installed on the host

```csharp
var javaBackend = builder.AddExecutable("java-backend", "mvn", workingDirectory: "../..", args: ["spring-boot:run"])
    .WithEnvironment("GPU_LANGCHAIN4J_GPU_ENABLED", "true")  // Enable GPU
    // ... other config
```

## Container Mode (Alternative)

You can also run the Java backend as a Docker container instead of an executable.

Uncomment this section in `AppHost.cs`:

```csharp
var javaBackendContainer = builder.AddContainer("java-backend-container", "gpu-langchain4j-demo", "latest")
    .WithHttpEndpoint(port: 8080, targetPort: 8080, name: "http")
    .WithEnvironment("GPU_LANGCHAIN4J_MODEL_DIR", "/app/models")
    .WithEnvironment("GPU_LANGCHAIN4J_GPU_ENABLED", "false")
    .WithBindMount(modelDir, "/app/models");
```

Then build the Docker image first:

```bash
# From repository root
docker build -t gpu-langchain4j-demo:latest .
```

## Troubleshooting

### Java Backend Not Starting

- Verify Java 21 is installed: `java --version`
- Verify Maven is installed: `mvn --version`
- Check models are downloaded in `./models` directory

### Blazor Frontend Can't Connect to Backend

- Verify Java backend is running and healthy
- Check Aspire dashboard for service status
- Verify CORS is configured in Java backend

### Aspire Dashboard Not Opening

- Check port 15000 and 18888 are not in use
- Run: `dotnet run --urls "http://localhost:15000"`

## Next Steps

- Add service-to-service authentication
- Configure production deployment settings
- Add Redis cache for improved performance
- Integrate Azure-specific Aspire components

## Resources

- [.NET Aspire Documentation](https://learn.microsoft.com/dotnet/aspire/)
- [Aspire Dashboard](https://learn.microsoft.com/dotnet/aspire/fundamentals/dashboard)
- [Service Discovery](https://learn.microsoft.com/dotnet/aspire/service-discovery/overview)
