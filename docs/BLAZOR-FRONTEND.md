# Blazor Frontend Documentation

## Overview

The Blazor WebAssembly frontend provides a modern, interactive user interface for the GPU-accelerated AI platform. Built with .NET 10 and Blazor WebAssembly, it communicates with the Java Spring Boot backend via REST APIs.

## Project Structure

```
src/BlazorFrontend/
├── BlazorFrontend/                    # Server-side host project
│   ├── Components/
│   │   ├── Layout/                    # Layout components
│   │   │   ├── MainLayout.razor       # Main application layout
│   │   │   └── NavMenu.razor          # Navigation menu
│   │   └── Pages/
│   │       ├── Home.razor             # Landing page
│   │       ├── Error.razor            # Error page
│   │       └── NotFound.razor         # 404 page
│   ├── Program.cs                     # Server configuration
│   └── BlazorFrontend.csproj
│
└── BlazorFrontend.Client/             # WebAssembly client project
    ├── Pages/
    │   ├── ImageGenerator.razor       # Image generation interface
    │   ├── Embeddings.razor           # Text similarity comparison
    │   └── SystemMetrics.razor        # System metrics dashboard
    ├── Services/
    │   └── GpuBackendService.cs       # Backend API client
    ├── Program.cs                     # Client configuration
    └── BlazorFrontend.Client.csproj
```

## Features

### 1. Image Generator (`/image-generator`)

Generate AI images from text prompts using Stable Diffusion v1.5.

**Features:**
- Text prompt input with style selection (Classic, Happy, Confused, Excited)
- Real-time generation progress indicator
- Image preview and download
- Sample prompts for quick testing
- Generation time tracking

**Usage:**
1. Enter a descriptive prompt
2. Select an image style
3. Click "Generate Image"
4. Wait 30-60 seconds (CPU) or 2-5 seconds (GPU)
5. Download or regenerate with different settings

### 2. Text Embeddings (`/embeddings`)

Compare semantic similarity between two text snippets.

**Features:**
- Side-by-side text input fields
- Visual similarity score with color-coded progress bar
- Interpretation guide for scores
- Sample comparisons (high, medium, low similarity)

**Score Interpretation:**
- **90-100%**: Very similar or nearly identical meaning
- **70-90%**: Strong semantic similarity
- **50-70%**: Moderate similarity
- **0-50%**: Low similarity or different topics

### 3. System Metrics (`/metrics`)

Real-time monitoring of system health and model status.

**Features:**
- GPU availability status
- Model loading status
- ONNX Runtime version
- Backend connection health
- Auto-refresh every 10 seconds

**Displays:**
- Stable Diffusion v1.5 status and provider (SD4J)
- All-MiniLM-L6-v2 embeddings status
- Real-time health checks

### 4. Home Page (`/`)

Landing page with overview and quick access to all features.

**Features:**
- Feature cards with navigation
- Architecture overview
- Key features list
- Technology stack information

## Service Layer

### GpuBackendService

The `GpuBackendService` class provides a strongly-typed client for the Java backend API.

**Methods:**

#### GenerateImageAsync
```csharp
public async Task<byte[]?> GenerateImageAsync(
    string prompt, 
    string style = "CLASSIC", 
    CancellationToken cancellationToken = default)
```

Generates an image from a text prompt.

**Parameters:**
- `prompt`: Text description of the desired image
- `style`: Image style (CLASSIC, HAPPY, CONFUSED, EXCITED)
- `cancellationToken`: Cancellation token for async operations

**Returns:** PNG image data as byte array

#### CompareEmbeddingsAsync
```csharp
public async Task<EmbeddingResponse?> CompareEmbeddingsAsync(
    string text1, 
    string text2, 
    CancellationToken cancellationToken = default)
```

Compares semantic similarity between two texts.

**Parameters:**
- `text1`: First text to compare
- `text2`: Second text to compare
- `cancellationToken`: Cancellation token

**Returns:** `EmbeddingResponse` with similarity score (0.0-1.0)

#### GetMetricsAsync
```csharp
public async Task<MetricsResponse?> GetMetricsAsync(
    CancellationToken cancellationToken = default)
```

Retrieves system metrics and health information.

**Returns:** `MetricsResponse` with GPU status, models, and ONNX Runtime info

#### IsHealthyAsync
```csharp
public async Task<bool> IsHealthyAsync(
    CancellationToken cancellationToken = default)
```

Checks if the backend service is responding.

**Returns:** `true` if healthy, `false` otherwise

## Configuration

### Backend URL

Configure the Java backend URL in `appsettings.json`:

```json
{
  "BackendUrl": "http://localhost:8080"
}
```

**Environment-specific:**
- `appsettings.json`: Default configuration
- `appsettings.Development.json`: Development overrides

