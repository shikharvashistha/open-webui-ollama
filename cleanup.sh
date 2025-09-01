#!/bin/bash

echo "Cleaning up Ollama and Open WebUI deployment..."

kubectl delete -f 05-services.yaml
kubectl delete -f 04-open-webui-deployment.yaml  
kubectl delete -f 03-ollama-deployment.yaml
kubectl delete -f 02-configmap.yaml
kubectl delete -f 01-persistent-volumes.yaml
kubectl delete -f 00-namespace.yaml

echo "✅ Cleanup completed!"
