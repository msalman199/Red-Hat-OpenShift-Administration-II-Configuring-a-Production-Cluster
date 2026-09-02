Lab 8: Exposing Non-HTTP Applications (NodePort/LoadBalancer)
Objectives
By the end of this lab, you will be able to:

• Deploy TCP and UDP applications in a Kubernetes cluster • Understand the differences between NodePort and LoadBalancer service types • Configure NodePort services to expose applications on specific ports • Configure LoadBalancer services for external access • Test connectivity to non-HTTP applications through different service types • Troubleshoot common issues with service exposure • Understand port mapping and traffic routing for non-HTTP protocols

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Services, Deployments) • Familiarity with command-line interface operations • Knowledge of TCP/UDP networking fundamentals • Understanding of YAML configuration files • Basic Linux command-line skills

Ready-to-Use Cloud Machines
Al Nafi provides pre-configured Linux-based cloud machines with Kubernetes already installed and configured. Simply click Start Lab to access your environment. No need to build your own VM or install additional software - everything is ready to use!

Your lab environment includes: • Kubernetes cluster with multiple nodes • kubectl command-line tool pre-configured • All necessary networking components • Administrative access to the cluster

Task 1: Deploy a TCP/UDP Application
Subtask 1.1: Create a TCP Application (Redis Database)
First, we'll deploy Redis, a popular in-memory database that uses TCP protocol.

Create a directory for your lab files:
mkdir lab8-services
cd lab8-services
Create a Redis deployment configuration file:
cat > redis-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: redis-tcp-app
  labels:
    app: redis-tcp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: redis-tcp
  template:
    metadata:
      labels:
        app: redis-tcp
    spec:
      containers:
      - name: redis
        image: redis:7-alpine
        ports:
        - containerPort: 6379
          protocol: TCP
        command: ["redis-server"]
        args: ["--bind", "0.0.0.0", "--protected-mode", "no"]
        resources:
          requests:
            memory: "64Mi"
            cpu: "50m"
          limits:
            memory: "128Mi"
            cpu: "100m"
EOF
Deploy the Redis application:
kubectl apply -f redis-deployment.yaml
Verify the deployment is running:
kubectl get deployments
kubectl get pods -l app=redis-tcp
Subtask 1.2: Create a UDP Application (DNS Server)
Now we'll deploy a simple DNS server that uses UDP protocol.

Create a DNS server deployment configuration:
cat > dns-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dns-udp-app
  labels:
    app: dns-udp
spec:
  replicas: 1
  selector:
    matchLabels:
      app: dns-udp
  template:
    metadata:
      labels:
        app: dns-udp
    spec:
      containers:
      - name: dnsmasq
        image: andyshinn/dnsmasq:2.85
        ports:
        - containerPort: 53
          protocol: UDP
        - containerPort: 53
          protocol: TCP
        args:
          - --keep-in-foreground
          - --log-queries
          - --no-resolv
          - --address=/test.local/1.2.3.4
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
          limits:
            memory: "64Mi"
            cpu: "50m"
EOF
Deploy the DNS application:
kubectl apply -f dns-deployment.yaml
Verify both applications are running:
kubectl get deployments
kubectl get pods
Subtask 1.3: Create a Mixed Protocol Application (Echo Server)
Let's create an echo server that handles both TCP and UDP traffic.

Create an echo server deployment:
cat > echo-deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: echo-mixed-app
  labels:
    app: echo-mixed
spec:
  replicas: 2
  selector:
    matchLabels:
      app: echo-mixed
  template:
    metadata:
      labels:
        app: echo-mixed
    spec:
      containers:
      - name: echo-server
        image: mendhak/tcp-udp-test:1
        ports:
        - containerPort: 2701
          protocol: TCP
        - containerPort: 2701
          protocol: UDP
        env:
        - name: TCP_PORT
          value: "2701"
        - name: UDP_PORT
          value: "2701"
        resources:
          requests:
            memory: "32Mi"
            cpu: "25m"
          limits:
            memory: "64Mi"
            cpu: "50m"
