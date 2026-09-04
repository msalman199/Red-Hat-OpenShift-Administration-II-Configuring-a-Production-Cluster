Lab 19: OpenShift Cluster Upgrades
Objectives
By the end of this lab, you will be able to:

• Check and verify the current OpenShift cluster version and available upgrade paths • Plan and execute cluster upgrades in a staging environment • Perform rolling upgrades using OpenShift's built-in upgrade mechanisms • Verify cluster health and functionality after upgrade completion • Understand upgrade rollback procedures and troubleshooting techniques • Implement best practices for production cluster upgrades

Prerequisites
Before starting this lab, you should have:

• Basic understanding of OpenShift cluster architecture and components • Familiarity with OpenShift CLI (oc) commands • Knowledge of Kubernetes concepts including nodes, pods, and deployments • Experience with YAML configuration files • Understanding of cluster administration concepts • Access to cluster-admin privileges in OpenShift

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift clusters already deployed. Simply click Start Lab to access your environment - no need to build your own VM or install OpenShift from scratch.

Your lab environment includes: • OpenShift 4.12 cluster with 3 master nodes and 2 worker nodes • Pre-installed OpenShift CLI (oc) tools • Configured cluster-admin access • Sample applications for testing upgrade scenarios

Task 1: Check Current OpenShift Cluster Version
Subtask 1.1: Verify Cluster Access and Current Version
First, let's establish connection to the cluster and check the current version.

Login to the OpenShift cluster:
# Login using the provided credentials
oc login https://api.cluster.example.com:6443 -u admin -p admin123

# Verify successful login
oc whoami
Check the current cluster version:
# Display current cluster version
oc get clusterversion

# Get detailed version information
oc get clusterversion version -o yaml
Check individual node versions:
# List all nodes with their versions
oc get nodes -o wide

# Get detailed node information
oc describe nodes
Subtask 1.2: Examine Cluster Operators Status
Before planning an upgrade, verify all cluster operators are healthy.

Check cluster operator status:
# List all cluster operators
oc get clusteroperators

# Check for any degraded operators
oc get clusteroperators | grep -v "True.*False.*False"
Examine specific operator details:
# Get detailed information about a specific operator
oc describe clusteroperator authentication

# Check operator logs if needed
oc logs -n openshift-authentication deployment/oauth-openshift
Subtask 1.3: Review Cluster Health Metrics
Check overall cluster health:
# View cluster status
oc get clusterversion version -o jsonpath='{.status.conditions[*].type}{"\n"}{.status.conditions[*].status}{"\n"}'

# Check for any alerts
oc get events --all-namespaces | grep -i warning
Verify etcd cluster health:
# Check etcd pods
oc get pods -n openshift-etcd | grep etcd

# Verify etcd cluster status
oc rsh -n openshift-etcd etcd-master-0 etcdctl endpoint health --cluster
Task 2: Plan and Test Cluster Upgrades in Staging
Subtask 2.1: Identify Available Upgrade Paths
Check available upgrade channels:
# View current update channel
oc get clusterversion version -o jsonpath='{.spec.channel}'

# List available updates
oc adm upgrade
Examine upgrade graph:
# Get detailed upgrade information
oc get clusterversion version -o yaml | grep -A 20 availableUpdates

# Check for conditional updates
oc adm upgrade --include-not-recommended
Subtask 2.2: Create Staging Environment Backup
Before testing upgrades, create a backup of critical configurations.

Backup cluster configurations:
# Create backup directory
mkdir -p ~/cluster-backup/$(date +%Y%m%d)

# Backup cluster version configuration
oc get clusterversion version -o yaml > ~/cluster-backup/$(date +%Y%m%d)/clusterversion.yaml

# Backup all cluster operators
oc get clusteroperators -o yaml > ~/cluster-backup/$(date +%Y%m%d)/clusteroperators.yaml
Backup application configurations:
# Backup all deployments
oc get deployments --all-namespaces -o yaml > ~/cluster-backup/$(date +%Y%m%d)/deployments.yaml

# Backup persistent volume claims
oc get pvc --all-namespaces -o yaml > ~/cluster-backup/$(date +%Y%m%d)/pvcs.yaml
Subtask 2.3: Deploy Test Applications
Create test applications to verify functionality during and after upgrades.

Create test namespace:
# Create dedicated namespace for testing
oc new-project upgrade-test

# Create a simple test application
cat << EOF | oc apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: test-app
  namespace: upgrade-test
spec:
  replicas: 3
  selector:
    matchLabels:
      app: test-app
  template:
    metadata:
      labels:
        app: test-app
    spec:
      containers:
      - name: test-app
        image: nginx:latest
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: test-app-service
  namespace: upgrade-test
spec:
  selector:
    app: test-app
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF
Verify test application deployment:
# Check deployment status
oc get deployments -n upgrade-test

