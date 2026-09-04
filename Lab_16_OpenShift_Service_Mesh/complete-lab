Lab 16: OpenShift Service Mesh
Objectives
By the end of this lab, you will be able to:

• Install and configure OpenShift Service Mesh (based on Istio) on an OpenShift cluster • Implement mutual TLS (mTLS) authentication for secure service-to-service communication • Deploy sample applications within the service mesh • Configure traffic management policies including routing and load balancing • Monitor service mesh traffic using built-in observability tools • Apply security policies and access controls within the mesh • Troubleshoot common service mesh configuration issues

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, services, deployments) • Familiarity with OpenShift fundamentals and CLI operations • Knowledge of microservices architecture principles • Understanding of networking concepts including TLS/SSL • Experience with YAML configuration files • Basic command-line interface skills

Lab Environment
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift cluster access. Simply click Start Lab to begin - no need to build your own virtual machine or install OpenShift from scratch.

Your lab environment includes: • OpenShift 4.12+ cluster with admin privileges • Pre-installed OpenShift CLI (oc) • Internet connectivity for downloading operators • Sufficient cluster resources (minimum 8 CPU cores, 16GB RAM)

Task 1: Install OpenShift Service Mesh
Subtask 1.1: Install Required Operators
The OpenShift Service Mesh requires three operators to be installed in a specific order.

Log into your OpenShift cluster:
oc login -u admin -p admin https://api.cluster.example.com:6443
Verify cluster access:
oc whoami
oc get nodes
Create the operator installation namespace:
oc new-project openshift-operators-redhat
oc new-project openshift-distributed-tracing
Install the Elasticsearch Operator:
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: elasticsearch-operator
  namespace: openshift-operators-redhat
spec:
  channel: stable
  installPlanApproval: Automatic
  name: elasticsearch-operator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
Install the Red Hat OpenShift distributed tracing platform (Jaeger):
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: jaeger-product
  namespace: openshift-distributed-tracing
spec:
  channel: stable
  installPlanApproval: Automatic
  name: jaeger-product
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
Install the Kiali Operator:
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: kiali-ossm
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: kiali-ossm
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
Install the Red Hat OpenShift Service Mesh Operator:
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: servicemeshoperator
  namespace: openshift-operators
spec:
  channel: stable
  installPlanApproval: Automatic
  name: servicemeshoperator
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
Verify operator installations:
oc get csv -n openshift-operators
oc get csv -n openshift-operators-redhat
oc get csv -n openshift-distributed-tracing
Wait for all operators to show Succeeded status before proceeding.

Subtask 1.2: Create Service Mesh Control Plane
Create the istio-system namespace:
oc new-project istio-system
Create the ServiceMeshControlPlane resource:
cat << EOF | oc apply -f -
apiVersion: maistra.io/v2
kind: ServiceMeshControlPlane
metadata:
  name: basic
  namespace: istio-system
spec:
  version: v2.4
  tracing:
    type: Jaeger
    sampling: 10000
  addons:
    jaeger:
      name: jaeger
      install:
        storage:
          type: Memory
    kiali:
      name: kiali
      enabled: true
      install: {}
    grafana:
      enabled: true
      install: {}
  policy:
    type: Istiod
  telemetry:
    type: Istiod
  security:
    dataPlane:
      mtls: true
EOF
Monitor the control plane installation:
oc get smcp -n istio-system
oc get pods -n istio-system
Wait for the control plane status to show ComponentsReady.

Subtask 1.3: Create Service Mesh Member Roll
Create a ServiceMeshMemberRoll to include application namespaces:
cat << EOF | oc apply -f -
apiVersion: maistra.io/v1
kind: ServiceMeshMemberRoll
metadata:
  name: default
  namespace: istio-system
spec:
  members:
  - bookinfo
  - production
EOF
Verify the member roll:
oc get smmr -n istio-system
oc describe smmr default -n istio-system
Task 2: Deploy Sample Applications
Subtask 2.1: Deploy Bookinfo Application
Create the bookinfo namespace:
oc new-project bookinfo
Deploy the Bookinfo application:
oc apply -n bookinfo -f https://raw.githubusercontent.com/Maistra/istio/maistra-2.4/samples/bookinfo/platform/kube/bookinfo.yaml
Create the Bookinfo gateway:
cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: bookinfo-gateway
  namespace: bookinfo
spec:
  selector:
    istio: ingressgateway
  servers:
  - port:
      number: 80
      name: http
      protocol: HTTP
    hosts:
    - "*"
---
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: bookinfo
  namespace: bookinfo