EOF
Deploy the echo server:
kubectl apply -f echo-deployment.yaml
Verify all applications are running:
kubectl get pods -o wide
Task 2: Expose Applications via NodePort and LoadBalancer
Subtask 2.1: Create NodePort Services
NodePort services expose applications on a specific port on all cluster nodes.

Create a NodePort service for the Redis TCP application:
cat > redis-nodeport-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: redis-nodeport-svc
  labels:
    app: redis-tcp
spec:
  type: NodePort
  selector:
    app: redis-tcp
  ports:
  - port: 6379
    targetPort: 6379
    nodePort: 30379
    protocol: TCP
    name: redis-tcp
EOF
Create a NodePort service for the DNS UDP application:
cat > dns-nodeport-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: dns-nodeport-svc
  labels:
    app: dns-udp
spec:
  type: NodePort
  selector:
    app: dns-udp
  ports:
  - port: 53
    targetPort: 53
    nodePort: 30053
    protocol: UDP
    name: dns-udp
  - port: 53
    targetPort: 53
    nodePort: 30054
    protocol: TCP
    name: dns-tcp
EOF
Create a NodePort service for the echo server (mixed protocols):
cat > echo-nodeport-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: echo-nodeport-svc
  labels:
    app: echo-mixed
spec:
  type: NodePort
  selector:
    app: echo-mixed
  ports:
  - port: 2701
    targetPort: 2701
    nodePort: 30701
    protocol: TCP
    name: echo-tcp
  - port: 2701
    targetPort: 2701
    nodePort: 30702
    protocol: UDP
    name: echo-udp
EOF
Apply all NodePort services:
kubectl apply -f redis-nodeport-service.yaml
kubectl apply -f dns-nodeport-service.yaml
kubectl apply -f echo-nodeport-service.yaml
Verify the services are created:
kubectl get services
kubectl get services -o wide
Subtask 2.2: Create LoadBalancer Services
LoadBalancer services provide external access through cloud provider load balancers.

Create a LoadBalancer service for Redis:
cat > redis-loadbalancer-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: redis-loadbalancer-svc
  labels:
    app: redis-tcp
spec:
  type: LoadBalancer
  selector:
    app: redis-tcp
  ports:
  - port: 6379
    targetPort: 6379
    protocol: TCP
    name: redis-tcp
EOF
Create a LoadBalancer service for the DNS server:
cat > dns-loadbalancer-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: dns-loadbalancer-svc
  labels:
    app: dns-udp
spec:
  type: LoadBalancer
  selector:
    app: dns-udp
  ports:
  - port: 53
    targetPort: 53
    protocol: UDP
    name: dns-udp
  - port: 5353
    targetPort: 53
    protocol: TCP
    name: dns-tcp
EOF
Create a LoadBalancer service for the echo server:
cat > echo-loadbalancer-service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: echo-loadbalancer-svc
  labels:
    app: echo-mixed
spec:
  type: LoadBalancer
  selector:
    app: echo-mixed
  ports:
  - port: 2701
    targetPort: 2701
    protocol: TCP
    name: echo-tcp
  - port: 2702
    targetPort: 2701
    protocol: UDP
    name: echo-udp
EOF
Apply all LoadBalancer services:
kubectl apply -f redis-loadbalancer-service.yaml
kubectl apply -f dns-loadbalancer-service.yaml
kubectl apply -f echo-loadbalancer-service.yaml
Check the status of LoadBalancer services:
kubectl get services -o wide
Note: In some environments, LoadBalancer services may show <pending> for EXTERNAL-IP if no cloud load balancer is available.

