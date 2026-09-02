Lab 7: Expose Applications with OpenShift Routes
Objectives
By the end of this lab, you will be able to:

• Understand the concept of OpenShift Routes and their role in exposing applications • Create and configure Routes to make internal applications accessible from outside the cluster • Implement TLS termination on Routes for secure HTTPS connections • Test and verify application accessibility through Routes • Troubleshoot common Route configuration issues • Apply security best practices for Route configuration

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (Pods, Services, Deployments) • Familiarity with OpenShift CLI (oc) commands • Knowledge of HTTP/HTTPS protocols and TLS certificates • Understanding of DNS concepts • Completed previous OpenShift labs or equivalent experience • Access to an OpenShift cluster with cluster-admin privileges

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with OpenShift pre-installed. Simply click Start Lab to begin - no need to build your own VM or install OpenShift manually.

Your lab environment includes: • OpenShift 4.12+ cluster with administrative access • Pre-configured oc CLI tool • Sample applications ready for deployment • Valid TLS certificates for testing

Task 1: Create a Route to Expose a Web Application
Subtask 1.1: Deploy a Sample Web Application
First, we'll deploy a simple web application that we can expose using Routes.

Create a new project for this lab:
oc new-project route-lab
Deploy a sample web application:
oc new-app --name=webapp --image=quay.io/redhattraining/hello-world-nginx:v1.0
Verify the deployment:
oc get pods
oc get deployment webapp
Wait until the pod status shows Running before proceeding.

Check the automatically created service:
oc get svc webapp
oc describe svc webapp
Note the service's cluster IP and port - this service is only accessible within the cluster.

Subtask 1.2: Create a Basic Route
Now we'll create a Route to expose our web application externally.

Create a Route using the oc expose command:
oc expose service webapp --name=webapp-route
Verify the Route creation:
oc get routes
oc describe route webapp-route
Get the Route hostname:
ROUTE_HOST=$(oc get route webapp-route -o jsonpath='{.spec.host}')
echo "Application URL: http://$ROUTE_HOST"
Subtask 1.3: Test Basic Route Access
Test the Route using curl:
curl -I http://$ROUTE_HOST
Test with a full HTTP request:
curl http://$ROUTE_HOST
You should see the HTML content from the hello-world application.

Test from a web browser (if GUI access is available):
Open your browser
Navigate to the URL displayed in the previous step
Verify the application loads correctly
Task 2: Configure TLS Termination on the Route
Subtask 2.1: Understanding TLS Termination Types
OpenShift supports three types of TLS termination:

• Edge Termination: TLS is terminated at the router, traffic to backend is HTTP • Passthrough Termination: TLS connection goes directly to the backend pod • Re-encryption Termination: TLS is terminated at router, then re-encrypted to backend

Subtask 2.2: Create a Route with Edge TLS Termination
Delete the existing Route:
oc delete route webapp-route
Create a new Route with edge TLS termination:
oc create route edge webapp-secure \
  --service=webapp \
  --port=8080 \
  --insecure-policy=Redirect
The --insecure-policy=Redirect parameter automatically redirects HTTP traffic to HTTPS.

Verify the secure Route:
oc get route webapp-secure
oc describe route webapp-secure
Subtask 2.3: Test TLS-Enabled Route
Get the secure Route hostname:
SECURE_HOST=$(oc get route webapp-secure -o jsonpath='{.spec.host}')
echo "Secure Application URL: https://$SECURE_HOST"
Test HTTPS access:
curl -k https://$SECURE_HOST
The -k flag ignores certificate warnings for self-signed certificates.

Test HTTP to HTTPS redirect:
curl -I http://$SECURE_HOST
You should see a 302 redirect response pointing to the HTTPS URL.

Verify certificate details:
openssl s_client -connect $SECURE_HOST:443 -servername $SECURE_HOST < /dev/null
Subtask 2.4: Create Route with Custom TLS Certificate
For production environments, you'll want to use proper TLS certificates.

Generate a self-signed certificate for demonstration:
# Create a private key
openssl genrsa -out webapp.key 2048

# Create a certificate signing request
openssl req -new -key webapp.key -out webapp.csr -subj "/CN=$SECURE_HOST"

# Generate a self-signed certificate
openssl x509 -req -in webapp.csr -signkey webapp.key -out webapp.crt -days 365
Create a Route with custom certificate:
oc create route edge webapp-custom-cert \
  --service=webapp \
  --cert=webapp.crt \
  --key=webapp.key \
  --hostname=custom-$SECURE_HOST
Test the custom certificate Route:
CUSTOM_HOST=$(oc get route webapp-custom-cert -o jsonpath='{.spec.host}')
curl -k https://$CUSTOM_HOST
Task 3: Test Accessing the Application via the Route
Subtask 3.1: Comprehensive Route Testing
Create a test script for comprehensive testing:
cat > test-routes.sh << 'EOF'
#!/bin/bash

echo "=== OpenShift Route Testing Script ==="
echo

# Get route information
BASIC_ROUTE=$(oc get route webapp-secure -o jsonpath='{.spec.host}' 2>/dev/null)
CUSTOM_ROUTE=$(oc get route webapp-custom-cert -o jsonpath='{.spec.host}' 2>/dev/null)

if [ -n "$BASIC_ROUTE" ]; then
    echo "Testing basic secure route: $BASIC_ROUTE"
    echo "1. Testing HTTPS access:"
    curl -s -o /dev/null -w "Status: %{http_code}, Time: %{time_total}s\n" https://$BASIC_ROUTE -k
    
    echo "2. Testing HTTP redirect:"
    curl -s -o /dev/null -w "Status: %{http_code}, Redirect: %{redirect_url}\n" http://$BASIC_ROUTE
    echo