spec:
  hosts:
  - "*"
  gateways:
  - bookinfo-gateway
  http:
  - match:
    - uri:
        exact: /productpage
    - uri:
        prefix: /static
    - uri:
        exact: /login
    - uri:
        exact: /logout
    - uri:
        prefix: /api/v1/products
    route:
    - destination:
        host: productpage
        port:
          number: 9080
EOF
Verify the deployment:
oc get pods -n bookinfo
oc get svc -n bookinfo
oc get gateway -n bookinfo
oc get virtualservice -n bookinfo
Get the ingress gateway URL:
export INGRESS_HOST=$(oc get route istio-ingressgateway -n istio-system -o jsonpath='{.spec.host}')
echo "Bookinfo URL: http://$INGRESS_HOST/productpage"
Subtask 2.2: Test Application Connectivity
Access the Bookinfo application:
curl -s http://$INGRESS_HOST/productpage | grep -o "<title>.*</title>"
Generate some traffic:
for i in {1..10}; do
  curl -s http://$INGRESS_HOST/productpage > /dev/null
  echo "Request $i completed"
  sleep 1
done
Task 3: Configure Mutual TLS for Secure Communication
Subtask 3.1: Verify Current mTLS Status
Check the current mTLS configuration:
oc get peerauthentication -n bookinfo
oc get destinationrule -n bookinfo
Verify mTLS is working by checking proxy configuration:
# Get a productpage pod name
PRODUCTPAGE_POD=$(oc get pod -n bookinfo -l app=productpage -o jsonpath='{.items[0].metadata.name}')

# Check the proxy configuration
oc exec -n bookinfo $PRODUCTPAGE_POD -c istio-proxy -- pilot-agent request GET config_dump | grep -A 5 -B 5 "tls_context"
Subtask 3.2: Configure Strict mTLS Policy
Create a PeerAuthentication policy for strict mTLS:
cat << EOF | oc apply -f -
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: default
  namespace: bookinfo
spec:
  mtls:
    mode: STRICT
EOF
Create DestinationRule for mTLS:
cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: default
  namespace: bookinfo
spec:
  host: "*.local"
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
---
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: bookinfo-services
  namespace: bookinfo
spec:
  host: "*.bookinfo.svc.cluster.local"
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
EOF
Verify mTLS is enforced:
oc get peerauthentication -n bookinfo
oc get destinationrule -n bookinfo
Subtask 3.3: Test mTLS Enforcement
Test communication between services with mTLS:
# Generate traffic to verify mTLS is working
for i in {1..5}; do
  curl -s http://$INGRESS_HOST/productpage > /dev/null
  echo "mTLS request $i completed"
  sleep 2
done
Deploy a test pod without sidecar to verify mTLS blocks unauthorized access:
cat << EOF | oc apply -f -
apiVersion: v1
kind: Pod
metadata:
  name: sleep-no-sidecar
  namespace: bookinfo
  annotations:
    sidecar.istio.io/inject: "false"
spec:
  containers:
  - name: sleep
    image: curlimages/curl
    command: ["/bin/sleep", "3600"]
EOF
Test that the non-mesh pod cannot access mesh services:
# Wait for pod to be ready
oc wait --for=condition=Ready pod/sleep-no-sidecar -n bookinfo --timeout=60s

# Try to access a service (this should fail with mTLS strict mode)
oc exec -n bookinfo sleep-no-sidecar -- curl -s http://productpage:9080/productpage --connect-timeout 5 || echo "Connection blocked by mTLS - this is expected"
Task 4: Monitor Traffic and Configure Policies
Subtask 4.1: Access Kiali Dashboard
Get Kiali route:
oc get route kiali -n istio-system
export KIALI_URL=$(oc get route kiali -n istio-system -o jsonpath='{.spec.host}')
echo "Kiali URL: https://$KIALI_URL"
Get Kiali credentials:
oc get secret kiali -n istio-system -o jsonpath='{.data.username}' | base64 -d; echo
oc get secret kiali -n istio-system -o jsonpath='{.data.passphrase}' | base64 -d; echo
Generate traffic for monitoring:
# Run this in background to generate continuous traffic
for i in {1..50}; do
  curl -s http://$INGRESS_HOST/productpage > /dev/null
  sleep 2
done &
Subtask 4.2: Configure Traffic Management Policies
Create destination rules for load balancing:
cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: reviews
  namespace: bookinfo