When running with Aspire, the backend URL is automatically configured via environment variables.

### CORS Configuration

The server-side host configures CORS to allow communication with the Java backend:

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

## Running the Frontend

### Standalone (without Aspire)

```bash
cd src/BlazorFrontend/BlazorFrontend
dotnet run
```

Access at: http://localhost:5000 or https://localhost:5001

### With Aspire (Recommended)

```bash
cd src/GpuAzure.AppHost
dotnet run
```

Aspire automatically starts both frontend and backend with service discovery.

### Development Mode

Enable hot reload for faster development:

```bash
dotnet watch run
```

Changes to Razor components are automatically reloaded.

## Building for Production

### Publish for Deployment

```bash
cd src/BlazorFrontend/BlazorFrontend
dotnet publish -c Release -o ./publish
```

This creates an optimized build with:
- AOT compilation for WebAssembly
- Trimmed assemblies
- Compressed assets
- Production configuration

### Docker Deployment

Create a Dockerfile for the Blazor frontend:

```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["BlazorFrontend/BlazorFrontend.csproj", "BlazorFrontend/"]
COPY ["BlazorFrontend.Client/BlazorFrontend.Client.csproj", "BlazorFrontend.Client/"]
RUN dotnet restore "BlazorFrontend/BlazorFrontend.csproj"
COPY . .
RUN dotnet publish "BlazorFrontend/BlazorFrontend.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENTRYPOINT ["dotnet", "BlazorFrontend.dll"]
```

## Styling

The frontend uses Bootstrap 5 for styling with custom enhancements:

- **Bootstrap Icons**: For consistent iconography
- **Custom Colors**: Matching the GPU/AI theme
- **Responsive Design**: Mobile-friendly layouts
- **Dark Mode Ready**: Can be enabled via Bootstrap themes

### Adding Custom Styles

Edit `wwwroot/app.css` in the server project:

```css
.custom-class {
    /* Your styles */
}
```

## Performance Optimization

### WebAssembly Size Optimization

The project uses several techniques to minimize download size:

1. **Assembly Trimming**: Unused code is removed
2. **Brotli Compression**: Assets are compressed
3. **Lazy Loading**: Components load on demand
4. **AOT Compilation**: Ahead-of-time compilation for faster startup

### Caching Strategy

Static assets are cached with immutable content hashing:

```html
<link href="_content/BlazorFrontend.Client/app.styles.css?v=abc123" rel="stylesheet" />
```

## Troubleshooting

### Backend Connection Failed

**Error:** `Failed to generate image. Please check if the backend service is running.`

**Solution:**
1. Verify Java backend is running: `curl http://localhost:8080/api/langchain4j/health`
2. Check backend URL in `appsettings.json`
3. Verify CORS is configured in Java backend

### WebAssembly Loading Slowly

**Solution:**
- Enable compression in production
- Use HTTP/2 or HTTP/3
- Deploy close to users (CDN)
- Enable assembly trimming

### HTTPS Certificate Errors

**Solution:**
```bash
dotnet dev-certs https --trust
```

## Testing

### Unit Testing Components

Create tests in a separate test project:

```csharp
using Bunit;
using Xunit;

public class ImageGeneratorTests : TestContext
{
    [Fact]
    public void ImageGenerator_RendersCorrectly()
    {
        // Arrange
        var cut = RenderComponent<ImageGenerator>();
        
        // Assert
        cut.Find("h1").TextContent.Should().Contain("Image Generator");
    }
}
```

### Integration Testing

Test the backend service client:

```csharp
[Fact]
public async Task GenerateImageAsync_ValidPrompt_ReturnsImageData()
{
    // Arrange
    var httpClient = new HttpClient { BaseAddress = new Uri("http://localhost:8080") };
    var service = new GpuBackendService(httpClient, logger);
    
    // Act
    var result = await service.GenerateImageAsync("test prompt", "CLASSIC");
    
    // Assert
    result.Should().NotBeNull();
    result.Length.Should().BeGreaterThan(0);
}
```

## Future Enhancements

Planned features for the Blazor frontend:

- [ ] User authentication with Azure AD B2C
- [ ] Image history and gallery
- [ ] Batch image generation
- [ ] Advanced image editing tools
- [ ] Real-time progress updates with SignalR
- [ ] Prompt templates and suggestions
- [ ] Image-to-image generation
- [ ] Fine-tuning controls for inference parameters

## Resources

- [Blazor Documentation](https://learn.microsoft.com/aspnet/core/blazor/)
- [Blazor WebAssembly](https://learn.microsoft.com/aspnet/core/blazor/hosting-models#blazor-webassembly)
- [.NET Aspire](https://learn.microsoft.com/dotnet/aspire/)
- [Bootstrap 5](https://getbootstrap.com/docs/5.3/)
