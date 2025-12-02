var builder = DistributedApplication.CreateBuilder(args);

// Configure model directory as parameter for reuse
var modelDir = builder.Configuration["ModelDirectory"] ?? "./models";

// Add Java Spring Boot backend as an executable
// This will run the Maven Spring Boot application
var javaBackend = builder.AddExecutable("java-backend", "mvn", workingDirectory: "../..", args: ["spring-boot:run"])
    .WithHttpEndpoint(port: 8080, name: "http")
    .WithEnvironment("GPU_LANGCHAIN4J_MODEL_DIR", modelDir)
    .WithEnvironment("GPU_LANGCHAIN4J_GPU_ENABLED", "false") // Default to CPU mode for safety
    .WithEnvironment("SPRING_PROFILES_ACTIVE", "default");

// Get the backend endpoint URL
var backendEndpoint = javaBackend.GetEndpoint("http");

// Add Blazor frontend with backend URL configuration
var blazorFrontend = builder.AddProject<Projects.BlazorFrontend>("blazor-frontend")
    .WithEnvironment("BackendUrl", backendEndpoint);

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
