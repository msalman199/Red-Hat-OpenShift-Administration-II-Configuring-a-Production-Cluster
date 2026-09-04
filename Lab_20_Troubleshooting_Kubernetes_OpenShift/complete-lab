Lab 20: Troubleshooting Kubernetes/OpenShift
Objectives
By the end of this lab, students will be able to:

• Use kubectl and oc commands to view logs, events, and pod status for troubleshooting • Identify common issues in pod networking, storage, and resource limits • Apply systematic troubleshooting methodologies to resolve Kubernetes/OpenShift problems • Implement fixes for common container orchestration issues • Understand the relationship between pods, services, and cluster resources • Diagnose and resolve storage-related problems in containerized environments

Prerequisites
Before starting this lab, students should have:

• Basic understanding of Kubernetes/OpenShift concepts (pods, services, deployments) • Familiarity with Linux command line operations • Knowledge of YAML configuration files • Understanding of container concepts and Docker basics • Access to a terminal or command prompt

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with pre-installed Kubernetes and OpenShift tools. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • Pre-configured Kubernetes cluster • kubectl and oc command-line tools • Sample applications with intentional issues for troubleshooting practice • All necessary permissions and access rights

Task 1: Using kubectl/oc to View Logs, Events, and Pod Status
Subtask 1.1: Examining Pod Status and Basic Information
First, let's explore the current state of pods in our cluster and understand how to gather basic troubleshooting information.

Step 1: Connect to your lab environment and verify cluster access

# Check cluster connection
kubectl cluster-info

# List all namespaces
kubectl get namespaces

# Set default namespace for this lab
kubectl config set-context --current --namespace=troubleshooting-lab
Step 2: Examine pod status across different namespaces

# View all pods in current namespace
kubectl get pods

# View pods with more detailed information
kubectl get pods -o wide

# View pods in all namespaces
kubectl get pods --all-namespaces

# Check pod status with additional details
kubectl get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,NODE:.spec.nodeName,IP:.status.podIP
Step 3: Get detailed information about specific pods

# Describe a specific pod (replace 'pod-name' with actual pod name)
kubectl describe pod <pod-name>

# View pod configuration in YAML format
kubectl get pod <pod-name> -o yaml

# Check pod resource usage
kubectl top pod <pod-name>
Subtask 1.2: Viewing and Analyzing Pod Logs
Understanding how to access and interpret pod logs is crucial for troubleshooting application issues.

Step 1: Access basic pod logs

# View logs from a specific pod
kubectl logs <pod-name>

# View logs from a specific container in a multi-container pod
kubectl logs <pod-name> -c <container-name>

# Follow logs in real-time
kubectl logs -f <pod-name>

# View logs from the previous container instance (useful if pod restarted)
kubectl logs <pod-name> --previous
Step 2: Advanced log viewing techniques

# View logs with timestamps
kubectl logs <pod-name> --timestamps=true

# View last 50 lines of logs
kubectl logs <pod-name> --tail=50

# View logs from the last hour
kubectl logs <pod-name> --since=1h

# View logs from multiple pods with same label
kubectl logs -l app=myapp --all-containers=true
Step 3: Create a problematic pod for log analysis

# Create a pod with logging issues
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: log-test-pod
  labels:
    app: log-test
spec:
  containers:
  - name: log-container
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Starting application..."
      sleep 10
      echo "ERROR: Database connection failed"
      sleep 5
      echo "WARNING: Retrying connection..."
      sleep 5
      echo "FATAL: Unable to start service"
      exit 1
  restartPolicy: Never
EOF

# Wait for pod to complete and examine logs
sleep 30
kubectl logs log-test-pod
Subtask 1.3: Examining Cluster Events
Events provide valuable information about what's happening in your cluster and can help identify issues.

Step 1: View cluster events

# View all events in current namespace
kubectl get events

# View events sorted by timestamp
kubectl get events --sort-by='.lastTimestamp'

# View events for a specific pod
kubectl get events --field-selector involvedObject.name=<pod-name>

# View events in all namespaces
kubectl get events --all-namespaces
Step 2: Filter and analyze events

