#!/bin/bash
echo "=== Pod Resource Monitoring ==="
echo "Timestamp: $(date)"
echo ""
echo "Pod Status:"
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,CPU-REQ:.spec.containers[0].resources.requests.cpu,MEM-REQ:.spec.containers[0].resources.requests.memory,CPU-LIM:.spec.containers[0].resources.limits.cpu,MEM-LIM:.spec.containers[0].resources.limits.memory

echo ""
echo "Resource Usage (if metrics available):"
kubectl top pods 2>/dev/null || echo "Metrics server not available"

echo ""
echo "Recent Events:"
kubectl get events --sort-by='.lastTimestamp' | tail -5
