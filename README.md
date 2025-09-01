# Ollama + Open WebUI Kubernetes Deployment

This repository contains Kubernetes manifests to deploy Ollama with Open WebUI on a local minikube cluster.

## Features

- 🚀 **Ollama** with qwen2:0.6b model pre-installed
- 🎨 **Open WebUI** for a user-friendly chat interface  
- 💾 **Persistent storage** for models and data
- 🔧 **Ready for minikube** with appropriate resource limits
- 🛡️ **Health checks** and proper service discovery

## Quick Start

### Prerequisites

- minikube running
- kubectl configured to use minikube context

### Deploy

```bash
# Make deployment script executable
chmod +x deploy.sh

# Deploy everything
./deploy.sh
```

### Access the Application

**Option 1: NodePort (Recommended for minikube)**
```bash
# Get minikube IP
minikube ip

# Access Open WebUI at: http://<minikube-ip>:30080
```

**Option 2: Port Forwarding**
```bash
# Forward Open WebUI port
kubectl port-forward -n ollama-system service/open-webui-service 8080:8080

# Access at: http://localhost:8080
```

### Verify Deployment

```bash
# Check pod status
kubectl get pods -n ollama-system

# Check services
kubectl get services -n ollama-system

# Check logs
kubectl logs -n ollama-system deployment/ollama
kubectl logs -n ollama-system deployment/open-webui
```

### Test Ollama API

```bash
# Port forward Ollama service
kubectl port-forward -n ollama-system service/ollama-service 11434:11434

# Test API
curl http://localhost:11434/api/version

# List available models
curl http://localhost:11434/api/tags

# Generate text
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "qwen3:0.6b",
    "prompt": "Explain Kubernetes in simple terms",
    "stream": false
  }'
```

## Architecture

```
┌─────────────────┐    ┌──────────────────┐
│   Open WebUI    │───▶│     Ollama       │
│   (Port 8080)   │    │   (Port 11434)   │
│                 │    │                  │
│  - Chat UI      │    │  - qwen3:0.6b    │
│  - User Mgmt    │    │  - API Server    │
└─────────────────┘    └──────────────────┘
         │                        │
         ▼                        ▼
┌─────────────────┐    ┌──────────────────┐
│  WebUI Storage  │    │  Model Storage   │
│   (2Gi PVC)     │    │   (10Gi PVC)     │
└─────────────────┘    └──────────────────┘
```

## Configuration

### Resource Requirements

**Ollama:**
- CPU: 1-4 cores
- Memory: 2-8Gi  
- Storage: 10Gi for models

**Open WebUI:**
- CPU: 250m-1 core
- Memory: 512Mi-2Gi
- Storage: 2Gi for data

### Environment Variables

**Open WebUI:**
- `OLLAMA_BASE_URL`: Points to Ollama service
- `WEBUI_AUTH`: Set to "False" for no-auth mode
- `WEBUI_SECRET_KEY`: Change this in production

**Ollama:**
- `OLLAMA_HOST`: Bind to all interfaces (0.0.0.0:11434)

## Troubleshooting

### Pods not starting
```bash
kubectl describe pod -n ollama-system <pod-name>
kubectl logs -n ollama-system <pod-name>
```

### Model not downloading
```bash
# Check init container logs
kubectl logs -n ollama-system <ollama-pod> -c model-puller

# Manually pull model
kubectl exec -n ollama-system deployment/ollama -- ollama pull qwen3:0.6b
```

### Storage issues
```bash
# Check PVC status
kubectl get pvc -n ollama-system

# Check available storage in minikube
minikube ssh
df -h
```

## Cleanup

```bash
# Make cleanup script executable
chmod +x cleanup.sh

# Remove everything
./cleanup.sh
```

## Production Considerations

For production deployments, consider:

1. **Security**: Enable authentication (`WEBUI_AUTH=True`)
2. **Resources**: Increase CPU/memory limits based on usage
3. **Storage**: Use appropriate storage classes
4. **Ingress**: Use proper ingress controllers instead of NodePort
5. **Monitoring**: Add Prometheus metrics and health checks
6. **Backup**: Regular backup of persistent volumes

## Models

This deployment uses the lightweight qwen3:0.6b model (~600MB). You can modify the ConfigMap to use different models:

- `qwen2:1.5b` - Larger but more capable
- `llama3.2:1b` - Alternative small model  
- `phi3:3.8b` - Microsoft's Phi-3 model

```bash
# Add more models after deployment
kubectl exec -n ollama-system deployment/ollama -- ollama pull <model-name>
```
