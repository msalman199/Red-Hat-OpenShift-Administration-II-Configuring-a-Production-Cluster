Lab 17: Implementing CI/CD Pipelines
Objectives
By the end of this lab, you will be able to:

• Install and configure OpenShift Pipelines (Tekton) on an OpenShift cluster • Create and execute a complete CI/CD pipeline to build and deploy applications • Integrate GitHub webhooks to automate pipeline triggers • Understand the core components of Tekton pipelines including Tasks, Pipelines, and PipelineRuns • Implement automated deployment workflows using source code management integrations • Monitor and troubleshoot pipeline executions • Apply CI/CD best practices in a containerized environment

Prerequisites
Before starting this lab, you should have:

• Basic understanding of OpenShift concepts (pods, services, deployments) • Familiarity with Git version control and GitHub • Knowledge of containerization concepts and Docker • Understanding of YAML syntax • Basic command-line interface experience • Access to an OpenShift cluster with cluster-admin privileges

Lab Environment Setup
Ready-to-Use Cloud Machines: Al Nafi provides pre-configured Linux-based cloud machines with OpenShift cluster access. Simply click Start Lab to begin - no need to build your own virtual machine or install additional software.

Your lab environment includes: • OpenShift 4.12+ cluster with admin access • Pre-installed oc CLI tool • Git client and text editor • Network connectivity to GitHub and container registries

Task 1: Install OpenShift Pipelines
Subtask 1.1: Verify Cluster Access and Install Pipelines Operator
First, let's verify your OpenShift cluster access and install the OpenShift Pipelines Operator.

Login to OpenShift cluster:
oc login --server=https://your-cluster-api:6443 --username=admin
Verify cluster status:
oc get nodes
oc get clusterversion
Create the OpenShift Pipelines Operator subscription:
cat << EOF | oc apply -f -
apiVersion: operators.coreos.com/v1alpha1
kind: Subscription
metadata:
  name: openshift-pipelines-operator
  namespace: openshift-operators
spec:
  channel: latest
  name: openshift-pipelines-operator-rh
  source: redhat-operators
  sourceNamespace: openshift-marketplace
