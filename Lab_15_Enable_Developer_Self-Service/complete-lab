Lab 15: Enable Developer Self-Service
Objectives
By the end of this lab, students will be able to:

• Create and configure OpenShift projects with appropriate resource quotas to limit resource consumption • Implement Role-Based Access Control (RBAC) using RoleBindings to restrict developer permissions within projects • Configure admission controllers to enforce organizational policies and governance • Understand the principles of multi-tenant environments and developer self-service capabilities • Apply security best practices for developer access management in production OpenShift clusters

Prerequisites
Before starting this lab, students should have:

• Basic understanding of Kubernetes/OpenShift concepts (pods, services, deployments) • Familiarity with YAML syntax and configuration files • Knowledge of Linux command-line operations • Understanding of Role-Based Access Control (RBAC) concepts • Access to an OpenShift cluster with cluster-admin privileges • Basic knowledge of resource management concepts (CPU, memory, storage)

Lab Environment
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift cluster access. Simply click Start Lab to begin - no need to build your own virtual machine or install additional software.

Your lab environment includes: • OpenShift cluster with cluster-admin access • Pre-installed oc command-line tool • Web console access for visual management • Sample applications and configurations

Task 1: Create a Project and Apply Resource Quotas
Subtask 1.1: Create a New Project for Developer Team
First, we'll create a dedicated project for a development team and configure it with appropriate resource limitations.

Login to OpenShift cluster using the command line:
oc login -u admin -p admin https://api.cluster.example.com:6443
Create a new project for the development team:
oc new-project dev-team-alpha --display-name="Development Team Alpha" --description="Self-service project for Alpha development team"
Verify the project creation:
oc get projects | grep dev-team-alpha
oc project dev-team-alpha
Subtask 1.2: Create and Apply Resource Quotas
Resource quotas prevent any single project from consuming excessive cluster resources.

Create a resource quota configuration file:
cat > resource-quota.yaml << 'EOF'
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dev-team-quota
  namespace: dev-team-alpha
spec:
  hard:
    # Compute Resources
    requests.cpu: "4"
    requests.memory: 8Gi
    limits.cpu: "8"
    limits.memory: 16Gi
    
    # Storage Resources
    requests.storage: 50Gi
    persistentvolumeclaims: "10"
    
    # Object Counts
    pods: "20"
    services: "10"
    secrets: "20"
    configmaps: "20"
    replicationcontrollers: "10"
    
    # OpenShift Specific
    openshift.io/imagestreams: "10"
    openshift.io/imagestreamtags: "20"
EOF
Apply the resource quota:
oc apply -f resource-quota.yaml
Verify the resource quota is active:
oc get resourcequota -n dev-team-alpha
oc describe resourcequota dev-team-quota -n dev-team-alpha
Subtask 1.3: Create Limit Ranges for Default Resource Constraints
Limit ranges set default and maximum resource limits for individual containers and pods.

Create a limit range configuration:
cat > limit-range.yaml << 'EOF'
apiVersion: v1
kind: LimitRange
metadata:
  name: dev-team-limits
  namespace: dev-team-alpha
spec:
  limits:
  # Container limits
  - type: Container
    default:
      cpu: 200m
      memory: 256Mi
    defaultRequest:
      cpu: 100m
      memory: 128Mi
    max:
      cpu: 1000m
      memory: 2Gi
    min:
      cpu: 50m
      memory: 64Mi
  
  # Pod limits
  - type: Pod
    max:
      cpu: 2000m
      memory: 4Gi
    min:
      cpu: 100m
      memory: 128Mi
  
  # Persistent Volume Claim limits
  - type: PersistentVolumeClaim
    max:
      storage: 10Gi
    min:
      storage: 1Gi
EOF
Apply the limit range:
oc apply -f limit-range.yaml
Verify the limit range:
oc get limitrange -n dev-team-alpha
oc describe limitrange dev-team-limits -n dev-team-alpha
Task 2: Implement RoleBindings for Developers to Restrict Permissions
Subtask 2.1: Create Developer User Accounts
For this lab, we'll create sample developer users and configure their access.

Create developer users (simulated for lab purposes):
# Create user identities (in production, these would come from LDAP/OAuth)
oc create user developer1
oc create user developer2
oc create user developer3

# Create corresponding identities
oc create identity htpasswd:developer1
oc create identity htpasswd:developer2
oc create identity htpasswd:developer3