spec:
  host: reviews
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
    loadBalancer:
      simple: LEAST_CONN
  subsets:
  - name: v1
    labels:
      version: v1
  - name: v2
    labels:
      version: v2
  - name: v3
    labels:
      version: v3
EOF
Create a virtual service for traffic splitting:
cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: reviews
  namespace: bookinfo
spec:
  host: reviews
  http:
  - match:
    - headers:
        end-user:
          exact: jason
    route:
    - destination:
        host: reviews
        subset: v2
  - route:
    - destination:
        host: reviews
        subset: v1
      weight: 80
    - destination:
        host: reviews
        subset: v3
      weight: 20
EOF
Test the traffic routing:
# Test normal traffic (should go 80% to v1, 20% to v3)
for i in {1..10}; do
  curl -s http://$INGRESS_HOST/productpage | grep -o "glyphicon-star-empty\|glyphicon-star\|color: red"
  sleep 1
done

# Test with jason user (should go to v2)
for i in {1..5}; do
  curl -s -H "end-user: jason" http://$INGRESS_HOST/productpage | grep -o "glyphicon-star-empty\|glyphicon-star\|color: red"
  sleep 1
done
Subtask 4.3: Configure Circuit Breaker
Create a circuit breaker policy:
cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: productpage-circuit-breaker
  namespace: bookinfo
spec:
  host: productpage
  trafficPolicy:
    tls:
      mode: ISTIO_MUTUAL
    connectionPool:
      tcp:
        maxConnections: 1
      http:
        http1MaxPendingRequests: 1
        maxRequestsPerConnection: 2
    outlierDetection:
      consecutiveErrors: 1
      interval: 1s
      baseEjectionTime: 3s
      maxEjectionPercent: 100
EOF
Test the circuit breaker:
# Generate load to trigger circuit breaker
for i in {1..20}; do
  curl -s http://$INGRESS_HOST/productpage > /dev/null &
done
wait
Subtask 4.4: Configure Rate Limiting
Create a rate limiting policy:
cat << EOF | oc apply -f -
apiVersion: networking.istio.io/v1alpha3
kind: EnvoyFilter
metadata:
  name: filter-ratelimit
  namespace: istio-system
spec:
  workloadSelector:
    labels:
      istio: ingressgateway
  configPatches:
  - applyTo: HTTP_FILTER
    match:
      context: GATEWAY
      listener:
        filterChain:
          filter:
            name: "envoy.filters.network.http_connection_manager"
    patch:
      operation: INSERT_BEFORE
      value:
        name: envoy.filters.http.local_ratelimit
        typed_config:
          "@type": type.googleapis.com/udpa.type.v1.TypedStruct
          type_url: type.googleapis.com/envoy.extensions.filters.http.local_ratelimit.v3.LocalRateLimit
          value:
            stat_prefix: http_local_rate_limiter
            token_bucket:
              max_tokens: 10
              tokens_per_fill: 10
              fill_interval: 60s
            filter_enabled:
              runtime_key: local_rate_limit_enabled
              default_value:
                numerator: 100
                denominator: HUNDRED
            filter_enforced:
              runtime_key: local_rate_limit_enforced
              default_value:
                numerator: 100
                denominator: HUNDRED
            response_headers_to_add:
            - append: false
              header:
                key: x-local-rate-limit
                value: 'true'
EOF
Task 5: Advanced Security and Observability
Subtask 5.1: Configure Authorization Policies
Create an authorization policy to deny all traffic by default:
cat << EOF | oc apply -f -
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: deny-all
  namespace: bookinfo
spec:
  {}
EOF
Create specific allow policies:
cat << EOF | oc apply -f -
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-productpage
  namespace: bookinfo
spec:
  selector:
    matchLabels:
      app: productpage
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/istio-system/sa/istio-ingressgateway-service-account"]
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-reviews
  namespace: bookinfo
spec:
  selector:
    matchLabels:
      app: reviews
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/bookinfo/sa/bookinfo-productpage"]
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-details
  namespace: bookinfo
spec:
  selector:
    matchLabels:
      app: details
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/bookinfo/sa/bookinfo-productpage"]
---
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: allow-ratings
  namespace: bookinfo
spec:
  selector:
    matchLabels:
      app: ratings
  rules:
  - from:
    - source:
        principals: ["cluster.local/ns/bookinfo/sa/bookinfo-reviews"]
EOF
Test the authorization policies:
# This should work
curl -s http://$INGRESS_HOST/productpage | grep -o "<title>.*</title>"
Subtask 5.2: Access Grafana Dashboard
Get Grafana route:
oc get route grafana -n istio-system
export GRAFANA_URL=$(oc get route grafana -n istio-system -o jsonpath='{.spec.host}')
echo "Grafana URL: https://$GRAFANA_URL"
Generate traffic for metrics:
for i in {1..30}; do
  curl -s http://$INGRESS_HOST/productpage > /dev/null
  sleep 1
