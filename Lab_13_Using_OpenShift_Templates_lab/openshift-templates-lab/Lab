Lab 13: Using OpenShift Templates
Objectives
By the end of this lab, you will be able to:

• Understand the concept and structure of OpenShift templates • Create parameterized templates for reusable application deployments • Instantiate templates with different parameter values for multiple environments • Deploy applications using custom templates • Manage template parameters for development, staging, and production environments • Troubleshoot common template-related issues

Prerequisites
Before starting this lab, you should have:

• Basic understanding of OpenShift concepts (pods, services, deployments) • Familiarity with YAML syntax and Kubernetes resources • Knowledge of command-line interface operations • Understanding of containerized applications • Basic knowledge of environment variables and configuration management

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with OpenShift pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install OpenShift locally.

Your lab environment includes: • OpenShift cluster with administrative access • Pre-configured oc command-line tool • Sample application source code • All necessary permissions to create and manage templates

Task 1: Create an OpenShift Template with Parameterized Resources
Subtask 1.1: Understanding Template Structure
First, let's examine the basic structure of an OpenShift template and create our working directory.

# Create a working directory for our lab
mkdir ~/openshift-templates-lab
cd ~/openshift-templates-lab

# Verify OpenShift connection
oc whoami
oc cluster-info
Subtask 1.2: Create a Basic Web Application Template
Create a comprehensive template that includes a Deployment, Service, and Route for a web application.

# Create the template file
cat > web-app-template.yaml << 'EOF'
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: web-application-template
  annotations:
    description: "A template for deploying a web application with configurable parameters"
    tags: "web,application,template"
    iconClass: "icon-nodejs"
objects:
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: ${APP_NAME}
    labels:
      app: ${APP_NAME}
      environment: ${ENVIRONMENT}
  spec:
    replicas: ${{REPLICA_COUNT}}
    selector:
      matchLabels:
        app: ${APP_NAME}
    template:
      metadata:
        labels:
          app: ${APP_NAME}
          environment: ${ENVIRONMENT}
      spec:
        containers:
        - name: ${APP_NAME}
          image: ${IMAGE_NAME}:${IMAGE_TAG}
          ports:
          - containerPort: ${{CONTAINER_PORT}}
          env:
          - name: ENVIRONMENT
            value: ${ENVIRONMENT}
          - name: DATABASE_URL
            value: ${DATABASE_URL}
          - name: APP_VERSION
            value: ${APP_VERSION}
          resources:
            requests:
              memory: ${MEMORY_REQUEST}
              cpu: ${CPU_REQUEST}
            limits:
              memory: ${MEMORY_LIMIT}
              cpu: ${CPU_LIMIT}
- apiVersion: v1
  kind: Service
  metadata:
    name: ${APP_NAME}-service
    labels:
      app: ${APP_NAME}
      environment: ${ENVIRONMENT}
  spec:
    selector:
      app: ${APP_NAME}
    ports:
    - port: ${{SERVICE_PORT}}
      targetPort: ${{CONTAINER_PORT}}
      protocol: TCP
    type: ClusterIP
- apiVersion: route.openshift.io/v1
  kind: Route
  metadata:
    name: ${APP_NAME}-route
    labels:
      app: ${APP_NAME}
      environment: ${ENVIRONMENT}
  spec:
    to:
      kind: Service
      name: ${APP_NAME}-service
    port:
      targetPort: ${{CONTAINER_PORT}}
    tls:
      termination: edge
      insecureEdgeTerminationPolicy: Redirect
parameters:
- name: APP_NAME
  description: "Name of the application"
  value: "my-web-app"
  required: true
- name: ENVIRONMENT
  description: "Environment where the app is deployed"
  value: "development"
  required: true
- name: IMAGE_NAME
  description: "Container image name"
  value: "nginx"
  required: true
- name: IMAGE_TAG
  description: "Container image tag"
  value: "latest"
  required: true
- name: REPLICA_COUNT
  description: "Number of replicas"
  value: "1"
  required: true
- name: CONTAINER_PORT
  description: "Port exposed by the container"
  value: "8080"
  required: true
- name: SERVICE_PORT
  description: "Port exposed by the service"
  value: "80"
  required: true
- name: DATABASE_URL
  description: "Database connection URL"
  value: "postgresql://localhost:5432/myapp"
  required: false