Subtask 2.3: Examine Service Details
Get detailed information about all services:
kubectl describe service redis-nodeport-svc
kubectl describe service redis-loadbalancer-svc
View service endpoints:
kubectl get endpoints
Check which nodes are available:
kubectl get nodes -o wide
Task 3: Test the Exposed Services
Subtask 3.1: Test NodePort Services
Get the node IP addresses:
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
echo "Node IP: $NODE_IP"
Test the Redis TCP service via NodePort:
# Install redis-cli if not available
kubectl run redis-client --image=redis:7-alpine -it --rm --restart=Never -- redis-cli -h $NODE_IP -p 30379 ping
Test the Redis service from within the cluster:
kubectl run redis-test --image=redis:7-alpine -it --rm --restart=Never -- sh -c "
redis-cli -h $NODE_IP -p 30379 set testkey 'Hello NodePort'
redis-cli -h $NODE_IP -p 30379 get testkey
"
Test the DNS UDP service via NodePort:
kubectl run dns-test --image=busybox -it --rm --restart=Never -- nslookup test.local $NODE_IP -port=30053
Test the echo server TCP via NodePort:
kubectl run echo-tcp-test --image=busybox -it --rm --restart=Never -- sh -c "
echo 'Hello TCP NodePort' | nc $NODE_IP 30701
"
Test the echo server UDP via NodePort:
kubectl run echo-udp-test --image=busybox -it --rm --restart=Never -- sh -c "
echo 'Hello UDP NodePort' | nc -u $NODE_IP 30702
"
Subtask 3.2: Test LoadBalancer Services
Get LoadBalancer external IPs (if available):
kubectl get services -o wide | grep LoadBalancer
If external IPs are available, test Redis LoadBalancer:
# Replace EXTERNAL_IP with actual external IP from previous command
REDIS_LB_IP=$(kubectl get service redis-loadbalancer-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ ! -z "$REDIS_LB_IP" ]; then
  kubectl run redis-lb-test --image=redis:7-alpine -it --rm --restart=Never -- redis-cli -h $REDIS_LB_IP -p 6379 ping
