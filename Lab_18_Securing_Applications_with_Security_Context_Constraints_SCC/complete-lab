Lab 18: Securing Applications with Security Context Constraints (SCC)
Objectives
By the end of this lab, you will be able to:

• Understand the purpose and importance of Security Context Constraints (SCCs) in OpenShift • Create custom SCCs to control pod security policies • Assign SCCs to specific service accounts for granular security control • Test and validate different security contexts for containerized applications • Implement security best practices for production OpenShift environments • Troubleshoot common SCC-related issues and access denials

Prerequisites
Before starting this lab, you should have:

• Basic understanding of Kubernetes/OpenShift concepts (pods, services, deployments) • Familiarity with YAML configuration files • Knowledge of Linux command line operations • Understanding of container security concepts • Access to an OpenShift cluster with cluster-admin privileges • Basic knowledge of service accounts and RBAC concepts

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift access. Simply click Start Lab to begin - no need to build your own VM or install additional software.

Your lab environment includes: • OpenShift cluster with administrative access • Pre-installed oc command-line tool • Sample applications for testing • All necessary permissions to create and modify SCCs

Task 1: Understanding and Creating Custom Security Context Constraints
Subtask 1.1: Examine Default SCCs
First, let's explore the existing SCCs in your OpenShift cluster to understand the security landscape.

Login to your OpenShift cluster:
oc login -u admin -p admin https://your-cluster-url:6443
List all available SCCs:
oc get scc
Examine the details of the restricted SCC (the most secure default SCC):
oc describe scc restricted
View the privileged SCC (the least restrictive SCC):
oc describe scc privileged
Key Observation: Notice the differences in capabilities, volume types, and security settings between these SCCs.

Subtask 1.2: Create a Custom SCC for Privileged Containers
Now we'll create a custom SCC that allows privileged containers with specific security controls.

Create a new project for this lab:
oc new-project scc-lab
Create a custom SCC YAML file:
cat > custom-privileged-scc.yaml << 'EOF'
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: custom-privileged-scc
  annotations:
    kubernetes.io/description: "Custom SCC that allows privileged containers with specific controls"
allowHostDirVolumePlugin: true
allowHostIPC: true
allowHostNetwork: true
allowHostPID: true
allowHostPorts: true
allowPrivilegedContainer: true
allowedCapabilities:
- '*'
allowedUnsafeSysctls:
- '*'
defaultAddCapabilities: []
fsGroup:
  type: RunAsAny
priority: 10
readOnlyRootFilesystem: false
requiredDropCapabilities: []
runAsUser:
  type: RunAsAny
seLinuxContext:
  type: RunAsAny
supplementalGroups:
  type: RunAsAny
volumes:
- '*'
users: []
groups: []
EOF
Apply the custom SCC:
oc apply -f custom-privileged-scc.yaml
Verify the SCC was created:
oc get scc custom-privileged-scc
oc describe scc custom-privileged-scc
Subtask 1.3: Create a Moderate Security SCC
Let's also create a more restrictive custom SCC for comparison.

Create a moderate security SCC:
cat > moderate-security-scc.yaml << 'EOF'
apiVersion: security.openshift.io/v1
kind: SecurityContextConstraints
metadata:
  name: moderate-security-scc
  annotations:
    kubernetes.io/description: "Moderate security SCC with limited privileges"
allowHostDirVolumePlugin: false
allowHostIPC: false
allowHostNetwork: false
allowHostPID: false
allowHostPorts: false
allowPrivilegedContainer: false
allowedCapabilities:
- SETUID
- SETGID
- NET_BIND_SERVICE
defaultAddCapabilities: []
fsGroup:
  type: MustRunAs
  ranges:
  - min: 1000
  - max: 65535
priority: 5
readOnlyRootFilesystem: false
requiredDropCapabilities:
- ALL
runAsUser:
  type: MustRunAsNonRoot
seLinuxContext:
  type: MustRunAs
supplementalGroups:
  type: MustRunAs
  ranges:
  - min: 1000
  - max: 65535
