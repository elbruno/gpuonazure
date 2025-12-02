namespace BlazorFrontend.Client.Services;

/// <summary>
/// Service for interacting with the Java GPU backend API
/// </summary>
public class GpuBackendService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<GpuBackendService> _logger;

    public GpuBackendService(HttpClient httpClient, ILogger<GpuBackendService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
    }

    /// <summary>
    /// Generate an image from a text prompt using Stable Diffusion
    /// </summary>
    public async Task<byte[]?> GenerateImageAsync(string prompt, string style = "CLASSIC", CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Generating image for prompt: {Prompt}, style: {Style}", prompt, style);

            var request = new ImageRequest
            {
                Prompt = prompt,
                Style = style
            };

            var response = await _httpClient.PostAsJsonAsync("/api/langchain4j/image", request, cancellationToken);
            
            if (response.IsSuccessStatusCode)
            {
                var imageData = await response.Content.ReadAsByteArrayAsync(cancellationToken);
                _logger.LogInformation("Image generated successfully: {Size} bytes", imageData.Length);
                return imageData;
            }
            else
            {
                _logger.LogError("Failed to generate image: {StatusCode}", response.StatusCode);
                return null;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error generating image");
            throw;
        }
    }

    /// <summary>
    /// Compare two text strings using embeddings
    /// </summary>
    public async Task<EmbeddingResponse?> CompareEmbeddingsAsync(string text1, string text2, CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogInformation("Comparing embeddings for texts (lengths: {Len1}, {Len2})", text1.Length, text2.Length);

            var request = new EmbeddingRequest
            {
                Text1 = text1,
                Text2 = text2
            };

            var response = await _httpClient.PostAsJsonAsync("/api/langchain4j/embeddings", request, cancellationToken);
            
            if (response.IsSuccessStatusCode)
            {
                var result = await response.Content.ReadFromJsonAsync<EmbeddingResponse>(cancellationToken);
                _logger.LogInformation("Embeddings compared successfully: similarity = {Similarity}", result?.Similarity);
                return result;
            }
            else
            {
                _logger.LogError("Failed to compare embeddings: {StatusCode}", response.StatusCode);
                return null;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error comparing embeddings");
            throw;
        }
    }

    /// <summary>
    /// Get system metrics including GPU status
    /// </summary>
    public async Task<MetricsResponse?> GetMetricsAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            _logger.LogDebug("Fetching system metrics");

            var response = await _httpClient.GetAsync("/api/langchain4j/metrics", cancellationToken);
            
            if (response.IsSuccessStatusCode)
            {
                var metrics = await response.Content.ReadFromJsonAsync<MetricsResponse>(cancellationToken);
                _logger.LogDebug("Metrics fetched successfully");
                return metrics;
            }
            else
            {
                _logger.LogError("Failed to fetch metrics: {StatusCode}", response.StatusCode);
                return null;
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error fetching metrics");
            throw;
        }
    }

    /// <summary>
    /// Health check endpoint
    /// </summary>
    public async Task<bool> IsHealthyAsync(CancellationToken cancellationToken = default)
    {
        try
        {
            var response = await _httpClient.GetAsync("/api/langchain4j/health", cancellationToken);
            return response.IsSuccessStatusCode;
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error checking health");
            return false;
        }
    }
}

// Request/Response DTOs
public record ImageRequest
{
    public string Prompt { get; set; } = string.Empty;
    public string Style { get; set; } = "CLASSIC";
}

public record EmbeddingRequest
{
    public string Text1 { get; set; } = string.Empty;
    public string Text2 { get; set; } = string.Empty;
}

public record EmbeddingResponse
{
    public double Similarity { get; set; }
    public string Text1 { get; set; } = string.Empty;
    public string Text2 { get; set; } = string.Empty;
}

public record MetricsResponse
{
    public bool GpuAvailable { get; set; }
    public bool ModelsLoaded { get; set; }
    public Dictionary<string, ModelInfo> Models { get; set; } = new();
    public string OnnxRuntimeVersion { get; set; } = string.Empty;
}

public record ModelInfo
{
    public bool Available { get; set; }
    public string Status { get; set; } = string.Empty;
    public string Provider { get; set; } = string.Empty;
    public string Model { get; set; } = string.Empty;
}
