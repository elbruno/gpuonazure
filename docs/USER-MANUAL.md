# User Manual - GPU-Accelerated AI Platform

This comprehensive user manual provides visual guides and step-by-step instructions for using all features of the GPU-accelerated AI platform.

## Table of Contents

- [Getting Started](#getting-started)
- [Aspire Dashboard](#aspire-dashboard)
- [Blazor Frontend](#blazor-frontend)
- [JavaScript WebUI](#javascript-webui)
- [Common Tasks](#common-tasks)

---

## Getting Started

### Starting the Application with Aspire

The easiest way to run the entire application stack is using .NET Aspire orchestration.

**Steps:**

1. Open a terminal in the project root directory
2. Navigate to the Aspire AppHost:
   ```bash
   cd src/GpuAzure.AppHost
   ```
3. Start all services:
   ```bash
   dotnet run
   ```

**What happens:**
- Aspire Dashboard opens automatically in your browser
- Java Spring Boot backend starts on port 8080
- Blazor WebAssembly frontend starts on ports 5000/5001
- All services register with service discovery
- Health checks begin monitoring

**Expected output:**
```
info: Aspire.Hosting.DistributedApplication[0]
      Aspire version: 13.0.1
info: Aspire.Hosting.DistributedApplication[0]
      Distributed application starting...
info: Aspire.Hosting.DistributedApplication[0]
      Application host directory is: /home/user/gpuonazure/src/GpuAzure.AppHost
info: Aspire.Hosting.DistributedApplication[0]
      Now listening on: http://localhost:15000
info: Aspire.Hosting.DistributedApplication[0]
      Login to the dashboard at http://localhost:15000
```

**Screenshot Location**: `images/user-manual/01-aspire-startup.png`
_TODO: Screenshot showing Aspire startup in terminal_

---

## Aspire Dashboard

The Aspire Dashboard provides a unified view of all services, logs, metrics, and distributed traces.

### Accessing the Dashboard

**URL:** http://localhost:15000

The dashboard opens automatically when you start Aspire. If it doesn't, manually navigate to the URL above.

### Dashboard Overview

The dashboard consists of several tabs:

#### 1. Resources Tab

**Screenshot Location**: `images/user-manual/02-aspire-resources.png`
_TODO: Screenshot of Aspire Dashboard Resources view showing all running services_

The Resources tab shows:
- **Service Name**: Identifies each service (java-backend, blazor-frontend)
- **Type**: Executable, Project, or Container
- **State**: Running, Starting, or Stopped
- **Endpoints**: HTTP/HTTPS URLs for accessing each service
- **Console Logs**: Quick access to service logs

**Features:**
- Click service name to view details
- Click endpoint URLs to open in browser
- View environment variables
- Restart or stop services

#### 2. Console Logs Tab

**Screenshot Location**: `images/user-manual/03-aspire-logs.png`
_TODO: Screenshot of Aspire Dashboard Console Logs with filtered view_

The Console tab displays:
- Real-time log streaming from all services
- Color-coded by log level (INFO, WARN, ERROR)
- Search and filter capabilities
- Service selection dropdown

**How to use:**
1. Select service from dropdown (or "All" for combined view)
2. Use search box to filter logs
3. Click log level badges to filter by severity
4. Auto-scroll toggle for live updates

**Common scenarios:**
- **Debugging errors**: Filter by ERROR level, search for exception names
- **Performance monitoring**: Watch INFO logs for response times
- **Service health**: Monitor startup and shutdown messages

#### 3. Traces Tab

**Screenshot Location**: `images/user-manual/04-aspire-traces.png`
_TODO: Screenshot of distributed tracing view showing request flow_

The Traces tab shows:
- End-to-end request tracing across services
- Service dependencies and call chains
- Performance bottlenecks
- Error traces highlighted

**How to use:**
1. Click on a trace to expand details
2. View timeline of operations
3. Identify slow components
4. Drill down into specific spans

**Example trace:**
```
Request: POST /api/langchain4j/image
├─ Blazor Frontend (5ms)
│  └─ HTTP POST to Java Backend
└─ Java Backend (2,345ms)
   ├─ Text Tokenization (45ms)
   ├─ U-Net Inference (2,200ms)  ← Bottleneck
   └─ VAE Decoding (100ms)
```

#### 4. Metrics Tab

**Screenshot Location**: `images/user-manual/05-aspire-metrics.png`
_TODO: Screenshot of metrics dashboard with charts_

The Metrics tab displays:
- CPU usage per service
- Memory consumption
- HTTP request rates
- Response times (p50, p95, p99)
- Custom application metrics

**Available charts:**
- Request duration histogram
- Requests per second
- Memory usage over time
- CPU utilization

#### 5. Structured Logs Tab

**Screenshot Location**: `images/user-manual/06-aspire-structured-logs.png`
_TODO: Screenshot of structured logs with expanded JSON_

Enhanced log view with:
- JSON-formatted log entries
- Expandable properties
- Context preservation
- Correlation IDs for request tracing

---

## Blazor Frontend

The Blazor WebAssembly frontend provides a modern, interactive interface for the AI platform.

### Accessing the Blazor Frontend

**URLs:**
- HTTP: http://localhost:5000
- HTTPS: https://localhost:5001

### Home Page

**Screenshot Location**: `images/user-manual/07-blazor-home.png`
_TODO: Screenshot of Blazor home page with feature cards_

The home page features:
- Welcome message and project overview
- Three feature cards:
  - Image Generator
  - Text Embeddings  
  - System Metrics
- Key features list
- Architecture overview
- Quick navigation

**Navigation:**
- Click feature cards to navigate to respective pages
- Use navigation menu (left sidebar or top on mobile)
- All pages responsive and mobile-friendly

### Image Generator

**Screenshot Location**: `images/user-manual/08-blazor-image-generator.png`
_TODO: Screenshot of Image Generator page with form and sample prompts_

**URL:** http://localhost:5000/image-generator

**Features:**
- Text prompt input (multi-line textarea)
- Style selection dropdown:
  - Classic
  - Happy
  - Confused
  - Excited
- Real-time progress indicator during generation
- Image preview with download button
- Sample prompts for quick testing
- Generation time display

**How to generate an image:**

1. Enter a descriptive prompt:
   ```
   Example: "A friendly robot helping with Azure deployment"
   ```

2. Select a style from the dropdown

3. Click "Generate Image" button

4. Wait for generation (30-60 seconds on CPU, 2-5 seconds on GPU)

5. Image appears with download option

**Screenshot Location**: `images/user-manual/09-blazor-image-generating.png`
_TODO: Screenshot showing loading state with spinner and progress message_

**Screenshot Location**: `images/user-manual/10-blazor-image-result.png`
_TODO: Screenshot showing generated image with download button_

**Tips:**
- Be specific in prompts for better results
- Try sample prompts to see different styles
- Download button saves as PNG
- Generation time varies based on CPU/GPU mode

### Text Embeddings

**Screenshot Location**: `images/user-manual/11-blazor-embeddings.png`
_TODO: Screenshot of Embeddings page with two text inputs and sample buttons_

**URL:** http://localhost:5000/embeddings

**Features:**
- Two text input fields for comparison
- Semantic similarity calculation (0-100%)
- Color-coded progress bar:
  - Green (90-100%): Very similar
  - Cyan (70-90%): Strong similarity
  - Yellow (50-70%): Moderate similarity
  - Red (0-50%): Low similarity
- Interpretation guide
- Sample comparison buttons

**How to compare texts:**

1. Enter first text in "Text 1" field:
   ```
   Example: "GPU acceleration"
   ```

2. Enter second text in "Text 2" field:
   ```
   Example: "CUDA processing"
   ```

3. Click "Compare Similarity" button

4. View similarity score and visual representation

**Screenshot Location**: `images/user-manual/12-blazor-embeddings-result.png`
_TODO: Screenshot showing similarity result with colored progress bar and percentage_

**Understanding similarity scores:**
- **90-100%**: Very similar or nearly identical meaning
- **70-90%**: Strong semantic similarity (related concepts)
- **50-70%**: Moderate similarity (some overlap)
- **0-50%**: Low similarity (different topics)

**Example comparisons:**
- "GPU acceleration" vs "CUDA processing" → ~87% (high similarity)
- "Machine learning" vs "Artificial intelligence" → ~72% (strong similarity)
- "Cloud computing" vs "Pizza delivery" → ~15% (low similarity)

### System Metrics

**Screenshot Location**: `images/user-manual/13-blazor-metrics.png`
_TODO: Screenshot of System Metrics dashboard with all status indicators_

**URL:** http://localhost:5000/metrics

**Features:**
- Real-time system status
- GPU availability indicator
- Models loaded status
- ONNX Runtime version
- Backend connection health
- Auto-refresh every 10 seconds
- Manual refresh button

**Status Indicators:**

1. **GPU Status:**
   - Green: "Available" (GPU detected and functional)
   - Yellow: "Not Available (CPU Mode)" (running on CPU)

2. **Models Status:**
   - Green: "Loaded" (all models initialized)
   - Red: "Not Loaded" (model loading failed)

3. **AI Models Section:**
   - Stable Diffusion v1.5
     - Provider: SD4J (Oracle)
     - Status: Ready/Not initialized
   - All-MiniLM-L6-v2
     - Provider: LangChain4j (HuggingFace)
     - Model: All-MiniLM-L6-v2

4. **Backend Connection:**
   - Green: "Connected" (Java backend responding)
   - Red: "Disconnected" (backend not reachable)

**Screenshot Location**: `images/user-manual/14-blazor-metrics-gpu-mode.png`
_TODO: Screenshot showing metrics with GPU enabled_

---

## JavaScript WebUI

The JavaScript WebUI provides a lightweight, no-build-required interface served directly by the Java backend.

### Accessing JavaScript WebUI

**URL:** http://localhost:8080

**Screenshot Location**: `images/user-manual/15-javascript-webui.png`
_TODO: Screenshot of JavaScript WebUI home page_

### Features

The JavaScript WebUI includes:
- Image generation form
- Style selection
- System metrics panel at top
- Real-time status updates
- Inline image display
- Minimal dependencies (vanilla JavaScript)

### System Metrics Panel

**Screenshot Location**: `images/user-manual/16-javascript-metrics-panel.png`
_TODO: Screenshot of metrics panel at top of page_

Displays at the top of the page:
- GPU Status: Available/Not Available
- Models Loaded: Yes/No
- Stable Diffusion: Ready/Not Ready
- Embeddings Model: Available/Not Available

**Colors:**
- Green: Operational
- Orange: Loading or CPU mode
- Red: Error or not available

### Image Generation

**Screenshot Location**: `images/user-manual/17-javascript-image-form.png`
_TODO: Screenshot of image generation form_

**Form fields:**
1. **Prompt** (textarea):
   - Enter descriptive text for image
   - Multi-line input supported
   - Placeholder: "Describe your image..."

2. **Style** (dropdown):
   - Classic
   - Happy
   - Confused
   - Excited

3. **Generate Button**:
   - Submits request to backend
   - Shows loading spinner during generation
   - Displays result inline

**Screenshot Location**: `images/user-manual/18-javascript-image-generating.png`
_TODO: Screenshot showing loading state with spinner_

**Screenshot Location**: `images/user-manual/19-javascript-image-result.png`
_TODO: Screenshot showing generated image result_

### Differences from Blazor Frontend

| Feature | JavaScript WebUI | Blazor Frontend |
|---------|------------------|-----------------|
| Build Process | None (static files) | .NET build required |
| Loading Time | Instant | ~2-3 seconds (first load) |
| Functionality | Basic features | Full features + metrics |
| Dependencies | None | .NET runtime (WASM) |
| Use Case | Quick access | Primary interface |
| Styling | Custom CSS | Bootstrap 5 |

---

## Common Tasks

### Generating Your First Image

1. **Start Aspire:**
   ```bash
   cd src/GpuAzure.AppHost
   dotnet run
   ```

2. **Wait for services to start** (watch Aspire Dashboard)

3. **Open Blazor Frontend:** http://localhost:5000

4. **Navigate to Image Generator**

5. **Enter prompt:**
   ```
   A friendly robot helping with Azure deployment
   ```

6. **Select style:** Classic

7. **Click "Generate Image"**

8. **Wait** (~30-60 seconds on CPU, ~2-5 seconds on GPU)

9. **Download or regenerate**

**Screenshot Location**: `images/user-manual/20-first-image-generation.png`
_TODO: Screenshot sequence showing the full process_

### Comparing Text Similarity

1. **Navigate to Embeddings page**

2. **Try the sample comparison** (high similarity):
   - Text 1: "GPU acceleration"
   - Text 2: "CUDA processing"

3. **Click "Try Example" button** (auto-fills fields)

4. **Click "Compare Similarity"**

5. **Observe result** (~87% similarity)

6. **Try other examples** to see different similarity levels

### Monitoring System Health

1. **Open Aspire Dashboard:** http://localhost:15000

2. **Check Resources tab:**
   - All services should show "Running" state
   - Endpoints should be clickable

3. **View Console Logs:**
   - Filter by service
   - Look for ERROR or WARN messages

4. **Check Blazor Metrics page:**
   - GPU Status
   - Models Loaded
   - Backend Connection

**Screenshot Location**: `images/user-manual/21-health-monitoring.png`
_TODO: Screenshot showing healthy system across all dashboards_

### Troubleshooting Failed Image Generation

**Scenario:** Image generation fails or returns error

**Steps:**

1. **Check Aspire Console Logs:**
   - Select "java-backend" from dropdown
   - Filter by "ERROR"
   - Look for exception stack traces

**Screenshot Location**: `images/user-manual/22-troubleshooting-logs.png`
_TODO: Screenshot showing error in logs_

2. **Check System Metrics:**
   - Open http://localhost:5000/metrics
   - Verify "Models Loaded" shows "Loaded"
   - Verify "Backend Connection" shows "Connected"

3. **Check Backend Health:**
   ```bash
   curl http://localhost:8080/api/langchain4j/health
   ```
   Should return: `{"status":"UP"}`

4. **Common issues:**
   - **Models not found:** Run `./scripts/download-missing-models.sh`
   - **ONNX extensions missing:** Run `./scripts/download-ortextensions.sh`
   - **Out of memory:** Reduce image size or use GPU mode
   - **Backend not responding:** Check if port 8080 is in use

### Switching Between CPU and GPU Modes

**Enable GPU mode:**

1. **Edit AppHost configuration:**
   ```csharp
   // File: src/GpuAzure.AppHost/AppHost.cs
   .WithEnvironment("GPU_LANGCHAIN4J_GPU_ENABLED", "true")  // Change to true
   ```

2. **Restart Aspire:**
   ```bash
   # Press Ctrl+C to stop
   dotnet run  # Start again
   ```

3. **Verify in metrics:**
   - GPU Status should show "Available"

**Requirements for GPU mode:**
- NVIDIA GPU with CUDA 12.6+ support
- NVIDIA drivers installed
- CUDA toolkit installed
- Enough VRAM (8GB minimum)

### Using Different Frontend Options

**Option 1: Blazor (Recommended)**
- URL: http://localhost:5000
- Full feature set
- Modern UI with Bootstrap 5
- Real-time updates

**Option 2: JavaScript WebUI**
- URL: http://localhost:8080
- Lightweight and fast
- No build process
- Basic features only

**Option 3: Direct API Access**
```bash
# Generate image
curl -X POST http://localhost:8080/api/langchain4j/image \
  -H "Content-Type: application/json" \
  -d '{"prompt":"test prompt","style":"CLASSIC"}' \
  --output image.png

# Compare embeddings
curl -X POST http://localhost:8080/api/langchain4j/embeddings \
  -H "Content-Type: application/json" \
  -d '{"text1":"GPU","text2":"CUDA"}'
```

---

## Tips and Best Practices

### For Better Image Generation

1. **Be specific in prompts:**
   - Good: "A blue robot with friendly smile in a modern office"
   - Bad: "A robot"

2. **Use style appropriately:**
   - Classic: Neutral, balanced
   - Happy: Bright, cheerful tones
   - Excited: Dynamic, energetic
   - Confused: Quirky, unusual

3. **First generation slower:**
   - Model loading adds 10-20 seconds
   - Subsequent generations faster
   - GPU mode significantly faster

### For System Performance

1. **Monitor resource usage in Aspire Dashboard**
2. **Close unused browser tabs** (reduces memory)
3. **Use GPU mode for production** (much faster)
4. **Check Aspire logs regularly** for warnings

### For Development

1. **Use Aspire for local development** (easiest)
2. **Watch Console Logs** for real-time debugging
3. **Use hot reload** (`dotnet watch run` for Blazor)
4. **Test with sample prompts first** before custom ones

---

## Keyboard Shortcuts

### Aspire Dashboard
- `Ctrl+F` / `Cmd+F`: Search logs
- `Ctrl+R` / `Cmd+R`: Refresh page
- `Esc`: Close modal dialogs

### Blazor Frontend
- `Tab`: Navigate between form fields
- `Enter`: Submit form (when focused on button)
- `Ctrl+C` / `Cmd+C`: Copy image URL

### Terminal (Aspire)
- `Ctrl+C`: Stop all services
- `↑` / `↓`: Navigate command history

---

## Next Steps

- **Read:** [Architecture Documentation](./ARCHITECTURE.md)
- **Learn:** [DevContainer Setup](./HOW-TO-RUN-DEVCONTAINER.md)
- **Deploy:** [Azure Deployment Guide](./AZURE-DEPLOYMENT-GUIDE.md)
- **Develop:** [Blazor Frontend Guide](./BLAZOR-FRONTEND.md)

---

## Feedback and Support

If you encounter issues or have suggestions:
1. Check [Troubleshooting](#troubleshooting-failed-image-generation) section
2. View [HOW-TO-RUN-DEVCONTAINER.md](./HOW-TO-RUN-DEVCONTAINER.md) for detailed troubleshooting
3. Open an issue on GitHub
4. Consult Aspire Dashboard logs for detailed error information

---

**Note:** Screenshots marked with "TODO" will be added when services are running. Placeholders indicate where screenshots should be inserted.

**Screenshot Index:**
- 01-20: Aspire and UI screenshots
- 21-22: Troubleshooting and monitoring
- All images should be saved to `images/user-manual/` directory
