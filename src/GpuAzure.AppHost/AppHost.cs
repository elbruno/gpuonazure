var builder = DistributedApplication.CreateBuilder(args);

// Configure model directory as parameter for reuse
var modelDir = builder.Configuration["ModelDirectory"] ?? "./models";

// Add Java Spring Boot backend as an executable
// This serves both REST APIs and the JavaScript WebUI (static files)
var javaBackend = builder.AddExecutable("java-backend", "mvn", workingDirectory: "../..", args: ["spring-boot:run"])
    .WithHttpEndpoint(port: 8080, name: "http")
    .WithEnvironment("GPU_LANGCHAIN4J_MODEL_DIR", modelDir)
    .WithEnvironment("GPU_LANGCHAIN4J_GPU_ENABLED", "false") // Default to CPU mode for safety
    .WithEnvironment("SPRING_PROFILES_ACTIVE", "default");

// Get the backend endpoint URL for service discovery
var backendEndpoint = javaBackend.GetEndpoint("http");

// Add Blazor frontend with Aspire service discovery
// The backend URL is automatically resolved through service discovery
var blazorFrontend = builder.AddProject<Projects.BlazorFrontend>("blazor-frontend")
    .WithEnvironment("services__java-backend__http__0", backendEndpoint)
    .WithEnvironment("BackendUrl", backendEndpoint);

// The JavaScript WebUI is served directly by the Java backend
// It's available at the java-backend endpoint (port 8080)
// Access it via: http://localhost:8080

// Optionally, you can also run the Java backend as a container
// Uncomment this if you want to use the Docker image instead
/*
var javaBackendContainer = builder.AddContainer("java-backend-container", "gpu-langchain4j-demo", "latest")
    .WithHttpEndpoint(port: 8080, targetPort: 8080, name: "http")
    .WithEnvironment("GPU_LANGCHAIN4J_MODEL_DIR", "/app/models")
    .WithEnvironment("GPU_LANGCHAIN4J_GPU_ENABLED", "false")
    .WithBindMount(modelDir, "/app/models");
*/

builder.Build().Run();
