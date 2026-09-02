Lab 6: Helm Chart Parameterization
Objectives
By the end of this lab, you will be able to:

• Create and configure values.yaml files for environment-specific parameters • Deploy parameterized applications using Helm charts • Test Helm chart deployments with different configuration values • Understand how to manage multiple environments using Helm parameterization • Override default values using command-line parameters and custom values files • Validate and troubleshoot Helm chart deployments

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with YAML syntax and structure • Knowledge of container fundamentals • Experience with command-line interface operations • Completion of previous Helm labs or equivalent Helm knowledge

Lab Environment Setup
Al Nafi Cloud Machines: This lab uses pre-configured Linux-based cloud machines provided by Al Nafi. Simply click Start Lab to access your environment - no need to build your own VM or install additional software.

Your lab environment includes: • Kubernetes cluster (minikube or kind) • Helm 3.x pre-installed • kubectl configured and ready • Text editor (nano/vim) • All necessary networking configured

Task 1: Create values.yaml for Environment-Specific Parameters
Subtask 1.1: Set Up Lab Directory Structure
First, let's create a proper directory structure for our Helm chart:

# Create the main lab directory
mkdir -p ~/helm-lab6
cd ~/helm-lab6

# Create Helm chart structure
mkdir -p webapp-chart/{templates,values}
cd webapp-chart
Subtask 1.2: Create Basic Chart Metadata
Create the Chart.yaml file to define our chart metadata:

cat > Chart.yaml << 'EOF'
apiVersion: v2
name: webapp-chart
description: A parameterized web application Helm chart
type: application
version: 0.1.0
appVersion: "1.0"
keywords:
  - web
  - application
  - parameterized
maintainers:
  - name: Lab Student
    email: student@example.com
EOF
Subtask 1.3: Create Comprehensive values.yaml
Create the main values.yaml file with comprehensive parameterization:

cat > values.yaml << 'EOF'
# Application Configuration
app:
  name: webapp
  version: "1.0"
  
# Image Configuration
image:
  repository: nginx
  tag: "1.21-alpine"
  pullPolicy: IfNotPresent

# Replica Configuration
replicaCount: 2

# Service Configuration
service:
  type: ClusterIP
  port: 80
  targetPort: 80
  name: webapp-service

# Ingress Configuration
ingress:
  enabled: false
  className: ""
  annotations: {}
  hosts:
    - host: webapp.local
      paths:
        - path: /
          pathType: Prefix
  tls: []

# Resource Configuration
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 250m
    memory: 256Mi

# Environment Variables
env:
  - name: ENVIRONMENT
    value: "development"
  - name: LOG_LEVEL
    value: "info"
  - name: APP_PORT
    value: "80"

# Node Selection
nodeSelector: {}
tolerations: []
affinity: {}

# Security Context
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 2000

# Probes Configuration
probes:
  liveness:
    enabled: true
    path: /
    initialDelaySeconds: 30
    periodSeconds: 10
  readiness:
    enabled: true
    path: /
    initialDelaySeconds: 5
    periodSeconds: 5

# ConfigMap Data
configMap:
  enabled: true
  data:
    app.properties: |
      server.port=80
      logging.level=info
      app.name=webapp
    nginx.conf: |
      server {
          listen 80;
          server_name localhost;
          location / {
              root /usr/share/nginx/html;
              index index.html;
          }
      }
EOF
Subtask 1.4: Create Environment-Specific Values Files
Create development environment values:

cat > values/values-dev.yaml << 'EOF'
# Development Environment Overrides
replicaCount: 1

image:
  tag: "1.21-alpine"

env:
  - name: ENVIRONMENT
    value: "development"
  - name: LOG_LEVEL
    value: "debug"
  - name: APP_PORT
    value: "80"
  - name: DEBUG_MODE
    value: "true"

resources:
  limits:
    cpu: 200m
    memory: 256Mi
  requests:
    cpu: 100m
    memory: 128Mi

service:
  type: NodePort