# View only warning and error events
kubectl get events --field-selector type!=Normal

# View events from the last 30 minutes
kubectl get events --field-selector type!=Normal --sort-by='.lastTimestamp' | head -20

# Watch events in real-time
kubectl get events --watch
Step 3: Create a scenario to generate events

# Create a pod with resource issues to generate events
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: resource-test-pod
spec:
  containers:
  - name: memory-hog
    image: busybox
    command: ['sh', '-c', 'sleep 3600']
    resources:
      requests:
        memory: "1Gi"
        cpu: "500m"
      limits:
        memory: "2Gi"
        cpu: "1000m"
EOF

# Check events related to this pod
kubectl get events --field-selector involvedObject.name=resource-test-pod
Task 2: Identifying Issues in Pod Networking, Storage, and Resource Limits
Subtask 2.1: Diagnosing Networking Issues
Network connectivity problems are common in containerized environments. Let's learn how to identify and diagnose them.

Step 1: Create pods with networking issues

# Create a service and pod setup for networking tests
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: web-container
        image: nginx:alpine
        ports:
        - containerPort: 80
EOF
Step 2: Test network connectivity

# Check service endpoints
kubectl get endpoints web-service

# Describe the service
kubectl describe service web-service

# Test connectivity from within the cluster
kubectl run test-pod --image=busybox --rm -it --restart=Never -- sh

# Inside the test pod, run these commands:
# nslookup web-service
# wget -qO- http://web-service
# exit
Step 3: Diagnose DNS issues

# Check DNS configuration
kubectl get configmap coredns -n kube-system -o yaml

# Test DNS resolution
kubectl run dns-test --image=busybox --rm -it --restart=Never -- nslookup kubernetes.default

# Check if DNS pods are running
kubectl get pods -n kube-system -l k8s-app=kube-dns
Step 4: Examine network policies (if applicable)

# Check for network policies
kubectl get networkpolicies

# Create a test network policy
cat << EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Test connectivity after applying policy
kubectl run network-test --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service --timeout=5
Subtask 2.2: Identifying Storage Issues
Storage problems can prevent pods from starting or cause data loss. Let's explore common storage issues.

Step 1: Create pods with storage problems

# Create a pod with a non-existent persistent volume claim
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: storage-issue-pod
spec:
  containers:
  - name: app-container
    image: busybox
    command: ['sleep', '3600']
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: non-existent-pvc
EOF
Step 2: Diagnose storage issues

# Check pod status
kubectl get pod storage-issue-pod

# Describe the pod to see storage-related events
kubectl describe pod storage-issue-pod

# Check available persistent volumes and claims
kubectl get pv
kubectl get pvc

# Check storage classes
kubectl get storageclass
Step 3: Create a working storage example

# Create a persistent volume claim
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: working-pvc
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Create a pod that uses the PVC
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: storage-working-pod
spec:
  containers:
  - name: app-container
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Writing to persistent storage..."
      echo "Hello World" > /data/test.txt
      cat /data/test.txt
      sleep 3600
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: working-pvc
EOF

# Verify the pod starts successfully
kubectl get pod storage-working-pod
kubectl logs storage-working-pod
Subtask 2.3: Diagnosing Resource Limit Issues
Resource constraints can cause pods to fail or perform poorly. Let's identify and resolve these issues.

Step 1: Create pods with resource limit problems

# Create a pod that exceeds memory limits
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: memory-limit-pod
spec:
  containers:
  - name: memory-consumer
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Allocating memory..."
      dd if=/dev/zero of=/tmp/memory.tmp bs=1M count=200
      sleep 3600
    resources:
      requests:
        memory: "64Mi"
      limits:
        memory: "128Mi"
EOF
Step 2: Monitor resource usage and limits

# Check pod status
kubectl get pod memory-limit-pod

# Describe the pod to see resource-related events
kubectl describe pod memory-limit-pod

# Check resource usage (if metrics server is available)
kubectl top pod memory-limit-pod

# View resource quotas in the namespace
kubectl get resourcequota
kubectl describe resourcequota
Step 3: Create a pod with CPU limit issues