# Verify pods are running
oc get pods -n upgrade-test

# Test application connectivity
oc port-forward -n upgrade-test svc/test-app-service 8080:80 &
curl http://localhost:8080
Subtask 2.4: Create Upgrade Monitoring Script
Create a script to monitor cluster health during upgrades.

Create monitoring script:
cat << 'EOF' > ~/upgrade-monitor.sh
#!/bin/bash

echo "=== OpenShift Upgrade Monitor ==="
echo "Starting monitoring at $(date)"

while true; do
    echo "--- $(date) ---"
    
    # Check cluster version
    echo "Cluster Version:"
    oc get clusterversion version --no-headers
    
    # Check cluster operators
    echo "Degraded Operators:"
    oc get clusteroperators | grep -v "True.*False.*False" | tail -n +2
    
    # Check node status
    echo "Node Status:"
    oc get nodes --no-headers | awk '{print $1, $2}'
    
    # Check test application
    echo "Test App Status:"
    oc get pods -n upgrade-test --no-headers | awk '{print $1, $3}'
    
    echo "------------------------"
    sleep 30
done
EOF

chmod +x ~/upgrade-monitor.sh
Task 3: Perform Rolling Upgrade and Verify Cluster Health
Subtask 3.1: Initiate Cluster Upgrade
Now we'll perform the actual cluster upgrade using OpenShift's rolling upgrade mechanism.

Start the upgrade monitoring:
# Start monitoring in background
~/upgrade-monitor.sh > ~/upgrade-log.txt 2>&1 &
MONITOR_PID=$!
echo "Monitor started with PID: $MONITOR_PID"
Initiate the cluster upgrade:
# Start upgrade to the next available version
oc adm upgrade --to-latest=true

# Alternative: Upgrade to specific version
# oc adm upgrade --to=4.13.1
Monitor upgrade progress:
# Watch upgrade progress
watch -n 30 'oc get clusterversion'

# Check upgrade events
oc get events -n openshift-cluster-version --sort-by='.lastTimestamp'
Subtask 3.2: Monitor Node Upgrades
During the rolling upgrade, nodes will be updated one by one.

Monitor node upgrade status:
# Watch nodes being cordoned and drained
watch -n 10 'oc get nodes'

# Check machine config pool status
oc get machineconfigpool
Verify node upgrade process:
# Check machine config daemon status
oc get pods -n openshift-machine-config-operator | grep daemon

# Monitor node annotations for upgrade status
oc get nodes -o custom-columns=NAME:.metadata.name,VERSION:.status.nodeInfo.kubeletVersion,DESIRED:.metadata.annotations.machineconfiguration\.openshift\.io/desiredConfig
Subtask 3.3: Monitor Application Availability
Ensure applications remain available during the rolling upgrade.

Test application connectivity continuously:
# Create continuous connectivity test
cat << 'EOF' > ~/app-test.sh
#!/bin/bash

SUCCESS=0
FAILURE=0

while true; do
    if oc get pods -n upgrade-test | grep -q "Running"; then
        if curl -s http://localhost:8080 > /dev/null; then
            SUCCESS=$((SUCCESS + 1))
            echo "$(date): SUCCESS - Total: $SUCCESS, Failures: $FAILURE"
        else
            FAILURE=$((FAILURE + 1))
            echo "$(date): FAILURE - Total: $SUCCESS, Failures: $FAILURE"
        fi
    else
        echo "$(date): Pods not ready"
    fi
    sleep 5
done
EOF

chmod +x ~/app-test.sh
Run application test:
# Start port forwarding
oc port-forward -n upgrade-test svc/test-app-service 8080:80 &
PF_PID=$!

# Start application testing
~/app-test.sh > ~/app-test-log.txt 2>&1 &
APP_TEST_PID=$!
Subtask 3.4: Verify Upgrade Completion
Check final upgrade status:
# Verify upgrade completion
oc get clusterversion

# Check that all operators are healthy
oc get clusteroperators
Validate cluster functionality:
# Check all nodes are ready
oc get nodes

# Verify all system pods are running
oc get pods --all-namespaces | grep -v Running | grep -v Completed
Stop monitoring processes:
# Stop monitoring scripts
kill $MONITOR_PID $APP_TEST_PID $PF_PID

# Review logs
echo "=== Upgrade Monitor Log ==="
tail -20 ~/upgrade-log.txt

echo "=== Application Test Log ==="
tail -20 ~/app-test-log.txt
Subtask 3.5: Post-Upgrade Validation
Perform comprehensive validation of the upgraded cluster.

Validate cluster version:
# Confirm new version
oc get clusterversion version -o jsonpath='{.status.desired.version}'

# Check upgrade history
oc get clusterversion version -o jsonpath='{.status.history}' | jq '.'
Test cluster functionality:
# Create a new test deployment
oc new-app --name=post-upgrade-test --image=httpd:latest -n upgrade-test