ingress:
  enabled: true
  hosts:
    - host: webapp-dev.local
      paths:
        - path: /
          pathType: Prefix
EOF
Create production environment values:

cat > values/values-prod.yaml << 'EOF'
# Production Environment Overrides
replicaCount: 3

image:
  tag: "1.21-alpine"
  pullPolicy: Always

env:
  - name: ENVIRONMENT
    value: "production"
  - name: LOG_LEVEL
    value: "warn"
  - name: APP_PORT
    value: "80"
  - name: CACHE_ENABLED
    value: "true"

resources:
  limits:
    cpu: 1000m
    memory: 1Gi
  requests:
    cpu: 500m
    memory: 512Mi

service:
  type: LoadBalancer

ingress:
  enabled: true
  hosts:
    - host: webapp-prod.example.com
      paths:
        - path: /
          pathType: Prefix

securityContext:
  runAsNonRoot: true
  runAsUser: 1001
  fsGroup: 3000

nodeSelector:
  environment: production
EOF
Create staging environment values:

cat > values/values-staging.yaml << 'EOF'
# Staging Environment Overrides
replicaCount: 2

image:
  tag: "1.21-alpine"

env:
  - name: ENVIRONMENT
    value: "staging"
  - name: LOG_LEVEL
    value: "info"
  - name: APP_PORT
    value: "80"
  - name: MONITORING_ENABLED
    value: "true"

resources:
  limits:
    cpu: 750m
    memory: 768Mi
  requests:
    cpu: 375m
    memory: 384Mi

service:
  type: ClusterIP

ingress:
  enabled: true
  hosts:
    - host: webapp-staging.local
      paths:
        - path: /
          pathType: Prefix
EOF
Task 2: Use Helm to Deploy a Parameterized Application
Subtask 2.1: Create Kubernetes Template Files
Create the deployment template:

cat > templates/deployment.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: {{ .Values.app.name }}-deployment
  labels:
    app: {{ .Values.app.name }}
    version: {{ .Values.app.version }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version }}
spec:
  replicas: {{ .Values.replicaCount }}
  selector:
    matchLabels:
      app: {{ .Values.app.name }}
  template:
    metadata:
      labels:
        app: {{ .Values.app.name }}
        version: {{ .Values.app.version }}
    spec:
      {{- if .Values.securityContext }}
      securityContext:
        {{- toYaml .Values.securityContext | nindent 8 }}
      {{- end }}
      containers:
      - name: {{ .Values.app.name }}
        image: "{{ .Values.image.repository }}:{{ .Values.image.tag }}"
        imagePullPolicy: {{ .Values.image.pullPolicy }}
        ports:
        - containerPort: {{ .Values.service.targetPort }}
        {{- if .Values.env }}
        env:
        {{- toYaml .Values.env | nindent 8 }}
        {{- end }}
        {{- if .Values.resources }}
        resources:
          {{- toYaml .Values.resources | nindent 10 }}
        {{- end }}
        {{- if .Values.probes.liveness.enabled }}
        livenessProbe:
          httpGet:
            path: {{ .Values.probes.liveness.path }}
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: {{ .Values.probes.liveness.initialDelaySeconds }}
          periodSeconds: {{ .Values.probes.liveness.periodSeconds }}
        {{- end }}
        {{- if .Values.probes.readiness.enabled }}
        readinessProbe:
          httpGet:
            path: {{ .Values.probes.readiness.path }}
            port: {{ .Values.service.targetPort }}
          initialDelaySeconds: {{ .Values.probes.readiness.initialDelaySeconds }}
          periodSeconds: {{ .Values.probes.readiness.periodSeconds }}
        {{- end }}
        {{- if .Values.configMap.enabled }}
        volumeMounts:
        - name: config-volume
          mountPath: /etc/config
        {{- end }}
      {{- if .Values.configMap.enabled }}
      volumes:
      - name: config-volume
        configMap:
          name: {{ .Values.app.name }}-config
      {{- end }}
      {{- if .Values.nodeSelector }}
      nodeSelector:
        {{- toYaml .Values.nodeSelector | nindent 8 }}
      {{- end }}
      {{- if .Values.tolerations }}
      tolerations:
        {{- toYaml .Values.tolerations | nindent 8 }}
      {{- end }}
      {{- if .Values.affinity }}
      affinity:
        {{- toYaml .Values.affinity | nindent 8 }}
      {{- end }}
