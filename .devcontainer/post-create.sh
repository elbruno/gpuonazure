#!/bin/bash
set -e

echo "=========================================="
echo "Running post-create setup..."
echo "=========================================="

# Verify Java installation
echo "Java version:"
java --version

# Verify .NET installation
echo ".NET version:"
dotnet --version

# Verify Maven installation
echo "Maven version:"
mvn --version

# Verify Docker (if available)
if command -v docker &> /dev/null; then
    echo "Docker version:"
    docker --version
fi

# Verify Azure CLI
if command -v az &> /dev/null; then
    echo "Azure CLI version:"
    az --version | head -1
fi

# Install .NET development certificates
echo "Installing .NET development certificates..."
dotnet dev-certs https --trust 2>&1 || echo "Note: HTTPS certificate trust requires manual confirmation"

# Restore .NET Aspire tools if AppHost exists
if [ -d "src/GpuAzure.AppHost" ]; then
    echo "Restoring .NET Aspire AppHost dependencies..."
    cd src/GpuAzure.AppHost
    dotnet restore || echo "Note: Will restore when AppHost is created"
    cd ../..
fi

# Download Maven dependencies for Java project
if [ -f "pom.xml" ]; then
    echo "Downloading Maven dependencies..."
    mvn dependency:go-offline -B 2>&1 || echo "Note: Some dependencies may be downloaded on first build"
fi

echo "=========================================="
echo "Post-create setup complete!"
echo "=========================================="
echo ""
echo "To get started:"
echo "  1. Run Java backend: mvn spring-boot:run"
echo "  2. Run Blazor frontend: cd src/BlazorFrontend && dotnet run"
echo "  3. Run with Aspire: cd src/GpuAzure.AppHost && dotnet run"
echo ""
echo "NOTE: GPU support requires NVIDIA drivers on the host"
echo "=========================================="