EOF
Verify the operator installation:
oc get subscription openshift-pipelines-operator -n openshift-operators
oc get csv -n openshift-operators | grep pipelines
Subtask 1.2: Verify Tekton Components Installation
Check if Tekton components are running:
oc get pods -n openshift-pipelines
Verify Tekton CRDs are installed:
oc get crd | grep tekton
Check pipeline service account:
oc get sa pipeline -n openshift-pipelines
Task 2: Create a Pipeline to Build and Deploy an Application
Subtask 2.1: Create Project and Setup Application Repository
Create a new project for our pipeline:
oc new-project pipeline-demo
Create a sample Node.js application repository structure:
mkdir -p ~/pipeline-app
cd ~/pipeline-app
Create a simple Node.js application:
cat << EOF > package.json
{
  "name": "pipeline-demo-app",
  "version": "1.0.0",
  "description": "Demo app for OpenShift Pipelines",
  "main": "server.js",
  "scripts": {
    "start": "node server.js",
    "test": "echo \"No tests specified\" && exit 0"
  },
  "dependencies": {
    "express": "^4.18.0"
  }
}
EOF
Create the application server:
cat << EOF > server.js
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from OpenShift Pipelines!',
    version: '1.0.0',
    timestamp: new Date().toISOString()
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(\`Server running on port \${port}\`);
});
EOF
Create Dockerfile:
cat << EOF > Dockerfile
FROM node:16-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install --production
COPY . .
EXPOSE 8080
USER node
CMD ["npm", "start"]
EOF
Subtask 2.2: Create Tekton Tasks
Create a Git clone task:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: git-clone
  namespace: pipeline-demo
spec:
  params:
    - name: url
      description: Repository URL to clone from
      type: string
    - name: revision
      description: Revision to checkout
      type: string
      default: main
  workspaces:
    - name: output
      description: The git repo will be cloned onto this workspace
  steps:
    - name: clone
      image: registry.redhat.io/ubi8/ubi:latest
      script: |
        #!/bin/bash
        set -e
        yum install -y git
        cd \$(workspaces.output.path)
        git clone \$(params.url) .
        git checkout \$(params.revision)
        ls -la
EOF
Create a build and push task:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: buildah-build-push
  namespace: pipeline-demo
spec:
  params:
    - name: IMAGE
      description: Reference of the image buildah will produce
      type: string
    - name: DOCKERFILE
      description: Path to the Dockerfile to build
      type: string
      default: ./Dockerfile
  workspaces:
    - name: source
      description: Workspace containing the source code
  steps:
    - name: build-and-push
      image: registry.redhat.io/rhel8/buildah:latest
      securityContext:
        privileged: true
      script: |
        #!/bin/bash
        set -e
        cd \$(workspaces.source.path)
        buildah bud --format=oci --tls-verify=false --no-cache \
          -f \$(params.DOCKERFILE) -t \$(params.IMAGE) .
        buildah push --tls-verify=false \$(params.IMAGE)
      volumeMounts:
        - name: varlibcontainers
          mountPath: /var/lib/containers
  volumes:
    - name: varlibcontainers
      emptyDir: {}
EOF
Create a deployment task:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Task
metadata:
  name: deploy-app
  namespace: pipeline-demo
spec:
  params:
    - name: IMAGE
      description: Image to deploy
      type: string
    - name: APP_NAME
      description: Application name
      type: string
  steps:
    - name: deploy
      image: registry.redhat.io/openshift4/ose-cli:latest
      script: |
        #!/bin/bash
        set -e
        
        # Create deployment if it doesn't exist
        if ! oc get deployment \$(params.APP_NAME) > /dev/null 2>&1; then
          oc create deployment \$(params.APP_NAME) --image=\$(params.IMAGE)
        else
          oc set image deployment/\$(params.APP_NAME) \$(params.APP_NAME)=\$(params.IMAGE)
        fi
        
        # Create service if it doesn't exist
        if ! oc get service \$(params.APP_NAME) > /dev/null 2>&1; then
          oc expose deployment \$(params.APP_NAME) --port=8080
        fi
        
        # Create route if it doesn't exist
        if ! oc get route \$(params.APP_NAME) > /dev/null 2>&1; then
          oc expose service \$(params.APP_NAME)
        fi
        
        # Wait for deployment to be ready
        oc rollout status deployment/\$(params.APP_NAME) --timeout=300s
        
        echo "Application deployed successfully!"
        oc get route \$(params.APP_NAME) -o jsonpath='{.spec.host}'
EOF
Subtask 2.3: Create the Pipeline
Create the main pipeline:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: Pipeline
metadata:
  name: build-deploy-pipeline
  namespace: pipeline-demo
spec:
  params:
    - name: git-url
      description: Git repository URL
      type: string
    - name: git-revision
      description: Git revision to build
      type: string
      default: main
    - name: image-name
      description: Container image name
      type: string
    - name: app-name
      description: Application name
      type: string
  workspaces:
    - name: shared-workspace
      description: Workspace shared between tasks
  tasks:
    - name: fetch-source
      taskRef:
        name: git-clone
      params:
        - name: url
          value: \$(params.git-url)
        - name: revision
          value: \$(params.git-revision)
      workspaces:
        - name: output
          workspace: shared-workspace
    
    - name: build-image
      taskRef:
        name: buildah-build-push
      runAfter:
        - fetch-source
      params:
        - name: IMAGE
          value: \$(params.image-name)
      workspaces:
        - name: source
          workspace: shared-workspace
    
    - name: deploy-application
      taskRef:
        name: deploy-app
      runAfter:
        - build-image
      params:
        - name: IMAGE
          value: \$(params.image-name)
        - name: APP_NAME
          value: \$(params.app-name)
EOF
Subtask 2.4: Setup Container Registry Access
Create a secret for the internal registry:
oc create secret docker-registry pipeline-registry-secret \
  --docker-server=image-registry.openshift-image-registry.svc:5000 \
  --docker-username=pipeline \
  --docker-password=$(oc whoami -t) \
  --docker-email=pipeline@example.com
Link the secret to the pipeline service account:
oc secrets link pipeline pipeline-registry-secret
Grant necessary permissions:
oc policy add-role-to-user edit system:serviceaccount:pipeline-demo:pipeline
Subtask 2.5: Create and Run a PipelineRun
Create a PipelineRun to execute our pipeline:
cat << EOF | oc apply -f -
apiVersion: tekton.dev/v1beta1
kind: PipelineRun
metadata:
  name: build-deploy-run-$(date +%s)
  namespace: pipeline-demo
spec:
  pipelineRef:
    name: build-deploy-pipeline
  params:
    - name: git-url
      value: https://github.com/your-username/pipeline-demo-app.git
    - name: git-revision
      value: main
    - name: image-name
      value: image-registry.openshift-image-registry.svc:5000/pipeline-demo/demo-app:latest
    - name: app-name
      value: demo-app
  workspaces:
    - name: shared-workspace
      volumeClaimTemplate:
        spec:
          accessModes:
            - ReadWriteOnce
          resources:
            requests:
              storage: 1Gi
EOF
Monitor the pipeline execution:
oc get pipelinerun -w
View pipeline logs:
# Get the latest pipelinerun name
PIPELINE_RUN=$(oc get pipelinerun --sort-by=.metadata.creationTimestamp -o name | tail -1)
oc logs $PIPELINE_RUN -f
Task 3: Automate Deployments Using GitHub Actions Integration
Subtask 3.1: Setup GitHub Repository
Create a GitHub repository (if you haven't already):

Go to GitHub.com and create a new repository named pipeline-demo-app
Initialize it with the files we created earlier
Push your application code to GitHub:

cd ~/pipeline-app
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/pipeline-demo-app.git
git push -u origin main
Subtask 3.2: Create GitHub Webhook Integration
Create an EventListener for GitHub webhooks:
cat << EOF | oc apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: EventListener
metadata:
  name: github-listener
  namespace: pipeline-demo
spec:
  serviceAccountName: pipeline
  triggers:
    - name: github-push-trigger
      interceptors:
        - ref:
            name: github
          params:
            - name: eventTypes
              value: ["push"]
      bindings:
        - ref: github-push-binding
      template:
        ref: github-push-template
EOF
Create TriggerBinding for GitHub events:
cat << EOF | oc apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerBinding
metadata:
  name: github-push-binding
  namespace: pipeline-demo
spec:
  params:
    - name: git-repo-url
      value: \$(body.repository.clone_url)
    - name: git-revision
      value: \$(body.head_commit.id)
    - name: git-repo-name
      value: \$(body.repository.name)
EOF
Create TriggerTemplate:
cat << EOF | oc apply -f -
apiVersion: triggers.tekton.dev/v1beta1
kind: TriggerTemplate
metadata:
  name: github-push-template
  namespace: pipeline-demo
spec:
  params:
    - name: git-repo-url
      description: The git repository URL
    - name: git-revision
      description: The git revision
    - name: git-repo-name
      description: The git repository name
  resourcetemplates:
    - apiVersion: tekton.dev/v1beta1
      kind: PipelineRun
      metadata:
        generateName: github-triggered-run-
        namespace: pipeline-demo
      spec:
        pipelineRef:
          name: build-deploy-pipeline
        params:
          - name: git-url
            value: \$(tt.params.git-repo-url)
          - name: git-revision
            value: \$(tt.params.git-revision)
          - name: image-name
            value: image-registry.openshift-image-registry.svc:5000/pipeline-demo/\$(tt.params.git-repo-name):latest
          - name: app-name
            value: \$(tt.params.git-repo-name)
        workspaces:
          - name: shared-workspace
            volumeClaimTemplate:
              spec:
                accessModes:
                  - ReadWriteOnce
                resources:
                  requests:
                    storage: 1Gi
EOF
Subtask 3.3: Expose EventListener and Configure GitHub Webhook
Create a route for the EventListener:
oc expose service el-github-listener
Get the webhook URL:
WEBHOOK_URL=$(oc get route el-github-listener -o jsonpath='{.spec.host}')
echo "Webhook URL: http://$WEBHOOK_URL"
Configure GitHub webhook:
Go to your GitHub repository settings
Click on "Webhooks" in the left sidebar
Click "Add webhook"
Set Payload URL to: http://YOUR_WEBHOOK_URL
Set Content type to: application/json
Select "Just the push event"
Click "Add webhook"
Subtask 3.4: Test Automated Pipeline Trigger
Make a change to your application:
cd ~/pipeline-app
cat << EOF > server.js
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

app.get('/', (req, res) => {
  res.json({
    message: 'Hello from OpenShift Pipelines - Updated!',
    version: '2.0.0',
    timestamp: new Date().toISOString(),
    environment: 'production'
  });
});

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'healthy' });
});

app.listen(port, () => {
  console.log(\`Server running on port \${port}\`);
});
EOF
Commit and push the changes:
git add .
git commit -m "Update application message and version"
git push origin main
Monitor the automatically triggered pipeline:
oc get pipelinerun -w
Subtask 3.5: Create a GitHub Actions Workflow (Alternative Approach)
Create GitHub Actions workflow directory:
mkdir -p .github/workflows
Create GitHub Actions workflow file:
cat << EOF > .github/workflows/openshift-deploy.yml
name: Build and Deploy to OpenShift

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

env:
  OPENSHIFT_SERVER: \${{ secrets.OPENSHIFT_SERVER }}
  OPENSHIFT_TOKEN: \${{ secrets.OPENSHIFT_TOKEN }}
  OPENSHIFT_NAMESPACE: pipeline-demo
  APP_NAME: demo-app

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - name: Checkout code
      uses: actions/checkout@v3
    
    - name: Install OpenShift CLI
      uses: redhat-actions/openshift-tools-installer@v1
      with:
        oc: 4.12
    
    - name: Log in to OpenShift
      run: |
        oc login --token=\$OPENSHIFT_TOKEN --server=\$OPENSHIFT_SERVER --insecure-skip-tls-verify
        oc project \$OPENSHIFT_NAMESPACE
    
    - name: Create PipelineRun
      run: |
        cat << EOL | oc apply -f -
        apiVersion: tekton.dev/v1beta1
        kind: PipelineRun
        metadata:
          generateName: github-actions-run-
          namespace: \$OPENSHIFT_NAMESPACE
        spec:
          pipelineRef:
            name: build-deploy-pipeline
          params:
            - name: git-url
              value: \${{ github.server_url }}/\${{ github.repository }}.git
            - name: git-revision
              value: \${{ github.sha }}
            - name: image-name
              value: image-registry.openshift-image-registry.svc:5000/\$OPENSHIFT_NAMESPACE/\$APP_NAME:latest
            - name: app-name
              value: \$APP_NAME
          workspaces:
            - name: shared-workspace
              volumeClaimTemplate:
                spec:
                  accessModes:
                    - ReadWriteOnce
                  resources:
                    requests:
                      storage: 1Gi
        EOL
    
    - name: Wait for pipeline completion
      run: |
        PIPELINE_RUN=\$(oc get pipelinerun --sort-by=.metadata.creationTimestamp -o name | tail -1)
        oc wait \$PIPELINE_RUN --for=condition=Succeeded --timeout=600s
        
    - name: Get application URL
      run: |
        APP_URL=\$(oc get route \$APP_NAME -o jsonpath='{.spec.host}')
        echo "Application deployed at: http://\$APP_URL"
EOF
Commit the GitHub Actions workflow:
git add .github/
git commit -m "Add GitHub Actions workflow"
git push origin main
Monitoring and Troubleshooting
Viewing Pipeline Status
Check pipeline runs:
oc get pipelinerun
oc describe pipelinerun PIPELINE_RUN_NAME
View task logs:
oc logs -f pipelinerun/PIPELINE_RUN_NAME
Check pipeline resources:
oc get pipeline,task,pipelinerun,taskrun
Common Troubleshooting Steps
Check service account permissions:
oc get rolebinding | grep pipeline
oc describe sa pipeline
Verify registry access:
oc get secret pipeline-registry-secret -o yaml
Check EventListener status:
oc get eventlistener
oc describe eventlistener github-listener
View webhook delivery logs:
oc logs deployment/el-github-listener-deployment
Testing Your Deployed Application
Get the application route:
oc get route demo-app -o jsonpath='{.spec.host}'
Test the application:
APP_URL=$(oc get route demo-app -o jsonpath='{.spec.host}')
curl http://$APP_URL
curl http://$APP_URL/health
Verify the deployment:
oc get deployment demo-app
oc get pods -l app=demo-app
Conclusion
Congratulations! You have successfully completed Lab 17: Implementing CI/CD Pipelines. In this comprehensive lab, you have accomplished the following:

Key Achievements:

• Installed OpenShift Pipelines: You successfully deployed the Tekton-based OpenShift Pipelines operator and verified all components are running correctly.

• Created a Complete CI/CD Pipeline: You built a full pipeline with three main stages - source code fetching, container image building, and application deployment - demonstrating the core concepts of continuous integration and deployment.

• Implemented Automated Triggers: You configured both webhook-based triggers and GitHub Actions integration, enabling automatic pipeline execution whenever code changes are pushed to your repository.

• Mastered Tekton Components: You worked hands-on with Tasks, Pipelines, PipelineRuns, EventListeners, TriggerBindings, and TriggerTemplates, gaining practical experience with the building blocks of Tekton pipelines.

Why This Matters:

CI/CD pipelines are fundamental to modern software development and DevOps practices. The skills you've developed in this lab are directly applicable to:

• Enterprise Development: Most organizations use CI/CD pipelines to ensure consistent, reliable, and fast software delivery • Cloud-Native Applications: Container-based applications require automated build and deployment processes • DevOps Culture: Understanding pipeline automation is essential for bridging development and operations teams • Quality Assurance: Automated pipelines help maintain code quality and reduce human error in deployments

Real-World Applications:

The pipeline you created follows industry best practices and can be extended for production use by adding: • Automated testing stages • Security scanning • Multi-environment deployments • Rollback capabilities • Monitoring and alerting

This lab has provided you with practical, hands-on experience that directly supports Red Hat OpenShift Administration certification objectives and prepares you for implementing CI/CD solutions in production environments.
