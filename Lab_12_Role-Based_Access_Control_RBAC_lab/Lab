Lab 12: Role-Based Access Control (RBAC)
Objectives
By the end of this lab, you will be able to:

• Understand the fundamentals of Kubernetes Role-Based Access Control (RBAC) • Create and configure Roles and RoleBindings for different users • Implement ClusterRoles and ClusterRoleBindings for cluster-wide permissions • Restrict access to specific namespaces and resources using RBAC policies • Test and validate user access permissions with different RBAC configurations • Troubleshoot common RBAC permission issues • Apply security best practices for user access management in Kubernetes

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes concepts (pods, services, namespaces) • Familiarity with kubectl command-line tool • Knowledge of YAML file structure and syntax • Understanding of Linux command-line operations • Basic knowledge of user authentication concepts

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides Linux-based cloud machines with Kubernetes pre-installed. Simply click Start Lab to access your environment - no need to build your own VM or install Kubernetes manually.

Your lab environment includes: • Kubernetes cluster (v1.28+) with RBAC enabled • kubectl command-line tool configured • Text editor (nano/vim) for creating YAML files • All necessary permissions to create users and RBAC policies

Task 1: Understanding RBAC Components and Creating Basic Roles
Subtask 1.1: Explore Current RBAC Configuration
First, let's examine the existing RBAC setup in your cluster.

Check the current user context:
kubectl config current-context
View existing roles in the default namespace:
kubectl get roles --all-namespaces
View existing cluster roles:
kubectl get clusterroles | head -20
Examine a sample cluster role to understand its structure:
kubectl describe clusterrole view
Subtask 1.2: Create Development and Production Namespaces
Create namespaces for our RBAC demonstration:
kubectl create namespace development
kubectl create namespace production
kubectl create namespace testing
Verify the namespaces were created:
kubectl get namespaces
Subtask 1.3: Create a Basic Role for Development Environment
Create a role definition file for developers:
cat > developer-role.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: developer-role
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "secrets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets"]
  verbs: ["get", "list", "create", "update", "patch", "delete"]
- apiGroups: [""]
  resources: ["pods/log", "pods/exec"]
  verbs: ["get", "create"]
EOF
Apply the role:
kubectl apply -f developer-role.yaml
Verify the role was created:
kubectl get roles -n development
kubectl describe role developer-role -n development
Subtask 1.4: Create a Read-Only Role for Production Environment
Create a read-only role for production access:
cat > production-readonly-role.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: production
  name: production-readonly