fi
Test DNS LoadBalancer service:
DNS_LB_IP=$(kubectl get service dns-loadbalancer-svc -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
if [ ! -z "$DNS_LB_IP" ]; then
  kubectl run dns-lb-test --image=busybox -it --rm --restart=Never -- nslookup test.local $DNS_LB_IP
fi
If LoadBalancer external IPs are not available, test using cluster IP:
# Test Redis via cluster IP
REDIS_CLUSTER_IP=$(kubectl get service redis-loadbalancer-svc -o jsonpath='{.spec.clusterIP}')
kubectl run redis-cluster-test --image=redis:7-alpine -it --rm --restart=Never -- redis-cli -h $REDIS_CLUSTER_IP -p 6379 ping
Subtask 3.3: Test Service Discovery and Port Mapping
Create a test pod to examine service resolution:
cat > test-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: network-test-pod
spec:
  containers:
  - name: network-tools
    image: nicolaka/netshoot
    command: ["/bin/bash"]
    args: ["-c", "sleep 3600"]
EOF
Deploy the test pod:
kubectl apply -f test-pod.yaml
Wait for the pod to be ready:
kubectl wait --for=condition=Ready pod/network-test-pod --timeout=60s
Test service DNS resolution:
kubectl exec -it network-test-pod -- nslookup redis-nodeport-svc
kubectl exec -it network-test-pod -- nslookup redis-loadbalancer-svc
Test connectivity to services from within the cluster:
# Test Redis via service name
kubectl exec -it network-test-pod -- redis-cli -h redis-nodeport-svc -p 6379 ping

# Test DNS service
kubectl exec -it network-test-pod -- nslookup test.local dns-nodeport-svc

# Test echo server
kubectl exec -it network-test-pod -- bash -c "echo 'Hello from cluster' | nc echo-nodeport-svc 2701"
Examine network connections:
kubectl exec -it network-test-pod -- netstat -tuln
kubectl exec -it network-test-pod -- ss -tuln
Subtask 3.4: Monitor and Troubleshoot Services
Check service status and events:
kubectl get events --sort-by=.metadata.creationTimestamp
Examine pod logs:
kubectl logs -l app=redis-tcp
kubectl logs -l app=dns-udp
kubectl logs -l app=echo-mixed
Check service endpoints:
kubectl get endpoints redis-nodeport-svc -o yaml
kubectl get endpoints dns-nodeport-svc -o yaml
Verify port accessibility on nodes:
kubectl exec -it network-test-pod -- nmap -p 30379,30053,30701,30702 $NODE_IP
Test service load balancing:
# Scale echo server to see load balancing
kubectl scale deployment echo-mixed-app --replicas=3
kubectl get pods -l app=echo-mixed -o wide

# Test multiple connections
for i in {1..5}; do
  kubectl exec -it network-test-pod -- bash -c "echo 'Request $i' | nc echo-nodeport-svc 2701"
done
Troubleshooting Common Issues
Issue 1: Service Not Accessible via NodePort
Symptoms: Cannot connect to application via NodePort Solutions:

Check if the service is properly created:
kubectl get services
kubectl describe service <service-name>
Verify pod labels match service selector:
kubectl get pods --show-labels
Check if the NodePort is in the valid range (30000-32767):
kubectl get service <service-name> -o yaml
Issue 2: LoadBalancer External IP Pending
Symptoms: LoadBalancer service shows <pending> for EXTERNAL-IP Solutions:

Check if your cluster supports LoadBalancer services
Use NodePort or port-forward as alternatives:
kubectl port-forward service/<service-name> <local-port>:<service-port>
Issue 3: DNS Resolution Not Working
Symptoms: Cannot resolve service names Solutions:

Check CoreDNS pods:
kubectl get pods -n kube-system -l k8s-app=kube-dns
Test DNS from within a pod:
kubectl exec -it <pod-name> -- nslookup kubernetes.default
Issue 4: UDP Service Not Responding
Symptoms: UDP services don't respond to requests Solutions:

Verify UDP port is correctly configured:
kubectl describe service <udp-service-name>
Test with appropriate UDP client tools:
kubectl exec -it network-test-pod -- nc -u <service-ip> <port>
Cleanup
Delete all test pods:
kubectl delete pod network-test-pod
Delete all services:
kubectl delete service redis-nodeport-svc redis-loadbalancer-svc
kubectl delete service dns-nodeport-svc dns-loadbalancer-svc
kubectl delete service echo-nodeport-svc echo-loadbalancer-svc
Delete all deployments:
kubectl delete deployment redis-tcp-app dns-udp-app echo-mixed-app
Remove configuration files:
cd ..
rm -rf lab8-services
Conclusion
In this lab, you have successfully:

• Deployed multiple non-HTTP applications using TCP and UDP protocols, including Redis (TCP), DNS server (UDP), and an echo server (mixed protocols)

• Configured NodePort services to expose applications on specific ports across all cluster nodes, enabling external access through node IPs

• Implemented LoadBalancer services to provide external access through cloud provider load balancers (where supported)

• Tested connectivity to exposed services using various client tools and protocols, verifying both TCP and UDP communication

• Explored service discovery and DNS resolution within the Kubernetes cluster

• Learned troubleshooting techniques for common service exposure issues

Why This Matters: Understanding how to expose non-HTTP applications is crucial for real-world Kubernetes deployments. Many enterprise applications use TCP or UDP protocols for database connections, messaging systems, DNS services, and custom protocols. NodePort and LoadBalancer services provide different approaches to external access, each with specific use cases:

NodePort is ideal for development environments and situations where you have direct access to cluster nodes
LoadBalancer is perfect for production environments with cloud provider integration, offering better scalability and availability
This knowledge prepares you for the Red Hat OpenShift Administration II certification and real-world scenarios where you need to expose various types of applications beyond simple web services.