EOF
Create the service template:

cat > templates/service.yaml << 'EOF'
apiVersion: v1
kind: Service
metadata:
  name: {{ .Values.service.name }}
  labels:
    app: {{ .Values.app.name }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version }}
spec:
  type: {{ .Values.service.type }}
  ports:
  - port: {{ .Values.service.port }}
    targetPort: {{ .Values.service.targetPort }}
    protocol: TCP
    name: http
  selector:
    app: {{ .Values.app.name }}
EOF
Create the configmap template:

cat > templates/configmap.yaml << 'EOF'
{{- if .Values.configMap.enabled }}
apiVersion: v1
kind: ConfigMap
metadata:
  name: {{ .Values.app.name }}-config
  labels:
    app: {{ .Values.app.name }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version }}
data:
  {{- range $key, $value := .Values.configMap.data }}
  {{ $key }}: |
{{ $value | indent 4 }}
  {{- end }}
{{- end }}
EOF
Create the ingress template:

cat > templates/ingress.yaml << 'EOF'
{{- if .Values.ingress.enabled }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ .Values.app.name }}-ingress
  labels:
    app: {{ .Values.app.name }}
    chart: {{ .Chart.Name }}-{{ .Chart.Version }}
  {{- if .Values.ingress.annotations }}
  annotations:
    {{- toYaml .Values.ingress.annotations | nindent 4 }}
  {{- end }}
spec:
  {{- if .Values.ingress.className }}
  ingressClassName: {{ .Values.ingress.className }}
  {{- end }}
  {{- if .Values.ingress.tls }}
  tls:
    {{- range .Values.ingress.tls }}
    - hosts:
        {{- range .hosts }}
        - {{ . | quote }}
        {{- end }}
      secretName: {{ .secretName }}
    {{- end }}
  {{- end }}
  rules:
    {{- range .Values.ingress.hosts }}
    - host: {{ .host | quote }}
      http:
        paths:
          {{- range .paths }}
          - path: {{ .path }}
            pathType: {{ .pathType }}
            backend:
              service:
                name: {{ $.Values.service.name }}
                port:
                  number: {{ $.Values.service.port }}
          {{- end }}
    {{- end }}
{{- end }}
EOF
Subtask 2.2: Validate Helm Chart Structure
Verify the chart structure and syntax:

# Check chart structure
find . -type f -name "*.yaml" | head -10

# Validate chart syntax
helm lint .

# Check template rendering with default values
helm template webapp-test . --debug
Subtask 2.3: Deploy with Default Values
Deploy the application using default values:

# Create namespace for our deployments
kubectl create namespace helm-lab

# Deploy with default values
helm install webapp-default . --namespace helm-lab

# Verify deployment
kubectl get all -n helm-lab
Check the deployment status:

# Check pods
kubectl get pods -n helm-lab -l app=webapp

# Check services
kubectl get svc -n helm-lab

# Check configmaps
kubectl get configmap -n helm-lab

# Describe the deployment
kubectl describe deployment webapp-deployment -n helm-lab
Task 3: Test Helm Chart Deployment with Different Values
Subtask 3.1: Deploy Development Environment
Deploy using development-specific values:

# Deploy development environment
helm install webapp-dev . -f values/values-dev.yaml --namespace helm-lab

# Verify development deployment
kubectl get pods -n helm-lab -l app=webapp
kubectl get svc -n helm-lab
Check development-specific configurations:

# Check environment variables in development pod
kubectl exec -n helm-lab deployment/webapp-deployment -- env | grep -E "(ENVIRONMENT|LOG_LEVEL|DEBUG_MODE)"