- name: APP_VERSION
  description: "Application version"
  value: "1.0.0"
  required: true
- name: MEMORY_REQUEST
  description: "Memory request for container"
  value: "128Mi"
  required: true
- name: MEMORY_LIMIT
  description: "Memory limit for container"
  value: "256Mi"
  required: true
- name: CPU_REQUEST
  description: "CPU request for container"
  value: "100m"
  required: true
- name: CPU_LIMIT
  description: "CPU limit for container"
  value: "200m"
  required: true
labels:
  template: web-application-template
EOF
Subtask 1.3: Upload Template to OpenShift
Now let's upload our template to the OpenShift cluster and verify it's available.

# Create a new project for our template work
oc new-project template-lab

# Upload the template to OpenShift
oc create -f web-app-template.yaml

# Verify the template was created successfully
oc get templates

# Get detailed information about our template
oc describe template web-application-template
Subtask 1.4: View Template Parameters
Let's examine the parameters defined in our template to understand how they can be customized.

# List all parameters for the template
oc process --parameters web-application-template

# View the template in processed form with default values
oc process web-application-template
Task 2: Instantiate the Template with Different Parameter Values for Various Environments
Subtask 2.1: Create Development Environment Deployment
Let's deploy our application to a development environment with specific parameter values.

# Create development environment with custom parameters
oc process web-application-template \
  -p APP_NAME=webapp-dev \
  -p ENVIRONMENT=development \
  -p IMAGE_NAME=httpd \
  -p IMAGE_TAG=2.4 \
  -p REPLICA_COUNT=1 \
  -p CONTAINER_PORT=80 \
  -p SERVICE_PORT=8080 \
  -p APP_VERSION=1.0.0-dev \
  -p MEMORY_REQUEST=64Mi \
  -p MEMORY_LIMIT=128Mi \
  -p CPU_REQUEST=50m \
  -p CPU_LIMIT=100m | oc create -f -

# Verify the development deployment
oc get all -l app=webapp-dev

# Check the deployment status
oc rollout status deployment/webapp-dev
Subtask 2.2: Create Staging Environment Deployment
Now let's create a staging environment with different resource allocations and configurations.

# Create staging environment with different parameters
oc process web-application-template \
  -p APP_NAME=webapp-staging \
  -p ENVIRONMENT=staging \
  -p IMAGE_NAME=httpd \
  -p IMAGE_TAG=2.4 \
  -p REPLICA_COUNT=2 \
  -p CONTAINER_PORT=80 \
  -p SERVICE_PORT=8080 \
  -p APP_VERSION=1.0.0-rc1 \
  -p MEMORY_REQUEST=128Mi \
  -p MEMORY_LIMIT=256Mi \
  -p CPU_REQUEST=100m \
  -p CPU_LIMIT=200m | oc create -f -

# Verify the staging deployment
oc get all -l app=webapp-staging

# Check pod status for staging
oc get pods -l app=webapp-staging
Subtask 2.3: Create Production Environment Deployment
Finally, let's create a production environment with higher resource allocations and multiple replicas.

# Create production environment with production-ready parameters
oc process web-application-template \
  -p APP_NAME=webapp-prod \
  -p ENVIRONMENT=production \
  -p IMAGE_NAME=httpd \
  -p IMAGE_TAG=2.4 \
  -p REPLICA_COUNT=3 \
  -p CONTAINER_PORT=80 \
  -p SERVICE_PORT=8080 \
  -p APP_VERSION=1.0.0 \
  -p MEMORY_REQUEST=256Mi \
  -p MEMORY_LIMIT=512Mi \
  -p CPU_REQUEST=200m \
  -p CPU_LIMIT=500m | oc create -f -

# Verify the production deployment
oc get all -l app=webapp-prod

# Check all deployments across environments
oc get deployments
Subtask 2.4: Compare Environment Configurations
Let's examine how our different environments are configured and verify they're running correctly.

# Compare resource allocations across environments
echo "=== Development Environment ==="
oc get deployment webapp-dev -o jsonpath='{.spec.template.spec.containers[0].resources}' | jq .

echo "=== Staging Environment ==="
oc get deployment webapp-staging -o jsonpath='{.spec.template.spec.containers[0].resources}' | jq .

echo "=== Production Environment ==="
oc get deployment webapp-prod -o jsonpath='{.spec.template.spec.containers[0].resources}' | jq .