rules:
- apiGroups: [""]
  resources: ["pods", "services", "configmaps", "endpoints"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "daemonsets"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
EOF
Apply the production role:
kubectl apply -f production-readonly-role.yaml
Verify the role creation:
kubectl get roles -n production
kubectl describe role production-readonly -n production
Task 2: Create RoleBindings and Restrict Access to Namespaces
Subtask 2.1: Create Service Accounts for Different Users
Create service accounts to simulate different users:
kubectl create serviceaccount developer-user -n development
kubectl create serviceaccount production-viewer -n production
kubectl create serviceaccount tester-user -n testing
Verify service accounts were created:
kubectl get serviceaccounts -n development
kubectl get serviceaccounts -n production
kubectl get serviceaccounts -n testing
Subtask 2.2: Create RoleBindings for Development Access
Create a RoleBinding to grant developer permissions:
cat > developer-rolebinding.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: developer-binding
  namespace: development
subjects:
- kind: ServiceAccount
  name: developer-user
  namespace: development
roleRef:
  kind: Role
  name: developer-role
  apiGroup: rbac.authorization.k8s.io
EOF
Apply the RoleBinding:
kubectl apply -f developer-rolebinding.yaml
Verify the RoleBinding:
kubectl get rolebindings -n development
kubectl describe rolebinding developer-binding -n development
Subtask 2.3: Create RoleBindings for Production Read-Only Access
Create a RoleBinding for production read-only access:
cat > production-rolebinding.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: production-readonly-binding
  namespace: production
subjects:
- kind: ServiceAccount
  name: production-viewer
  namespace: production
roleRef:
  kind: Role
  name: production-readonly
  apiGroup: rbac.authorization.k8s.io
EOF
Apply the production RoleBinding:
kubectl apply -f production-rolebinding.yaml
Verify the RoleBinding:
kubectl get rolebindings -n production
kubectl describe rolebinding production-readonly-binding -n production
Subtask 2.4: Create ClusterRole for Cross-Namespace Access
Create a ClusterRole for testing across namespaces:
cat > tester-clusterrole.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: tester-clusterrole
rules:
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["namespaces"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list"]
EOF
Apply the ClusterRole:
kubectl apply -f tester-clusterrole.yaml
Create a ClusterRoleBinding:
cat > tester-clusterrolebinding.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tester-cluster-binding
subjects:
- kind: ServiceAccount
  name: tester-user
  namespace: testing
roleRef:
  kind: ClusterRole
  name: tester-clusterrole
  apiGroup: rbac.authorization.k8s.io
EOF
Apply the ClusterRoleBinding:
kubectl apply -f tester-clusterrolebinding.yaml
Verify the ClusterRole and ClusterRoleBinding:
kubectl get clusterroles | grep tester
kubectl get clusterrolebindings | grep tester
kubectl describe clusterrolebinding tester-cluster-binding
Task 3: Test User Access with Different RBAC Permissions
Subtask 3.1: Create Test Resources in Different Namespaces
Create test deployments in each namespace:
kubectl create deployment nginx-dev --image=nginx:latest -n development
kubectl create deployment nginx-prod --image=nginx:latest -n production
kubectl create deployment nginx-test --image=nginx:latest -n testing
Create services for the deployments:
kubectl expose deployment nginx-dev --port=80 --target-port=80 -n development
kubectl expose deployment nginx-prod --port=80 --target-port=80 -n production
kubectl expose deployment nginx-test --port=80 --target-port=80 -n testing
Verify resources were created:
kubectl get all -n development
kubectl get all -n production
kubectl get all -n testing
Subtask 3.2: Test Developer User Permissions
Get the token for the developer service account:
kubectl create token developer-user -n development --duration=3600s > developer-token.txt
DEVELOPER_TOKEN=$(cat developer-token.txt)
Test developer access to development namespace:
kubectl --token=$DEVELOPER_TOKEN get pods -n development
kubectl --token=$DEVELOPER_TOKEN get services -n development
kubectl --token=$DEVELOPER_TOKEN get deployments -n development
Test developer access to production namespace (should fail):
kubectl --token=$DEVELOPER_TOKEN get pods -n production
Test creating resources as developer user:
kubectl --token=$DEVELOPER_TOKEN create deployment test-app --image=nginx:latest -n development
kubectl --token=$DEVELOPER_TOKEN get deployments -n development
Test deleting resources as developer user:
kubectl --token=$DEVELOPER_TOKEN delete deployment test-app -n development
Subtask 3.3: Test Production Viewer Permissions
Get the token for the production viewer service account:
kubectl create token production-viewer -n production --duration=3600s > production-token.txt
PRODUCTION_TOKEN=$(cat production-token.txt)
Test production viewer read access:
kubectl --token=$PRODUCTION_TOKEN get pods -n production
kubectl --token=$PRODUCTION_TOKEN get services -n production
kubectl --token=$PRODUCTION_TOKEN get deployments -n production
Test production viewer write access (should fail):
kubectl --token=$PRODUCTION_TOKEN create deployment unauthorized-app --image=nginx:latest -n production
kubectl --token=$PRODUCTION_TOKEN delete deployment nginx-prod -n production
Test access to other namespaces (should fail):
kubectl --token=$PRODUCTION_TOKEN get pods -n development
kubectl --token=$PRODUCTION_TOKEN get pods -n testing
Subtask 3.4: Test Tester User Cross-Namespace Access
Get the token for the tester service account:
kubectl create token tester-user -n testing --duration=3600s > tester-token.txt
TESTER_TOKEN=$(cat tester-token.txt)
Test tester access across namespaces:
kubectl --token=$TESTER_TOKEN get pods --all-namespaces
kubectl --token=$TESTER_TOKEN get services --all-namespaces
kubectl --token=$TESTER_TOKEN get namespaces
Test tester write access (should fail):
kubectl --token=$TESTER_TOKEN create deployment unauthorized-test --image=nginx:latest -n testing
kubectl --token=$TESTER_TOKEN delete deployment nginx-test -n testing
Subtask 3.5: Verify RBAC Restrictions with kubectl auth can-i
Test what the developer user can do:
kubectl auth can-i create pods --as=system:serviceaccount:development:developer-user -n development
kubectl auth can-i delete deployments --as=system:serviceaccount:development:developer-user -n development
kubectl auth can-i get pods --as=system:serviceaccount:development:developer-user -n production
Test what the production viewer can do:
kubectl auth can-i get pods --as=system:serviceaccount:production:production-viewer -n production
kubectl auth can-i create pods --as=system:serviceaccount:production:production-viewer -n production
kubectl auth can-i delete services --as=system:serviceaccount:production:production-viewer -n production
Test what the tester user can do:
kubectl auth can-i get pods --as=system:serviceaccount:testing:tester-user --all-namespaces
kubectl auth can-i create deployments --as=system:serviceaccount:testing:tester-user -n testing
kubectl auth can-i get namespaces --as=system:serviceaccount:testing:tester-user
Subtask 3.6: Create and Test Custom RBAC Policies
Create a custom role for monitoring purposes:
cat > monitoring-role.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: monitoring-role
rules:
- apiGroups: [""]
  resources: ["pods", "nodes", "services", "endpoints"]
  verbs: ["get", "list"]
- apiGroups: ["apps"]
  resources: ["deployments", "replicasets", "daemonsets"]
  verbs: ["get", "list"]
- apiGroups: ["metrics.k8s.io"]
  resources: ["pods", "nodes"]
  verbs: ["get", "list"]
EOF
Apply the monitoring role:
kubectl apply -f monitoring-role.yaml
Create a service account for monitoring:
kubectl create serviceaccount monitoring-user -n default
Create a ClusterRoleBinding for monitoring:
cat > monitoring-clusterrolebinding.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: monitoring-binding
subjects:
- kind: ServiceAccount
  name: monitoring-user
  namespace: default
roleRef:
  kind: ClusterRole
  name: monitoring-role
  apiGroup: rbac.authorization.k8s.io
EOF
Apply the monitoring ClusterRoleBinding:
kubectl apply -f monitoring-clusterrolebinding.yaml
Test monitoring user permissions:
kubectl create token monitoring-user -n default --duration=3600s > monitoring-token.txt
MONITORING_TOKEN=$(cat monitoring-token.txt)

kubectl --token=$MONITORING_TOKEN get pods --all-namespaces
kubectl --token=$MONITORING_TOKEN get nodes
kubectl --token=$MONITORING_TOKEN create deployment test --image=nginx:latest -n default
Troubleshooting Common RBAC Issues
Issue 1: Permission Denied Errors
If you encounter permission denied errors:

Check if the user has the correct permissions:
kubectl auth can-i <verb> <resource> --as=<user> -n <namespace>
Verify RoleBinding exists and is correctly configured:
kubectl get rolebindings -n <namespace>
kubectl describe rolebinding <binding-name> -n <namespace>
Issue 2: Service Account Token Issues
If service account tokens are not working:

Verify the service account exists:
kubectl get serviceaccounts -n <namespace>
Check if the token is valid and not expired:
kubectl create token <service-account> -n <namespace> --duration=3600s
Issue 3: ClusterRole vs Role Confusion
Remember: • Role: Permissions within a specific namespace • ClusterRole: Cluster-wide permissions or permissions that can be bound to any namespace

Issue 4: Debugging RBAC Policies
Use kubectl auth can-i to test permissions:
kubectl auth can-i --list --as=system:serviceaccount:<namespace>:<service-account>
Check effective permissions:
kubectl describe clusterrolebinding <binding-name>
kubectl describe rolebinding <binding-name> -n <namespace>
Security Best Practices
Principle of Least Privilege
Always grant the minimum permissions necessary
Use namespace-specific Roles instead of ClusterRoles when possible
Regularly audit and review RBAC policies
Example of Secure RBAC Configuration
cat > secure-developer-role.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: development
  name: secure-developer-role
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "create", "delete"]
  resourceNames: [] # Can be used to restrict to specific resources
- apiGroups: [""]
  resources: ["pods/log"]
  verbs: ["get"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "create", "update", "patch"]
  # Explicitly exclude delete to prevent accidental deletion
EOF
Lab Cleanup
To clean up the resources created in this lab:

# Delete deployments
kubectl delete deployment nginx-dev -n development
kubectl delete deployment nginx-prod -n production
kubectl delete deployment nginx-test -n testing

# Delete services
kubectl delete service nginx-dev -n development
kubectl delete service nginx-prod -n production
kubectl delete service nginx-test -n testing

# Delete RoleBindings and ClusterRoleBindings
kubectl delete rolebinding developer-binding -n development
kubectl delete rolebinding production-readonly-binding -n production
kubectl delete clusterrolebinding tester-cluster-binding
kubectl delete clusterrolebinding monitoring-binding

# Delete Roles and ClusterRoles
kubectl delete role developer-role -n development
kubectl delete role production-readonly -n production
kubectl delete clusterrole tester-clusterrole
kubectl delete clusterrole monitoring-role

# Delete Service Accounts
kubectl delete serviceaccount developer-user -n development
kubectl delete serviceaccount production-viewer -n production
kubectl delete serviceaccount tester-user -n testing
kubectl delete serviceaccount monitoring-user -n default

# Delete namespaces (optional)
kubectl delete namespace development
kubectl delete namespace production
kubectl delete namespace testing

# Clean up token files
rm -f developer-token.txt production-token.txt tester-token.txt monitoring-token.txt
Conclusion
In this comprehensive lab, you have successfully:

• Mastered RBAC Fundamentals: You learned the core components of Kubernetes RBAC including Roles, ClusterRoles, RoleBindings, and ClusterRoleBindings, understanding how they work together to control access to cluster resources.

• Implemented Namespace-Based Security: You created different roles for development and production environments, demonstrating how to restrict access to specific namespaces and implement environment-based security policies.

• Configured User Access Controls: You successfully created service accounts representing different user types (developers, production viewers, testers) and bound them to appropriate roles with varying levels of permissions.

• Tested Permission Boundaries: Through hands-on testing, you verified that RBAC policies work as expected, confirming that users can only perform actions they are explicitly authorized to do while being denied unauthorized access.

• Applied Security Best Practices: You implemented the principle of least privilege by granting only the minimum necessary permissions and learned how to audit and troubleshoot RBAC configurations effectively.

Why This Matters: RBAC is a critical security feature in Kubernetes that enables organizations to implement fine-grained access control, ensuring that users and applications can only access the resources they need. This is essential for:

Security Compliance: Meeting regulatory requirements and security standards
Multi-tenancy: Safely sharing cluster resources among different teams and applications
Operational Safety: Preventing accidental or malicious changes to critical resources
Audit and Governance: Maintaining clear records of who can access what resources
The skills you've developed in this lab are directly applicable to real-world Kubernetes administration and are essential for the Red Hat OpenShift Administration II certification. You now have the knowledge to design, implement, and maintain secure access control policies in production Kubernetes environments.
