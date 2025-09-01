#!/bin/bash

echo "Deploying Ollama and Open WebUI to Kubernetes..."

# Apply all YAML files in order
kubectl apply -f 00-namespace.yaml
echo "✅ Namespace created"

kubectl apply -f 01-persistent-volumes.yaml
echo "✅ Persistent volumes created"

kubectl apply -f 02-configmap.yaml
echo "✅ ConfigMap created"

kubectl apply -f 03-ollama-deployment.yaml
echo "✅ Ollama deployment created"

kubectl apply -f 04-open-webui-deployment.yaml
echo "✅ Open WebUI deployment created"

kubectl apply -f 05-services.yaml
echo "✅ Services created"

echo "
🎉 Deployment completed!

To check the status:
  kubectl get pods -n ollama-system
  kubectl get services -n ollama-system

To access Open WebUI:
  # Get minikube IP
  minikube ip
  
  # Then access: http://<minikube-ip>:30080
  
  # Or use port forwarding:
  kubectl port-forward -n ollama-system service/open-webui-service 8080:8080
  # Then access: http://localhost:8080

To check Ollama directly:
  kubectl port-forward -n ollama-system service/ollama-service 11434:11434
  curl http://localhost:11434/api/version
  
To check logs:
  kubectl logs -n ollama-system deployment/ollama
  kubectl logs -n ollama-system deployment/open-webui
"