# Check replica counts
echo "=== Replica Counts ==="
oc get deployments -o custom-columns=NAME:.metadata.name,REPLICAS:.spec.replicas,READY:.status.readyReplicas
Task 3: Deploy an Application Using the Template
Subtask 3.1: Create a Parameter File for Automated Deployment
Let's create parameter files for easier template instantiation and deployment automation.

# Create parameter file for development
cat > dev-params.txt << 'EOF'
APP_NAME=myapp-dev
ENVIRONMENT=development
IMAGE_NAME=nginx
IMAGE_TAG=alpine
REPLICA_COUNT=1
CONTAINER_PORT=80
SERVICE_PORT=8080
APP_VERSION=2.0.0-dev
MEMORY_REQUEST=64Mi
MEMORY_LIMIT=128Mi
CPU_REQUEST=50m
CPU_LIMIT=100m
DATABASE_URL=postgresql://dev-db:5432/myapp_dev
EOF

# Create parameter file for production
cat > prod-params.txt << 'EOF'
APP_NAME=myapp-prod
ENVIRONMENT=production
IMAGE_NAME=nginx
IMAGE_TAG=alpine
REPLICA_COUNT=5
CONTAINER_PORT=80
SERVICE_PORT=8080
APP_VERSION=2.0.0
MEMORY_REQUEST=256Mi
MEMORY_LIMIT=512Mi
CPU_REQUEST=200m
CPU_LIMIT=500m
DATABASE_URL=postgresql://prod-db:5432/myapp_prod
EOF
Subtask 3.2: Deploy Using Parameter Files
Now let's deploy applications using our parameter files for consistent and repeatable deployments.

# Deploy development application using parameter file
oc process web-application-template --param-file=dev-params.txt | oc create -f -

# Deploy production application using parameter file
oc process web-application-template --param-file=prod-params.txt | oc create -f -

# Verify both deployments
oc get all -l template=web-application-template
Subtask 3.3: Test Application Accessibility
Let's verify that our deployed applications are accessible and working correctly.

# Get route information for all deployed applications
echo "=== Application Routes ==="
oc get routes

# Test connectivity to development application
DEV_ROUTE=$(oc get route myapp-dev-route -o jsonpath='{.spec.host}')
echo "Development app URL: https://$DEV_ROUTE"
curl -k -s -o /dev/null -w "%{http_code}" https://$DEV_ROUTE

# Test connectivity to production application
PROD_ROUTE=$(oc get route myapp-prod-route -o jsonpath='{.spec.host}')
echo "Production app URL: https://$PROD_ROUTE"
curl -k -s -o /dev/null -w "%{http_code}" https://$PROD_ROUTE

# Check application logs
echo "=== Development Application Logs ==="
oc logs deployment/myapp-dev --tail=10

echo "=== Production Application Logs ==="
oc logs deployment/myapp-prod --tail=10
Subtask 3.4: Create an Advanced Template with ConfigMap
Let's create a more advanced template that includes a ConfigMap for application configuration.

# Create advanced template with ConfigMap
cat > advanced-web-template.yaml << 'EOF'
apiVersion: template.openshift.io/v1
kind: Template
metadata:
  name: advanced-web-template
  annotations:
    description: "Advanced web application template with ConfigMap"
    tags: "web,configmap,advanced"
objects:
- apiVersion: v1
  kind: ConfigMap
  metadata:
    name: ${APP_NAME}-config
    labels:
      app: ${APP_NAME}
  data:
    app.properties: |
      environment=${ENVIRONMENT}
      version=${APP_VERSION}
      database.url=${DATABASE_URL}
      log.level=${LOG_LEVEL}
      feature.enabled=${FEATURE_ENABLED}
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    name: ${APP_NAME}
    labels:
      app: ${APP_NAME}
  spec:
    replicas: ${{REPLICA_COUNT}}
    selector:
      matchLabels:
        app: ${APP_NAME}
    template:
      metadata:
        labels:
          app: ${APP_NAME}
      spec:
        containers:
        - name: ${APP_NAME}
          image: ${IMAGE_NAME}:${IMAGE_TAG}
          ports:
          - containerPort: ${{CONTAINER_PORT}}
          volumeMounts:
          - name: config-volume
            mountPath: /etc/config
          env:
          - name: CONFIG_PATH
            value: "/etc/config/app.properties"
        volumes:
        - name: config-volume
          configMap:
            name: ${APP_NAME}-config