# Link users to identities
oc create useridentitymapping htpasswd:developer1 developer1
oc create useridentitymapping htpasswd:developer2 developer2
oc create useridentitymapping htpasswd:developer3 developer3
Subtask 2.2: Create Custom Role for Developers
We'll create a custom role that provides appropriate permissions for developers without giving them excessive privileges.

Create a custom developer role:
cat > developer-role.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: dev-team-alpha
  name: developer-role
rules:
# Allow full access to most resources within the namespace
- apiGroups: [""]
  resources: ["pods", "pods/log", "pods/exec", "pods/portforward"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

- apiGroups: [""]
  resources: ["services", "endpoints", "configmaps"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# Limited secret access (can create/read but not list all secrets)
- apiGroups: [""]
  resources: ["secrets"]
  verbs: ["get", "create", "update", "patch", "delete"]
  resourceNames: [] # Can be restricted to specific secret names

# Deployment and ReplicaSet management
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# OpenShift specific resources
- apiGroups: ["image.openshift.io"]
  resources: ["imagestreams", "imagestreamtags"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

- apiGroups: ["build.openshift.io"]
  resources: ["builds", "buildconfigs"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

- apiGroups: ["route.openshift.io"]
  resources: ["routes"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# Read-only access to resource quotas and limit ranges
- apiGroups: [""]
  resources: ["resourcequotas", "limitranges"]
  verbs: ["get", "list", "watch"]

# Deny access to sensitive resources
# (This is handled by not including them in the allowed resources)
EOF
Apply the custom role:
oc apply -f developer-role.yaml
Verify the role creation:
oc get role developer-role -n dev-team-alpha
oc describe role developer-role -n dev-team-alpha
Subtask 2.3: Create RoleBindings for Developer Access
Now we'll bind the developers to the custom role within the project.

Create RoleBinding for individual developers:
cat > developer-rolebinding.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: dev-team-alpha
subjects:
- kind: User
  name: developer1
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: developer2
  apiGroup: rbac.authorization.k8s.io
- kind: User
  name: developer3
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
EOF
Apply the RoleBinding:
oc apply -f developer-rolebinding.yaml
Create a separate RoleBinding for project viewing (optional - for read-only access to project metadata):
oc adm policy add-role-to-user view developer1 -n dev-team-alpha
oc adm policy add-role-to-user view developer2 -n dev-team-alpha
oc adm policy add-role-to-user view developer3 -n dev-team-alpha
Subtask 2.4: Test Developer Permissions
Let's verify that the permissions are working correctly.

Test developer access (simulate login as developer1):
# Test what resources developer1 can access
oc auth can-i create pods --as=developer1 -n dev-team-alpha
oc auth can-i delete deployments --as=developer1 -n dev-team-alpha
oc auth can-i get secrets --as=developer1 -n dev-team-alpha

# Test what they cannot access
oc auth can-i create projects --as=developer1
oc auth can-i delete resourcequotas --as=developer1 -n dev-team-alpha
oc auth can-i get nodes --as=developer1
Create a test deployment as a developer:
cat > test-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
  namespace: dev-team-alpha
  labels:
    app: test-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: test-container
        image: nginx:1.20
        ports:
        - containerPort: 80
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF
Deploy the test application:
oc apply -f test-app.yaml --as=developer1
oc get deployments -n dev-team-alpha
oc get pods -n dev-team-alpha
Task 3: Set Up Admission Controllers for Policy Enforcement
Subtask 3.1: Configure Network Policies for Project Isolation
Network policies provide micro-segmentation and control traffic flow between projects.

Create a default deny-all network policy:
cat > network-policy-deny-all.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: deny-all-traffic
  namespace: dev-team-alpha
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF
Create an allow internal communication policy:
cat > network-policy-allow-internal.yaml << 'EOF'
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-internal-communication
  namespace: dev-team-alpha
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: dev-team-alpha
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: dev-team-alpha
  # Allow DNS resolution
  - to: []
    ports:
    - protocol: UDP
      port: 53
  # Allow external HTTPS traffic (for image pulls, etc.)
  - to: []
    ports:
    - protocol: TCP
      port: 443
    - protocol: TCP
      port: 80
EOF
Apply the network policies:
# First label the namespace
oc label namespace dev-team-alpha name=dev-team-alpha

# Apply policies
oc apply -f network-policy-deny-all.yaml
oc apply -f network-policy-allow-internal.yaml
Verify network policies:
oc get networkpolicy -n dev-team-alpha
oc describe networkpolicy deny-all-traffic -n dev-team-alpha
Subtask 3.2: Configure Pod Security Standards
Pod Security Standards replace Pod Security Policies and provide built-in security controls.

Configure Pod Security Standards for the namespace:
# Set pod security standards on the namespace
oc label namespace dev-team-alpha \
  pod-security.kubernetes.io/enforce=restricted \
  pod-security.kubernetes.io/audit=restricted \
  pod-security.kubernetes.io/warn=restricted
Create a test deployment that violates security standards:
cat > insecure-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: insecure-app
  namespace: dev-team-alpha
spec:
  replicas: 1
  selector:
    matchLabels:
      app: insecure-app
  template:
    metadata:
      labels:
        app: insecure-app
    spec:
      containers:
      - name: insecure-container
        image: nginx:1.20
        securityContext:
          runAsUser: 0  # This violates restricted policy
          privileged: true  # This also violates restricted policy
        ports:
        - containerPort: 80
EOF
Try to deploy the insecure application:
oc apply -f insecure-app.yaml
# This should fail or show warnings due to security policy violations
Create a compliant secure application:
cat > secure-app.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: secure-app
  namespace: dev-team-alpha
spec:
  replicas: 1
  selector:
    matchLabels:
      app: secure-app
  template:
    metadata:
      labels:
        app: secure-app
    spec:
      securityContext:
        runAsNonRoot: true
        runAsUser: 1001
        fsGroup: 1001
        seccompProfile:
          type: RuntimeDefault
      containers:
      - name: secure-container
        image: nginx:1.20
        securityContext:
          allowPrivilegeEscalation: false
          runAsNonRoot: true
          runAsUser: 1001
          capabilities:
            drop:
            - ALL
        ports:
        - containerPort: 8080
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF
Deploy the secure application:
oc apply -f secure-app.yaml
oc get pods -n dev-team-alpha -l app=secure-app
Subtask 3.3: Implement Custom Admission Controllers with ValidatingAdmissionWebhooks
For advanced policy enforcement, we can create custom validation rules.

Create a simple validation policy using OPA Gatekeeper (if available):
cat > require-labels-policy.yaml << 'EOF'
apiVersion: templates.gatekeeper.sh/v1beta1
kind: ConstraintTemplate
metadata:
  name: k8srequiredlabels
spec:
  crd:
    spec:
      names:
        kind: K8sRequiredLabels
      validation:
        openAPIV3Schema:
          type: object
          properties:
            labels:
              type: array
              items:
                type: string
  targets:
    - target: admission.k8s.gatekeeper.sh
      rego: |
        package k8srequiredlabels
        
        violation[{"msg": msg}] {
          required := input.parameters.labels
          provided := input.review.object.metadata.labels
          missing := required[_]
          not provided[missing]
          msg := sprintf("Missing required label: %v", [missing])
        }
---
apiVersion: constraints.gatekeeper.sh/v1beta1
kind: K8sRequiredLabels
metadata:
  name: must-have-environment-label
spec:
  match:
    kinds:
      - apiGroups: ["apps"]
        kinds: ["Deployment"]
    namespaces: ["dev-team-alpha"]
  parameters:
    labels: ["environment", "team"]
EOF
Alternative: Create a simple validation using built-in admission controllers:
# Configure the namespace to require specific annotations
oc annotate namespace dev-team-alpha \
  openshift.io/node-selector="node-role.kubernetes.io/worker=" \
  scheduler.alpha.kubernetes.io/default-tolerations='[{"operator": "Equal", "value": "worker", "effect": "NoSchedule", "key": "node-role.kubernetes.io/worker"}]'
Subtask 3.4: Test Policy Enforcement
Let's verify that our admission controllers are working properly.

Test deployment without required labels (if using Gatekeeper):
cat > test-deployment-no-labels.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-no-labels
  namespace: dev-team-alpha
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-no-labels
  template:
    metadata:
      labels:
        app: test-no-labels
    spec:
      containers:
      - name: test-container
        image: nginx:1.20
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF
Test deployment with required labels:
cat > test-deployment-with-labels.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-with-labels
  namespace: dev-team-alpha
  labels:
    environment: development
    team: alpha
spec:
  replicas: 1
  selector:
    matchLabels:
      app: test-with-labels
  template:
    metadata:
      labels:
        app: test-with-labels
        environment: development
        team: alpha
    spec:
      containers:
      - name: test-container
        image: nginx:1.20
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 200m
            memory: 256Mi
EOF
Apply both deployments and observe the results:
oc apply -f test-deployment-no-labels.yaml
oc apply -f test-deployment-with-labels.yaml
Verification and Testing
Verify Resource Quotas are Working
Check current resource usage:
oc describe resourcequota dev-team-quota -n dev-team-alpha
Try to exceed quota limits:
cat > quota-test.yaml << 'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: quota-test
  namespace: dev-team-alpha
spec:
  replicas: 25  # This should exceed the pod limit of 20
  selector:
    matchLabels:
      app: quota-test
  template:
    metadata:
      labels:
        app: quota-test
    spec:
      containers:
      - name: test-container
        image: nginx:1.20
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
EOF
oc apply -f quota-test.yaml
oc get pods -n dev-team-alpha | grep quota-test | wc -l
Verify RBAC is Working
Test developer permissions:
# These should succeed
oc auth can-i create pods --as=developer1 -n dev-team-alpha
oc auth can-i get services --as=developer1 -n dev-team-alpha

# These should fail
oc auth can-i delete resourcequotas --as=developer1 -n dev-team-alpha
oc auth can-i create projects --as=developer1
oc auth can-i get nodes --as=developer1
Verify Network Policies
Test network connectivity:
# Create a test pod for network testing
oc run network-test --image=busybox --rm -it --restart=Never -n dev-team-alpha -- /bin/sh

# Inside the pod, test connectivity
# nslookup kubernetes.default.svc.cluster.local  # Should work (DNS)
# wget -qO- http://secure-app:8080  # Should work (internal)
# wget -qO- http://google.com  # Should work (external HTTP/HTTPS)
Troubleshooting Common Issues
Issue 1: Resource Quota Not Enforcing
Problem: Deployments are created even when they should exceed quotas.

Solution:

# Check if resource requests are specified
oc get deployment <deployment-name> -o yaml | grep -A 10 resources

# Ensure limit ranges are applied
oc get limitrange -n dev-team-alpha
Issue 2: RBAC Permissions Not Working
Problem: Users can access resources they shouldn't be able to.

Solution:

# Check role bindings
oc get rolebindings -n dev-team-alpha
oc describe rolebinding developer-binding -n dev-team-alpha

# Verify user identity
oc whoami --as=developer1
Issue 3: Network Policies Blocking Required Traffic
Problem: Applications cannot communicate when they should be able to.

Solution:

# Check network policies
oc get networkpolicy -n dev-team-alpha
oc describe networkpolicy allow-internal-communication -n dev-team-alpha

# Verify namespace labels
oc get namespace dev-team-alpha --show-labels
Issue 4: Pod Security Standards Too Restrictive
Problem: Legitimate applications are being blocked by security policies.

Solution:

# Check pod security labels
oc get namespace dev-team-alpha -o yaml | grep pod-security

# Review pod security context
oc get pod <pod-name> -o yaml | grep -A 20 securityContext
Cleanup
To clean up the lab environment:

# Delete the project (this removes all resources)
oc delete project dev-team-alpha

# Remove users (if created for lab)
oc delete user developer1 developer2 developer3
oc delete identity htpasswd:developer1 htpasswd:developer2 htpasswd:developer3

# Clean up any remaining files
rm -f *.yaml
Conclusion
In this lab, you have successfully implemented a comprehensive developer self-service environment in OpenShift. Here's what you accomplished:

Resource Management: You created resource quotas and limit ranges that prevent any single project from consuming excessive cluster resources while providing reasonable defaults for developer workloads.

Security and Access Control: You implemented Role-Based Access Control (RBAC) that gives developers the permissions they need to be productive while preventing them from accessing sensitive cluster resources or other projects.

Policy Enforcement: You configured admission controllers including Pod Security Standards and Network Policies that automatically enforce organizational security and compliance requirements.

Multi-Tenancy: You established proper project isolation that allows multiple development teams to work independently without interfering with each other.

This self-service model is crucial for production OpenShift environments because it:

Increases Developer Productivity: Developers can deploy and manage their applications without waiting for operations teams
Reduces Operational Overhead: Platform teams spend less time on routine deployment tasks
Improves Security: Automated policy enforcement is more consistent than manual reviews
Enables Scalability: The platform can support many more development teams with the same operational staff
Provides Governance: Resource quotas and policies ensure fair resource usage and compliance
The skills you've learned in this lab are essential for OpenShift administrators who need to balance developer agility with operational control and security requirements in production environments.