# Create a CPU-intensive pod with limits
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: cpu-limit-pod
spec:
  containers:
  - name: cpu-consumer
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Starting CPU intensive task..."
      while true; do
        echo "Computing..." > /dev/null
      done
    resources:
      requests:
        cpu: "100m"
      limits:
        cpu: "200m"
EOF

# Monitor the pod
kubectl get pod cpu-limit-pod
kubectl top pod cpu-limit-pod
Task 3: Resolving Issues and Applying Fixes
Subtask 3.1: Fixing Networking Issues
Now let's resolve the networking problems we identified earlier.

Step 1: Fix service selector issues

# Check current service configuration
kubectl get service web-service -o yaml

# Fix the service by updating the selector
kubectl patch service web-service -p '{"spec":{"selector":{"app":"web-app"}}}'

# Verify the fix
kubectl get endpoints web-service
kubectl describe service web-service
Step 2: Resolve DNS issues

# Remove the restrictive network policy
kubectl delete networkpolicy deny-all

# Test connectivity again
kubectl run connectivity-test --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service --timeout=10

# If DNS issues persist, restart CoreDNS pods
kubectl rollout restart deployment/coredns -n kube-system
Step 3: Fix port configuration issues

# Update the deployment to use correct ports
kubectl patch deployment web-app -p '{"spec":{"template":{"spec":{"containers":[{"name":"web-container","ports":[{"containerPort":80}]}]}}}}'

# Wait for rollout to complete
kubectl rollout status deployment/web-app

# Test the service again
kubectl run final-connectivity-test --image=busybox --rm -it --restart=Never -- wget -qO- http://web-service
Subtask 3.2: Resolving Storage Issues
Let's fix the storage problems we encountered.

Step 1: Clean up the problematic pod

# Delete the pod with storage issues
kubectl delete pod storage-issue-pod

# Check that the PVC we created earlier exists
kubectl get pvc working-pvc
Step 2: Create a properly configured pod with storage

# Ensure our PVC is bound
kubectl describe pvc working-pvc

# Create a new pod that properly uses storage
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: fixed-storage-pod
spec:
  containers:
  - name: app-container
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Testing persistent storage..."
      if [ -f /data/test.txt ]; then
        echo "Found existing data:"
        cat /data/test.txt
      else
        echo "Creating new data file..."
        echo "Persistent data created at $(date)" > /data/test.txt
      fi
      echo "Storage test completed successfully"
      sleep 3600
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: working-pvc
EOF

# Verify the pod starts and storage works
kubectl get pod fixed-storage-pod
kubectl logs fixed-storage-pod
Step 3: Test storage persistence

# Execute commands inside the pod to test storage
kubectl exec fixed-storage-pod -- ls -la /data
kubectl exec fixed-storage-pod -- cat /data/test.txt

# Delete and recreate the pod to test persistence
kubectl delete pod fixed-storage-pod

# Recreate the pod with the same PVC
kubectl apply -f - << EOF
apiVersion: v1
kind: Pod
metadata:
  name: persistence-test-pod
spec:
  containers:
  - name: app-container
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Checking for persistent data..."
      if [ -f /data/test.txt ]; then
        echo "SUCCESS: Data persisted!"
        cat /data/test.txt
      else
        echo "ERROR: Data was lost!"
      fi
      sleep 3600
    volumeMounts:
    - name: data-volume
      mountPath: /data
  volumes:
  - name: data-volume
    persistentVolumeClaim:
      claimName: working-pvc
EOF

kubectl logs persistence-test-pod
Subtask 3.3: Fixing Resource Limit Issues
Let's resolve the resource constraint problems.

Step 1: Fix memory limit issues

# Delete the problematic memory pod
kubectl delete pod memory-limit-pod

# Create a pod with appropriate memory limits
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: fixed-memory-pod
spec:
  containers:
  - name: memory-consumer
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Allocating reasonable amount of memory..."
      dd if=/dev/zero of=/tmp/memory.tmp bs=1M count=50
      echo "Memory allocation completed successfully"
      ls -lh /tmp/memory.tmp
      sleep 3600
    resources:
      requests:
        memory: "64Mi"
      limits:
        memory: "256Mi"