volumes:
- configMap
- downwardAPI
- emptyDir
- persistentVolumeClaim
- projected
- secret
users: []
groups: []
EOF
Apply the moderate security SCC:
oc apply -f moderate-security-scc.yaml
List all SCCs to see your custom ones:
oc get scc | grep -E "(custom-privileged|moderate-security)"
Task 2: Assigning SCCs to Specific Service Accounts
Subtask 2.1: Create Service Accounts
We'll create dedicated service accounts for different security contexts.

Create service accounts for different security levels:
# Service account for privileged operations
oc create serviceaccount privileged-sa

# Service account for moderate security operations
oc create serviceaccount moderate-sa

# Service account for restricted operations
oc create serviceaccount restricted-sa
Verify service accounts were created:
oc get serviceaccounts
Subtask 2.2: Assign SCCs to Service Accounts
Now we'll bind our custom SCCs to the appropriate service accounts.

Assign the custom privileged SCC to the privileged service account:
oc adm policy add-scc-to-user custom-privileged-scc -z privileged-sa
Assign the moderate security SCC to the moderate service account:
oc adm policy add-scc-to-user moderate-security-scc -z moderate-sa
Assign the restricted SCC to the restricted service account:
oc adm policy add-scc-to-user restricted -z restricted-sa
Verify SCC assignments:
# Check which SCCs are available to each service account
oc describe scc custom-privileged-scc | grep -A 10 "Users:"
oc describe scc moderate-security-scc | grep -A 10 "Users:"
oc describe scc restricted | grep -A 10 "Users:"
Subtask 2.3: Create Role Bindings for Service Accounts
Ensure service accounts have necessary permissions to function.

Create a role binding for basic operations:
cat > service-account-rolebinding.yaml << 'EOF'
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: scc-lab-binding
  namespace: scc-lab
subjects:
- kind: ServiceAccount
  name: privileged-sa
  namespace: scc-lab
- kind: ServiceAccount
  name: moderate-sa
  namespace: scc-lab
- kind: ServiceAccount
  name: restricted-sa
  namespace: scc-lab
roleRef:
  kind: ClusterRole
  name: edit
  apiGroup: rbac.authorization.k8s.io
EOF
Apply the role binding:
oc apply -f service-account-rolebinding.yaml
Task 3: Testing Pods with Different Security Contexts
Subtask 3.1: Test Privileged Container Deployment
Let's test our privileged SCC with a container that requires elevated privileges.

Create a privileged pod deployment:
cat > privileged-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: privileged-test-pod
  namespace: scc-lab
  labels:
    app: privileged-test
spec:
  serviceAccountName: privileged-sa
  containers:
  - name: privileged-container
    image: registry.access.redhat.com/ubi8/ubi:latest
    command: ["/bin/bash"]
    args: ["-c", "while true; do echo 'Running as privileged container'; sleep 30; done"]
    securityContext:
      privileged: true
      runAsUser: 0
      capabilities:
        add:
        - SYS_ADMIN
        - NET_ADMIN
    volumeMounts:
    - name: host-root
      mountPath: /host
      readOnly: true
  volumes:
  - name: host-root
    hostPath:
      path: /
      type: Directory
  restartPolicy: Always
EOF
Deploy the privileged pod:
oc apply -f privileged-pod.yaml
Check if the pod is running:
oc get pods privileged-test-pod
oc describe pod privileged-test-pod
Test privileged operations inside the container:
# Execute commands in the privileged container
oc exec -it privileged-test-pod -- whoami
oc exec -it privileged-test-pod -- ls -la /host
oc exec -it privileged-test-pod -- ps aux
Subtask 3.2: Test Moderate Security Container
Now let's test a container with moderate security restrictions.

Create a moderate security pod:
cat > moderate-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: moderate-test-pod
  namespace: scc-lab
  labels:
    app: moderate-test
spec:
  serviceAccountName: moderate-sa
  containers:
  - name: moderate-container
    image: registry.access.redhat.com/ubi8/ubi:latest
    command: ["/bin/bash"]
    args: ["-c", "while true; do echo 'Running as moderate security container'; sleep 30; done"]
    securityContext:
      runAsNonRoot: true
      runAsUser: 1001
      runAsGroup: 1001
      capabilities:
        add:
        - NET_BIND_SERVICE
        drop:
        - ALL
    ports:
    - containerPort: 8080
      protocol: TCP
  restartPolicy: Always
