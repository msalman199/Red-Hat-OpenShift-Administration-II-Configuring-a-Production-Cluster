#!/bin/bash
echo "=== Kubernetes Cluster Health Check ==="
echo "Timestamp: $(date)"
echo ""

echo "1. Cluster Info:"
kubectl cluster-info

echo ""
echo "2. Node Status:"
kubectl get nodes -o wide

echo ""
echo "3. System Pods Status:"
kubectl get pods -n kube-system

echo ""
echo "4. Resource Usage:"
kubectl top nodes 2>/dev/null || echo "Metrics server not available"

echo ""
echo "5. Recent Cluster Events:"
kubectl get events --all-namespaces --sort-by='.lastTimestamp' | tail -10

echo ""
echo "6. Persistent Volumes:"
kubectl get pv

echo ""
echo "7. Storage Classes:"
kubectl get storageclass

echo ""
echo "Health check completed!"