done
Subtask 5.3: Access Jaeger Tracing
Get Jaeger route:
oc get route jaeger -n istio-system
export JAEGER_URL=$(oc get route jaeger -n istio-system -o jsonpath='{.spec.host}')
echo "Jaeger URL: https://$JAEGER_URL"
Generate traced requests:
for i in {1..10}; do
  curl -s -H "x-request-id: test-$i" http://$INGRESS_HOST/productpage > /dev/null
  echo "Traced request $i sent"
  sleep 2
done
Task 6: Troubleshooting and Validation
Subtask 6.1: Validate Service Mesh Configuration
Check control plane status:
oc get smcp -n istio-system
oc get pods -n istio-system
Verify sidecar injection:
oc get pods -n bookinfo -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.spec.containers[*].name}{"\n"}{end}'
Check proxy configuration:
# Get proxy configuration for a pod
PRODUCTPAGE_POD=$(oc get pod -n bookinfo -l app=productpage -o jsonpath='{.items[0].metadata.name}')
oc exec -n bookinfo $PRODUCTPAGE_POD -c istio-proxy -- pilot-agent request GET stats | grep cluster.outbound
Subtask 6.2: Common Troubleshooting Commands
Check Envoy proxy logs:
oc logs -n bookinfo $PRODUCTPAGE_POD -c istio-proxy --tail=50
Verify mTLS certificates:
oc exec -n bookinfo $PRODUCTPAGE_POD -c istio-proxy -- openssl s_client -connect reviews:9080 -cert /etc/ssl/certs/cert-chain.pem -key /etc/ssl/private/key.pem -CAfile /etc/ssl/certs/root-cert.pem -verify_return_error < /dev/null
Check service mesh member status:
oc get smmr default -n istio-system -o yaml
Subtask 6.3: Performance Validation
Run performance test:
# Install fortio for load testing
oc apply -f https://raw.githubusercontent.com/istio/istio/release-1.17/samples/httpbin/sample-client/fortio-deploy.yaml -n bookinfo

# Wait for fortio pod
oc wait --for=condition=Ready pod -l app=fortio -n bookinfo --timeout=60s

# Run load test
FORTIO_POD=$(oc get pods -n bookinfo -l app=fortio -o jsonpath='{.items[0].metadata.name}')
oc exec -n bookinfo $FORTIO_POD -c fortio -- /usr/bin/fortio load -c 2 -qps 0 -n 20 -loglevel Warning http://productpage:9080/productpage
Monitor resource usage:
oc top pods -n istio-system
oc top pods -n bookinfo
Cleanup
Remove Test Resources
Remove authorization policies:
oc delete authorizationpolicy --all -n bookinfo
Remove traffic management policies:
oc delete virtualservice --all -n bookinfo
oc delete destinationrule --all -n bookinfo
oc delete gateway --all -n bookinfo
Remove applications:
oc delete all --all -n bookinfo
Remove service mesh (optional):
oc delete smcp basic -n istio-system
oc delete smmr default -n istio-system
Conclusion
In this comprehensive lab, you have successfully:

• Installed OpenShift Service Mesh with all required operators and components, creating a production-ready service mesh environment • Configured mutual TLS (mTLS) authentication to secure all service-to-service communications within the mesh • Deployed and managed sample applications within the service mesh, demonstrating real-world microservices scenarios • Implemented advanced traffic management policies including load balancing, traffic splitting, circuit breakers, and rate limiting • Applied security policies using authorization rules to control access between services • Utilized observability tools including Kiali for service topology, Grafana for metrics, and Jaeger for distributed tracing • Performed troubleshooting and validation techniques essential for maintaining service mesh operations

Why This Matters: Service mesh technology is crucial for modern microservices architectures as it provides:

Security: Automatic mTLS encryption and fine-grained access controls
Observability: Deep insights into service behavior and performance
Traffic Management: Sophisticated routing and resilience patterns
Policy Enforcement: Consistent security and operational policies across all services
These skills are essential for Red Hat OpenShift Administration II certification and are highly valued in enterprise environments where secure, observable, and manageable microservices are critical for business operations. The hands-on experience gained in this lab directly applies to real-world scenarios where you'll need to implement, configure, and maintain service mesh infrastructure in production OpenShift clusters.