fi

if [ -n "$CUSTOM_ROUTE" ]; then
    echo "Testing custom certificate route: $CUSTOM_ROUTE"
    echo "3. Testing HTTPS access:"
    curl -s -o /dev/null -w "Status: %{http_code}, Time: %{time_total}s\n" https://$CUSTOM_ROUTE -k
    echo
fi

echo "4. Checking route configurations:"
oc get routes -o wide
EOF

chmod +x test-routes.sh
./test-routes.sh
Subtask 3.2: Load Testing the Routes
Install Apache Bench for load testing (if not available):
# On RHEL/CentOS systems
sudo yum install -y httpd-tools

# On Ubuntu/Debian systems
# sudo apt-get install -y apache2-utils
Perform basic load testing:
# Test with 100 requests, 10 concurrent
ab -n 100 -c 10 -k https://$SECURE_HOST/
Monitor Route performance:
# In one terminal, monitor the pods
watch oc get pods

# In another terminal, run the load test
ab -n 1000 -c 50 https://$SECURE_HOST/
Subtask 3.3: Advanced Route Configuration
Create a Route with path-based routing:
oc create route edge webapp-api \
  --service=webapp \
  --path=/api \
  --hostname=$SECURE_HOST
Test path-based routing:
curl -k https://$SECURE_HOST/api
curl -k https://$SECURE_HOST/
Configure Route with custom timeout:
oc annotate route webapp-secure \
  haproxy.router.openshift.io/timeout=30s
Add rate limiting annotation:
oc annotate route webapp-secure \
  haproxy.router.openshift.io/rate-limit-connections=10
Subtask 3.4: Route Monitoring and Troubleshooting
Check Route status and events:
oc describe route webapp-secure
oc get events --field-selector involvedObject.name=webapp-secure
View router logs:
# Find the router pods
oc get pods -n openshift-ingress

# View router logs (replace POD_NAME with actual pod name)
ROUTER_POD=$(oc get pods -n openshift-ingress -l ingresscontroller.operator.openshift.io/deployment-ingresscontroller=default -o jsonpath='{.items[0].metadata.name}')
oc logs $ROUTER_POD -n openshift-ingress | grep $SECURE_HOST
Test Route connectivity from within the cluster:
# Create a test pod
oc run test-pod --image=registry.access.redhat.com/ubi8/ubi:latest --rm -it -- bash

# Inside the pod, test internal service access
curl webapp:8080

# Test Route access from inside the cluster
curl https://$SECURE_HOST -k
Troubleshooting Common Issues
Issue 1: Route Not Accessible
Symptoms: Cannot access application via Route URL

Solutions:

# Check if Route exists and has correct hostname
oc get routes

# Verify service is running and has endpoints
oc get svc webapp
oc get endpoints webapp

# Check pod status
oc get pods -l deployment=webapp

# Verify router pods are running
oc get pods -n openshift-ingress
Issue 2: TLS Certificate Issues
Symptoms: Browser shows certificate warnings or SSL errors

Solutions:

# Check Route TLS configuration
oc get route webapp-secure -o yaml

# Verify certificate validity
openssl x509 -in webapp.crt -text -noout

# Test certificate chain
openssl s_client -connect $SECURE_HOST:443 -servername $SECURE_HOST
Issue 3: Performance Issues
Symptoms: Slow response times or timeouts

Solutions:

# Check Route annotations for timeouts
oc describe route webapp-secure

# Monitor pod resource usage
oc top pods

# Scale up the deployment if needed
oc scale deployment webapp --replicas=3
Security Best Practices
Secure Route Configuration
Always use TLS for production applications:
# Use edge termination with proper certificates
oc create route edge secure-app \
  --service=webapp \
  --cert=production.crt \
  --key=production.key \
  --ca-cert=ca.crt
Implement proper access controls:
# Add IP whitelist annotation
oc annotate route webapp-secure \
  haproxy.router.openshift.io/ip_whitelist="192.168.1.0/24 10.0.0.0/8"
Use HSTS headers for security:
oc annotate route webapp-secure \
  haproxy.router.openshift.io/hsts_header="max-age=31536000;includeSubDomains;preload"
Lab Cleanup
To clean up the resources created in this lab:

# Delete the project and all resources
oc delete project route-lab

# Clean up certificate files
rm -f webapp.key webapp.csr webapp.crt test-routes.sh
Conclusion
In this lab, you have successfully:

• Created OpenShift Routes to expose internal applications to external traffic, making them accessible from outside the cluster • Implemented TLS termination using both default and custom certificates, ensuring secure HTTPS connections • Tested application accessibility through various Route configurations and performed load testing • Applied security best practices including proper certificate management and access controls • Troubleshot common Route issues and learned monitoring techniques

Why This Matters: Routes are essential for making OpenShift applications accessible to end users. Understanding how to properly configure Routes with TLS termination is crucial for production deployments, as it ensures both accessibility and security. The skills you've learned here are fundamental for any OpenShift administrator managing production workloads.

Next Steps: Consider exploring advanced Route features such as: • Blue-green deployments using Route traffic splitting • Integration with external load balancers • Custom domain configuration with DNS management • Advanced security policies and WAF integration

This knowledge prepares you for the Red Hat OpenShift Administration II certification and real-world OpenShift cluster management scenarios.