# Check resource limits
kubectl describe pod -n helm-lab -l app=webapp | grep -A 5 "Limits:"
Subtask 3.2: Deploy Staging Environment
Deploy using staging-specific values:

# Deploy staging environment
helm install webapp-staging . -f values/values-staging.yaml --namespace helm-lab

# Verify staging deployment
kubectl get deployments -n helm-lab
kubectl get pods -n helm-lab -l app=webapp
Subtask 3.3: Deploy Production Environment
Deploy using production-specific values:

# Deploy production environment
helm install webapp-prod . -f values/values-prod.yaml --namespace helm-lab

# Verify production deployment
kubectl get all -n helm-lab
Check production-specific configurations:

# Check replica count
kubectl get deployment -n helm-lab -o wide

# Check resource allocations
kubectl top pods -n helm-lab 2>/dev/null || echo "Metrics server not available"

# Check environment variables in production pods
kubectl exec -n helm-lab deployment/webapp-deployment -- env | grep ENVIRONMENT
Subtask 3.4: Test Command-Line Value Overrides
Test overriding values using command-line parameters:

# Deploy with command-line overrides
helm install webapp-override . \
  --set replicaCount=4 \
  --set image.tag=1.22-alpine \
  --set env[0].name=ENVIRONMENT \
  --set env[0].value=testing \
  --set env[1].name=LOG_LEVEL \
  --set env[1].value=debug \
  --namespace helm-lab

# Verify overrides
kubectl get deployment webapp-override-deployment -n helm-lab -o yaml | grep -A 10 "spec:"
Subtask 3.5: Test Multiple Values Files
Create a custom values file and combine with existing ones:

# Create custom override file
cat > values/custom-overrides.yaml << 'EOF'
app:
  name: webapp-custom

replicaCount: 5

env:
  - name: ENVIRONMENT
    value: "custom"
  - name: CUSTOM_SETTING
    value: "enabled"
EOF

# Deploy with multiple values files
helm install webapp-multi . \
  -f values/values-dev.yaml \
  -f values/custom-overrides.yaml \
  --namespace helm-lab

# Verify the deployment
kubectl get deployment webapp-custom-deployment -n helm-lab -o yaml | grep -A 5 "replicas:"
Subtask 3.6: Upgrade Deployments with New Values
Test upgrading existing deployments:

# Upgrade development deployment with new values
helm upgrade webapp-dev . \
  -f values/values-dev.yaml \
  --set replicaCount=3 \
  --set image.tag=1.22-alpine \
  --namespace helm-lab

# Check upgrade history
helm history webapp-dev --namespace helm-lab

# Verify upgrade
kubectl get pods -n helm-lab -l app=webapp
Subtask 3.7: Validate Different Configurations
Compare configurations across different deployments:

# List all Helm releases
helm list --namespace helm-lab

# Get values for each deployment
echo "=== Default Values ==="
helm get values webapp-default --namespace helm-lab

echo "=== Development Values ==="
helm get values webapp-dev --namespace helm-lab

echo "=== Production Values ==="
helm get values webapp-prod --namespace helm-lab
Check resource differences:

# Compare resource requests and limits
kubectl get pods -n helm-lab -o custom-columns=NAME:.metadata.name,CPU-REQUEST:.spec.containers[0].resources.requests.cpu,MEMORY-REQUEST:.spec.containers[0].resources.requests.memory,CPU-LIMIT:.spec.containers[0].resources.limits.cpu,MEMORY-LIMIT:.spec.containers[0].resources.limits.memory
Subtask 3.8: Test Template Functions and Logic
Create a test to verify template logic:

# Test template rendering with different values
helm template test-dev . -f values/values-dev.yaml > /tmp/dev-manifest.yaml
helm template test-prod . -f values/values-prod.yaml > /tmp/prod-manifest.yaml

# Compare the differences
echo "=== Development Manifest Snippet ==="
head -20 /tmp/dev-manifest.yaml

