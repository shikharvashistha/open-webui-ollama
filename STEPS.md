# Complete Kubernetes Deployment Guide: Ollama + Open WebUI

This guide provides a complete Kubernetes deployment for running Ollama (with qwen3:0.6b model) and Open WebUI on your local minikube cluster, following the structure similar to the Nanuchi tutorial series.

## 🏗️ Architecture Overview

The deployment consists of:
- **Namespace**: `ollama-system` for isolation
- **Ollama Service**: AI model serving with qwen3:0.6b pre-loaded
- **Open WebUI Service**: User-friendly chat interface
- **Persistent Storage**: Model and data persistence
- **ConfigMap**: Automated model downloading
- **Services**: Internal and external access

## 📁 File Structure

```
kubernetes-ollama-deployment/
├── 00-namespace.yaml           # Namespace creation
├── 01-persistent-volumes.yaml  # Storage definitions
├── 02-configmap.yaml          # Ollama initialization script
├── 03-ollama-deployment.yaml  # Ollama deployment
├── 04-open-webui-deployment.yaml # Open WebUI deployment
├── 05-services.yaml           # Service definitions
├── deploy.sh                  # Deployment script
├── cleanup.sh                 # Cleanup script
└── README.md                  # Documentation
```

## 🚀 Quick Start

### Prerequisites
- minikube installed and running
- kubectl configured for minikube context
- At least 4GB RAM and 2 CPU cores available for minikube

### Step 1: Start Minikube
```bash
# Start with adequate resources
minikube start --cpus=4 --memory=8192

# Verify it's running
minikube status
```

### Step 2: Deploy the Stack
```bash
# Make the deploy script executable
chmod +x deploy.sh

# Deploy everything
./deploy.sh
```

### Step 3: Monitor Deployment
```bash
# Watch pods starting up
kubectl get pods -n ollama-system -w

# Check services
kubectl get services -n ollama-system

# Check persistent volumes
kubectl get pvc -n ollama-system
```

### Step 4: Access the Application

**Option A: Using Minikube IP (Recommended)**
```bash
# Get minikube IP
minikube ip

# Access Open WebUI at: http://<minikube-ip>:30080
```

**Option B: Port Forwarding**
```bash
# Forward Open WebUI
kubectl port-forward -n ollama-system service/open-webui-service 8080:8080

# Access at: http://localhost:8080
```

## 🔧 Configuration Details

### Resource Allocation
- **Ollama**: 1-4 CPU, 2-8Gi RAM, 10Gi storage
- **Open WebUI**: 250m-1 CPU, 512Mi-2Gi RAM, 2Gi storage

### Environment Variables
- `OLLAMA_BASE_URL`: Points Open WebUI to Ollama service
- `WEBUI_AUTH`: Set to "False" for no-auth mode (change for production)
- `OLLAMA_HOST`: Binds to all interfaces

### Model Configuration
The deployment automatically pulls the **qwen3:0.6b** model (~600MB) during initialization.

## 🧪 Testing the Deployment

### Test Ollama API
```bash
# Port forward Ollama
kubectl port-forward -n ollama-system service/ollama-service 11434:11434

# Check version
curl http://localhost:11434/api/version

# List models
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

### Test Open WebUI
1. Access the web interface
2. Create an account (first user becomes admin)
3. Start chatting with the qwen3:0.6b model

## 🐛 Troubleshooting

### Common Issues

**Pods not starting:**
```bash
kubectl describe pod -n ollama-system <pod-name>
kubectl logs -n ollama-system <pod-name>
```

**Model not downloading:**
```bash
# Check init container logs
kubectl logs -n ollama-system <ollama-pod> -c model-puller

# Manually pull model if needed
kubectl exec -n ollama-system deployment/ollama -- ollama pull qwen3:0.6b
```

**Storage issues:**
```bash
# Check PVC status
kubectl get pvc -n ollama-system

# Check minikube disk space
minikube ssh
df -h
```

**Can't access via NodePort:**
- Ensure minikube is using the correct driver
- Check firewall settings
- Try port forwarding as alternative

### Service Discovery Issues
If Open WebUI can't connect to Ollama:
1. Verify both pods are running
2. Check service endpoints: `kubectl get endpoints -n ollama-system`
3. Test internal connectivity: `kubectl exec -n ollama-system deployment/open-webui -- nslookup ollama-service`

## 🔒 Production Considerations

For production deployments:

1. **Security**: 
   - Enable authentication (`WEBUI_AUTH=True`)
   - Use secrets for sensitive data
   - Implement RBAC

2. **Resources**: 
   - Scale based on load
   - Use appropriate resource limits
   - Consider using larger models

3. **Storage**: 
   - Use appropriate StorageClasses
   - Implement backup strategies
   - Consider using remote storage

4. **Networking**: 
   - Use Ingress controllers instead of NodePort
   - Implement proper SSL/TLS
   - Set up monitoring and logging

## 🧹 Cleanup

To remove the entire deployment:
```bash
# Make cleanup script executable
chmod +x cleanup.sh

# Remove everything
./cleanup.sh
```

## 📊 Resource Monitoring

Monitor resource usage:
```bash
# Check resource usage
kubectl top pods -n ollama-system

# Check node resources
kubectl describe node minikube

# Monitor events
kubectl get events -n ollama-system --sort-by='.firstTimestamp'
```

## 🔄 Scaling and Updates

### Scaling Open WebUI
```bash
kubectl scale deployment open-webui -n ollama-system --replicas=2
```

### Adding More Models
```bash
# Add models to running Ollama
kubectl exec -n ollama-system deployment/ollama -- ollama pull llama3.2:1b
```

### Updating Images
```bash
# Update Open WebUI
kubectl set image deployment/open-webui -n ollama-system open-webui=ghcr.io/open-webui/open-webui:latest

# Restart deployments
kubectl rollout restart deployment/ollama -n ollama-system
```

## 🎯 Next Steps

1. **Explore Models**: Try different Ollama models
2. **Customize UI**: Configure Open WebUI settings
3. **Add Monitoring**: Implement Prometheus/Grafana
4. **Network Policies**: Enhance security
5. **Backup Strategy**: Implement data backup

This deployment provides a solid foundation for running AI models locally with Kubernetes, similar to the patterns shown in the Nanuchi tutorial series but optimized for AI workloads.