EOF
Deploy the moderate security pod:
oc apply -f moderate-pod.yaml
Verify the pod deployment:
oc get pods moderate-test-pod
oc describe pod moderate-test-pod
Test the security context:
# Check the user and capabilities
oc exec -it moderate-test-pod -- whoami
oc exec -it moderate-test-pod -- id
oc exec -it moderate-test-pod -- cat /proc/self/status | grep Cap
Subtask 3.3: Test Restricted Container
Finally, let's test the most restrictive security context.

Create a restricted pod:
cat > restricted-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: restricted-test-pod
  namespace: scc-lab
  labels:
    app: restricted-test
spec:
  serviceAccountName: restricted-sa
  containers:
  - name: restricted-container
    image: registry.access.redhat.com/ubi8/ubi:latest
    command: ["/bin/bash"]
    args: ["-c", "while true; do echo 'Running as restricted container'; sleep 30; done"]
    securityContext:
      runAsNonRoot: true
      readOnlyRootFilesystem: false
      allowPrivilegeEscalation: false
      capabilities:
        drop:
        - ALL
    resources:
      limits:
        memory: "128Mi"
        cpu: "100m"
      requests:
        memory: "64Mi"
        cpu: "50m"
  restartPolicy: Always
EOF
Deploy the restricted pod:
oc apply -f restricted-pod.yaml
Check the pod status:
oc get pods restricted-test-pod
oc describe pod restricted-test-pod
Test restricted operations:
# These commands should show limited capabilities
oc exec -it restricted-test-pod -- whoami
oc exec -it restricted-test-pod -- id
oc exec -it restricted-test-pod -- ls -la /
Subtask 3.4: Test Security Violations
Let's intentionally create a pod that violates security constraints to see how SCCs prevent unauthorized operations.

Create a pod that attempts to violate the moderate SCC:
cat > violation-test-pod.yaml << 'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: violation-test-pod
  namespace: scc-lab
spec:
  serviceAccountName: moderate-sa
  containers:
  - name: violation-container
    image: registry.access.redhat.com/ubi8/ubi:latest
    command: ["/bin/bash"]
    args: ["-c", "sleep 3600"]
    securityContext:
      privileged: true  # This should be denied by moderate-security-scc
      runAsUser: 0      # This should also be denied
    volumeMounts:
    - name: host-volume
      mountPath: /host
  volumes:
  - name: host-volume
    hostPath:
      path: /
EOF
Attempt to deploy the violating pod:
oc apply -f violation-test-pod.yaml
Check the pod status and events:
oc get pods violation-test-pod
oc describe pod violation-test-pod
oc get events --sort-by='.lastTimestamp' | tail -10
Expected Result: The pod should fail to start due to SCC violations.

Task 4: Advanced SCC Management and Troubleshooting
Subtask 4.1: Analyze SCC Selection Process
Understanding how OpenShift selects SCCs is crucial for troubleshooting.

Check which SCC was actually used by each pod:
# Check the annotations to see which SCC was selected
oc get pod privileged-test-pod -o yaml | grep -A 5 -B 5 "openshift.io/scc"
oc get pod moderate-test-pod -o yaml | grep -A 5 -B 5 "openshift.io/scc"
oc get pod restricted-test-pod -o yaml | grep -A 5 -B 5 "openshift.io/scc"
Create a script to check SCC compatibility:
cat > check-scc-compatibility.sh << 'EOF'
#!/bin/bash

echo "=== SCC Compatibility Check ==="
echo "Checking which SCCs are available to each service account..."

for sa in privileged-sa moderate-sa restricted-sa; do
    echo ""
    echo "Service Account: $sa"
    echo "Available SCCs:"
    oc policy can-i use scc --as=system:serviceaccount:scc-lab:$sa --list | grep scc
done
EOF

chmod +x check-scc-compatibility.sh
./check-scc-compatibility.sh
Subtask 4.2: Monitor and Audit SCC Usage
Create a monitoring script for SCC violations:
cat > monitor-scc-events.sh << 'EOF'
#!/bin/bash