- apiVersion: v1
  kind: Service
  metadata:
    name: ${APP_NAME}-service
    labels:
      app: ${APP_NAME}
  spec:
    selector:
      app: ${APP_NAME}
    ports:
    - port: ${{SERVICE_PORT}}
      targetPort: ${{CONTAINER_PORT}}
parameters:
- name: APP_NAME
  description: "Application name"
  value: "advanced-app"
  required: true
- name: ENVIRONMENT
  description: "Environment name"
  value: "development"
  required: true
- name: IMAGE_NAME
  description: "Container image"
  value: "nginx"
  required: true
- name: IMAGE_TAG
  description: "Image tag"
  value: "alpine"
  required: true
- name: REPLICA_COUNT
  description: "Number of replicas"
  value: "1"
  required: true
- name: CONTAINER_PORT
  description: "Container port"
  value: "80"
  required: true
- name: SERVICE_PORT
  description: "Service port"
  value: "8080"
  required: true
- name: APP_VERSION
  description: "Application version"
  value: "1.0.0"
  required: true
- name: DATABASE_URL
  description: "Database URL"
  value: "postgresql://localhost:5432/app"
  required: true
- name: LOG_LEVEL
  description: "Logging level"
  value: "INFO"
  required: true
- name: FEATURE_ENABLED
  description: "Feature flag"
  value: "true"
  required: true
EOF

# Upload the advanced template
oc create -f advanced-web-template.yaml

# Deploy using the advanced template
oc process advanced-web-template \
  -p APP_NAME=advanced-webapp \
  -p ENVIRONMENT=testing \
  -p REPLICA_COUNT=2 \
  -p LOG_LEVEL=DEBUG \
  -p FEATURE_ENABLED=false | oc create -f -

# Verify the ConfigMap was created
oc get configmap advanced-webapp-config -o yaml
Subtask 3.5: Template Management and Cleanup
Let's learn how to manage and clean up our templates and deployments.

# List all templates in the project
oc get templates

# Export a template for backup or sharing
oc get template web-application-template -o yaml > backup-template.yaml

# View all resources created from templates
oc get all -l template=web-application-template

# Clean up specific deployment
oc delete all -l app=webapp-dev

# Clean up all resources from a specific template instantiation
oc delete all,configmap -l app=advanced-webapp

# View remaining resources
oc get all
Troubleshooting Tips
Common Issues and Solutions
Issue 1: Template Parameter Validation Errors

# Check parameter requirements
oc process --parameters template-name

# Validate template before applying
oc process template-name --param-file=params.txt --dry-run
Issue 2: Resource Creation Failures

# Check events for error details
oc get events --sort-by='.lastTimestamp'

# Verify resource quotas
oc describe quota

# Check template processing output
oc process template-name -p PARAM=value
Issue 3: Application Not Accessible

# Check service endpoints
oc get endpoints

# Verify route configuration
oc describe route route-name

# Test internal connectivity
oc rsh deployment/app-name curl localhost:port
Issue 4: Parameter Override Not Working

# Verify parameter names match exactly
oc process --parameters template-name

# Check for typos in parameter files
cat param-file.txt

# Use explicit parameter syntax
oc process template-name -p PARAM_NAME=value
Conclusion
In this comprehensive lab, you have successfully:

• Created parameterized OpenShift templates that can be reused across multiple environments with different configurations • Instantiated templates with various parameter values to deploy applications in development, staging, and production environments • Deployed applications using templates with both command-line parameters and parameter files for automation • Implemented advanced template features including ConfigMaps for application configuration management • Learned template management techniques including backup, cleanup, and troubleshooting

Why This Matters: OpenShift templates provide a powerful way to standardize application deployments across different environments while maintaining flexibility through parameterization. This approach ensures consistency, reduces deployment errors, and enables efficient DevOps practices. Templates are essential for organizations that need to deploy the same application stack multiple times with different configurations, making them invaluable for multi-environment deployments, testing scenarios, and application lifecycle management.

The skills you've developed in this lab are directly applicable to real-world OpenShift administration tasks and are essential for the Red Hat OpenShift Administration II certification. You now understand how to create reusable deployment patterns that can significantly improve your organization's deployment efficiency and consistency.