# Verify deployment works
oc get pods -n upgrade-test
oc expose svc/post-upgrade-test -n upgrade-test
Validate storage and networking:
# Test persistent volume creation
cat << EOF | oc apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: test-pvc
  namespace: upgrade-test
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
EOF

# Verify PVC is bound
oc get pvc -n upgrade-test

# Test pod-to-pod networking
oc run network-test --image=busybox --restart=Never -n upgrade-test -- sleep 3600
oc exec network-test -n upgrade-test -- nslookup test-app-service.upgrade-test.svc.cluster.local
Subtask 3.6: Upgrade Rollback Preparation
Understand how to rollback if issues occur.

Check rollback options:
# View upgrade history
oc get clusterversion version -o jsonpath='{.status.history}' | jq '.[] | {version: .version, state: .state}'

# Note: Rollbacks are generally not supported, but you can check available options
oc adm upgrade --help | grep -i rollback
Document current state:
# Create post-upgrade documentation
cat << EOF > ~/post-upgrade-report.txt
OpenShift Cluster Upgrade Report
================================
Date: $(date)
Previous Version: [Record from pre-upgrade check]
Current Version: $(oc get clusterversion version -o jsonpath='{.status.desired.version}')

Cluster Operators Status:
$(oc get clusteroperators --no-headers | awk '{print $1, $2, $3, $4}')

Node Status:
$(oc get nodes --no-headers | awk '{print $1, $2}')

Test Applications:
$(oc get pods -n upgrade-test --no-headers | awk '{print $1, $3}')

Upgrade Duration: [Calculate from logs]
Issues Encountered: [Document any issues]
EOF

echo "Upgrade report saved to ~/post-upgrade-report.txt"
Troubleshooting Common Issues
Issue 1: Upgrade Stuck or Failing
Symptoms: Upgrade progress stops or cluster operators become degraded.

Solution:

# Check cluster operator logs
oc logs -n openshift-cluster-version deployment/cluster-version-operator

# Check for specific operator issues
oc describe clusteroperator <operator-name>

# Force operator reconciliation if needed
oc patch clusterversion version --type merge -p '{"spec":{"overrides":[]}}'
Issue 2: Node Upgrade Failures
Symptoms: Nodes fail to upgrade or become NotReady.

Solution:

# Check machine config daemon logs
oc logs -n openshift-machine-config-operator daemonset/machine-config-daemon

# Check node events
oc describe node <node-name>

# Manually reboot stuck nodes if necessary
oc debug node/<node-name> -- chroot /host shutdown -r now
Issue 3: Application Connectivity Issues
Symptoms: Applications become unreachable during upgrade.

Solution:

# Check pod distribution
oc get pods -n <namespace> -o wide

# Verify service endpoints
oc get endpoints -n <namespace>

# Check network policies
oc get networkpolicy -n <namespace>
Best Practices for Production Upgrades
Pre-Upgrade Checklist
• Backup Strategy: Ensure complete etcd backups and configuration backups • Maintenance Window: Schedule upgrades during low-traffic periods • Communication: Notify stakeholders about planned maintenance • Testing: Validate upgrade process in staging environment first • Monitoring: Set up comprehensive monitoring and alerting • Rollback Plan: Prepare rollback procedures and test them

During Upgrade
• Monitor Continuously: Watch cluster operators, nodes, and applications • Document Issues: Record any problems encountered for future reference • Stay Available: Ensure upgrade team is available throughout the process • Validate Incrementally: Test functionality as each component upgrades

Post-Upgrade
• Comprehensive Testing: Validate all applications and integrations • Performance Monitoring: Check for performance regressions • Security Validation: Verify security policies and configurations • Documentation: Update runbooks and procedures with lessons learned

Conclusion
In this lab, you have successfully:

• Assessed cluster readiness by checking current versions and operator health • Planned upgrade strategy by identifying upgrade paths and creating staging environments • Executed rolling upgrades using OpenShift's built-in upgrade mechanisms • Monitored upgrade progress and validated cluster health throughout the process • Verified post-upgrade functionality through comprehensive testing procedures • Learned troubleshooting techniques for common upgrade scenarios

Why This Matters: OpenShift cluster upgrades are critical for maintaining security, stability, and access to new features. The rolling upgrade mechanism ensures minimal downtime while updating cluster components. Understanding this process is essential for production cluster management and is a key skill tested in Red Hat OpenShift Administration certifications.

Key Takeaways:

Always test upgrades in staging environments first
Monitor cluster health continuously during upgrades
Maintain comprehensive backups before major changes
Document procedures and lessons learned for future upgrades
Understand rollback limitations and plan accordingly
This hands-on experience with OpenShift cluster upgrades prepares you for real-world scenarios where maintaining cluster currency while ensuring application availability is crucial for business operations.