echo "=== Monitoring SCC-related Events ==="
echo "Recent events related to security context constraints:"

oc get events --all-namespaces --field-selector reason=FailedCreate,reason=FailedMount | grep -i scc
oc get events --all-namespaces --field-selector reason=SecurityContextConstraintsAdmission

echo ""
echo "=== Current Pod Security Contexts ==="
for pod in $(oc get pods -o name); do
    echo "Pod: $pod"
    oc get $pod -o jsonpath='{.metadata.annotations.openshift\.io/scc}{"\n"}'
done
EOF

chmod +x monitor-scc-events.sh
./monitor-scc-events.sh
Check resource usage and limits:
oc describe limitrange
oc get resourcequota
oc top pods
Subtask 4.3: Cleanup and Best Practices
Clean up test resources:
# Delete test pods
oc delete pod privileged-test-pod moderate-test-pod restricted-test-pod violation-test-pod

# Keep SCCs and service accounts for reference
echo "Custom SCCs and service accounts preserved for future use"
Document SCC best practices:
cat > scc-best-practices.md << 'EOF'
# Security Context Constraints Best Practices

## 1. Principle of Least Privilege
- Always use the most restrictive SCC that allows your application to function
- Start with 'restricted' SCC and only escalate when necessary

## 2. Custom SCC Guidelines
- Create custom SCCs only when default ones don't meet requirements
- Document the business justification for each custom SCC
- Regularly review and audit custom SCCs

## 3. Service Account Management
- Use dedicated service accounts for different security contexts
- Avoid assigning SCCs to the 'default' service account
- Implement proper RBAC alongside SCC controls

## 4. Monitoring and Auditing
- Monitor SCC violations and failed pod creations
- Regularly audit which SCCs are assigned to which service accounts
- Log and review security context changes

## 5. Testing Strategy
- Test applications with restrictive SCCs first
- Validate security contexts in development environments
- Implement automated security testing in CI/CD pipelines
EOF

cat scc-best-practices.md
Troubleshooting Common Issues
Issue 1: Pod Fails to Start Due to SCC Violations
Symptoms: Pod remains in Pending or CreateContainerConfigError state

Solution:

# Check pod events
oc describe pod <pod-name>

# Check which SCC is being used
oc get pod <pod-name> -o yaml | grep scc

# Verify service account SCC assignments
oc describe scc <scc-name>
Issue 2: Service Account Cannot Use Assigned SCC
Symptoms: SCC is assigned but pod still uses default restricted SCC

Solution:

# Verify the assignment
oc adm policy who-can use scc <scc-name>

# Check for conflicting assignments
oc get scc -o yaml | grep -A 10 -B 10 <service-account-name>
Issue 3: Custom SCC Not Taking Effect
Symptoms: Custom SCC exists but isn't being selected

Solution:

# Check SCC priority
oc get scc <scc-name> -o yaml | grep priority

# Verify SCC syntax
oc describe scc <scc-name>

# Check for validation errors
oc get events | grep -i scc
Conclusion
In this comprehensive lab, you have successfully:

• Created custom Security Context Constraints that provide both privileged and moderate security levels, giving you fine-grained control over container security policies

• Assigned SCCs to specific service accounts, implementing the principle of least privilege by ensuring each application runs with only the permissions it requires

• Tested various security contexts by deploying pods with different privilege levels and observing how SCCs enforce security boundaries

• Implemented security best practices including proper service account management, SCC monitoring, and violation detection

• Gained hands-on experience with troubleshooting SCC-related issues and understanding the SCC selection process

Why This Matters: Security Context Constraints are a critical security feature in OpenShift that help prevent privilege escalation attacks, contain potential security breaches, and ensure compliance with organizational security policies. By mastering SCCs, you can:

Protect your cluster from malicious or misconfigured containers
Meet regulatory compliance requirements
Implement defense-in-depth security strategies
Maintain operational security while enabling developer productivity
The skills you've developed in this lab are essential for any OpenShift administrator responsible for maintaining secure, production-ready container platforms. These security controls form the foundation of a robust container security strategy that protects both your applications and underlying infrastructure.