echo "=== Production Manifest Snippet ==="
head -20 /tmp/prod-manifest.yaml

# Check specific differences
diff /tmp/dev-manifest.yaml /tmp/prod-manifest.yaml | head -20
Troubleshooting Common Issues
Issue 1: Template Rendering Errors
If you encounter template rendering errors:

# Debug template rendering
helm template debug-test . --debug

# Check specific template
helm template debug-test . --show-only templates/deployment.yaml
Issue 2: Values Not Applied
If values are not being applied correctly:

# Verify values hierarchy
helm get values webapp-dev --namespace helm-lab --all

# Check computed values
helm template webapp-dev . -f values/values-dev.yaml --debug | grep -A 10 "computed values"
Issue 3: Resource Conflicts
If you encounter resource conflicts:

# Check existing resources
kubectl get all -n helm-lab

# Clean up specific deployment
helm uninstall webapp-dev --namespace helm-lab

# Force cleanup if needed
kubectl delete all -l app=webapp -n helm-lab
Validation and Testing
Validate All Deployments
Run comprehensive validation:

# Check all pods are running
kubectl get pods -n helm-lab --field-selector=status.phase=Running

# Verify services are accessible
kubectl get svc -n helm-lab

# Check configmaps are created
kubectl get configmap -n helm-lab

# Test connectivity (if applicable)
kubectl exec -n helm-lab deployment/webapp-deployment -- wget -qO- http://localhost:80 || echo "Service test completed"
Performance Testing
Test different resource configurations:

# Monitor resource usage
kubectl top pods -n helm-lab 2>/dev/null || echo "Install metrics-server for resource monitoring"

# Check pod distribution
kubectl get pods -n helm-lab -o wide
Cleanup
Clean up all resources created during the lab:

# Uninstall all Helm releases
helm uninstall webapp-default --namespace helm-lab
helm uninstall webapp-dev --namespace helm-lab
helm uninstall webapp-staging --namespace helm-lab
helm uninstall webapp-prod --namespace helm-lab
helm uninstall webapp-override --namespace helm-lab
helm uninstall webapp-multi --namespace helm-lab

# Verify cleanup
helm list --namespace helm-lab

# Delete namespace
kubectl delete namespace helm-lab

# Clean up local files
cd ~/
rm -rf helm-lab6
Conclusion
Congratulations! You have successfully completed Lab 6: Helm Chart Parameterization. In this comprehensive lab, you have accomplished the following:

Key Achievements:

• Created comprehensive values.yaml files with environment-specific parameters for development, staging, and production environments • Deployed parameterized applications using Helm charts with different configuration sets • Tested multiple deployment scenarios including command-line overrides and multiple values files • Implemented advanced templating with conditional logic, resource management, and security contexts • Validated chart functionality across different environments and configurations

Technical Skills Developed:

• Helm Chart Parameterization: Understanding how to structure and organize values for different environments • Template Engineering: Creating flexible Kubernetes templates that adapt to various configurations • Environment Management: Managing multiple deployment environments with consistent tooling • Configuration Management: Using values files, command-line overrides, and hierarchical configuration • Deployment Validation: Testing and verifying deployments across different scenarios

Real-World Applications:

This lab simulates real-world scenarios where organizations need to deploy the same application across multiple environments with different configurations. The parameterization techniques you learned are essential for:

• DevOps Pipelines: Automating deployments across development, staging, and production • Multi-Tenant Applications: Deploying applications with tenant-specific configurations • Scalable Infrastructure: Managing applications that need different resource allocations • Compliance and Security: Implementing environment-specific security and compliance requirements

Next Steps:

• Explore Helm hooks for advanced deployment lifecycle management • Learn about Helm dependencies and chart repositories • Investigate GitOps workflows with Helm and ArgoCD • Study advanced templating techniques and helper functions • Practice Helm chart testing with automated validation

The parameterization skills you've developed in this lab are fundamental to modern Kubernetes application deployment and will serve as a foundation for more advanced container orchestration and DevOps practices.
