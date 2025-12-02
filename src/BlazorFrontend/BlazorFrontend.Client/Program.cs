using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using BlazorFrontend.Client.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

// Configure HttpClient for backend API
// Read backend URL from configuration, default to localhost:8080
var backendUrl = builder.Configuration["BackendUrl"] ?? "http://localhost:8080";

builder.Services.AddScoped(sp => new HttpClient
{
    BaseAddress = new Uri(backendUrl)
});

// Register backend service
builder.Services.AddScoped<GpuBackendService>();

// Add logging
builder.Logging.SetMinimumLevel(LogLevel.Information);

await builder.Build().RunAsync();