EOF

# Verify the pod starts successfully
kubectl get pod fixed-memory-pod
kubectl logs fixed-memory-pod
Step 2: Fix CPU limit issues

# Update the CPU-intensive pod with better resource management
kubectl delete pod cpu-limit-pod

cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: fixed-cpu-pod
spec:
  containers:
  - name: cpu-consumer
    image: busybox
    command: ['sh', '-c']
    args:
    - |
      echo "Starting controlled CPU task..."
      for i in {1..10}; do
        echo "Processing batch $i..."
        sleep 1
      done
      echo "CPU task completed successfully"
      sleep 3600
    resources:
      requests:
        cpu: "100m"
      limits:
        cpu: "500m"
EOF

# Monitor the fixed pod
kubectl get pod fixed-cpu-pod
kubectl logs fixed-cpu-pod
Step 3: Implement resource monitoring

# Create a script to monitor resource usage
cat << 'EOF' > monitor-resources.sh
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
EOF

chmod +x monitor-resources.sh
./monitor-resources.sh
Advanced Troubleshooting Techniques
Subtask 3.4: Using Debug Containers and Advanced Diagnostics
Step 1: Create a debug container for troubleshooting

# Create a problematic pod for debugging
cat << EOF | kubectl apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: debug-target-pod
spec:
  containers:
  - name: app-container
    image: nginx:alpine
    ports:
    - containerPort: 80
EOF

# Use kubectl debug to create a debug container (Kubernetes 1.20+)
kubectl debug debug-target-pod -it --image=busybox --target=app-container

# Alternative: Create a debug pod in the same network namespace
kubectl run debug-pod --image=busybox --rm -it --restart=Never -- sh
Step 2: Comprehensive cluster health check

# Create a comprehensive health check script
cat << 'EOF' > cluster-health-check.sh
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
EOF

chmod +x cluster-health-check.sh
./cluster-health-check.sh
Lab Cleanup
Step 1: Clean up all resources created during the lab

# Delete all pods created during the lab
kubectl delete pod log-test-pod resource-test-pod storage-working-pod fixed-storage-pod persistence-test-pod fixed-memory-pod fixed-cpu-pod debug-target-pod --ignore-not-found=true

# Delete deployments and services
kubectl delete deployment web-app --ignore-not-found=true
kubectl delete service web-service --ignore-not-found=true

# Delete PVC (this will also delete associated PV)
kubectl delete pvc working-pvc --ignore-not-found=true

# Clean up any remaining resources
kubectl delete all --all --ignore-not-found=true
Step 2: Verify cleanup

# Verify all resources are cleaned up
kubectl get all
kubectl get pvc
kubectl get events --sort-by='.lastTimestamp' | tail -5
Conclusion
In this comprehensive troubleshooting lab, you have successfully:

• Mastered diagnostic commands: You learned to use kubectl and oc commands to view logs, events, and pod status, which are essential skills for any Kubernetes administrator

• Identified common issues: You gained hands-on experience identifying problems in pod networking, storage configurations, and resource limits - the most frequent issues in production environments

• Applied systematic fixes: You learned to resolve issues methodically, from simple configuration corrections to complex resource management problems

• Developed troubleshooting methodology: You practiced a structured approach to problem-solving that includes gathering information, analyzing symptoms, and implementing targeted solutions

• Enhanced monitoring skills: You created monitoring scripts and learned to interpret cluster health indicators, preparing you for proactive system management

Why This Matters: Troubleshooting skills are critical for maintaining reliable containerized applications in production. The techniques you've learned will help you quickly identify and resolve issues, minimizing downtime and ensuring smooth operations. These skills are directly applicable to Red Hat OpenShift Administration and other enterprise Kubernetes environments.

Next Steps: Practice these troubleshooting techniques in different scenarios, explore advanced debugging tools like kubectl debug, and consider implementing monitoring solutions like Prometheus and Grafana for proactive issue detection.

The systematic approach you've learned here - gather information, analyze symptoms, implement fixes, and verify solutions - will serve you well in any containerized environment, whether you're working with OpenShift, vanilla Kubernetes, or other orchestration platforms.
