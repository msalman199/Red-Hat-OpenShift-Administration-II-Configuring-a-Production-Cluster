# 🚀 Introduction to OpenShift and Kubernetes 

<p align="center">
  <img src="https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white" />
  <img src="https://img.shields.io/badge/OpenShift-EE0000?style=for-the-badge&logo=redhatopenshift&logoColor=white" />
  <img src="https://img.shields.io/badge/Containers-2496ED?style=for-the-badge&logo=docker&logoColor=white" />
  <img src="https://img.shields.io/badge/Linux-FCC624?style=for-the-badge&logo=linux&logoColor=black" />
  <img src="https://img.shields.io/badge/YAML-CB171E?style=for-the-badge&logo=yaml&logoColor=white" />
</p>

---

# 📚 Overview

This lab introduces the core concepts of Kubernetes and OpenShift, providing hands-on experience with cluster access, namespaces, pods, and OpenShift-specific features.

---

# 🎯 Objectives

By the end of this lab, you will be able to:

✅ Understand fundamental Kubernetes and OpenShift concepts

✅ Access and interact with a cluster environment

✅ Use kubectl and oc CLI tools effectively

✅ Create and manage namespaces/projects

✅ Deploy and inspect pods

✅ Understand differences between OpenShift and Kubernetes

✅ Apply basic troubleshooting techniques

---

# 📋 Prerequisites

Before starting this lab, ensure you have:

🔹 Basic Linux command-line knowledge

🔹 Familiarity with containerization concepts

🔹 Understanding of YAML syntax

🔹 Basic networking knowledge

🔹 Access to a terminal

---

# 🖥️ Lab Environment Setup

Al Nafi provides pre-configured cloud machines.

### Included Tools

✅ kubectl

✅ oc (OpenShift CLI)

✅ OpenShift Cluster Access

✅ Configuration Files

✅ Nano & Vim Editors

---

# 🏗️ Task 1: Set Up an OpenShift/Kubernetes Cluster

## 🔍 Subtask 1.1: Verify Cluster Access and Tools

### Check kubectl Installation

```bash
kubectl version --client
```

### Check OpenShift CLI

```bash
oc version
```

### Verify Cluster Connectivity

```bash
kubectl cluster-info
```

Expected Result:

✅ Cluster endpoints displayed

✅ Successful connectivity confirmation

---

## 🔐 Subtask 1.2: Authenticate with OpenShift

### Login

```bash
oc login --server=https://your-cluster-url:6443 --username=developer --password=developer
```

### Verify Authentication

```bash
oc whoami
```

### Verify Current Context

```bash
kubectl config current-context
```

---

## 🌐 Subtask 1.3: Explore Cluster Information

### View Nodes

```bash
kubectl get nodes
```

### Detailed Node Information

```bash
kubectl get nodes -o wide
```

### Cluster Status

```bash
kubectl get componentstatuses
```

---

# ⚙️ Task 2: Introduction to kubectl and oc Commands

## 📖 Subtask 2.1: kubectl Basics

### View Help

```bash
kubectl --help
```

### List API Resources

```bash
kubectl api-resources
```

### Export Cluster Information

```bash
kubectl cluster-info dump > cluster-info.txt
head -20 cluster-info.txt
```

---

## 🔥 Subtask 2.2: OpenShift CLI (oc)

### View Help

```bash
oc --help
```

### OpenShift-Specific Resources

```bash
oc api-resources | grep -E "(route|build|image)"
```

### List Projects

```bash
oc projects
```

---

## 🛠️ Subtask 2.3: Common Command Patterns

### Basic Syntax

```bash
kubectl get pods
oc get pods
```

### Output Formats

```bash
kubectl get nodes -o json
kubectl get nodes -o yaml
kubectl get nodes -o wide
```

### Describe Resources

```bash
kubectl describe node <node-name>
```

---

# 📦 Task 3: Explore Namespaces and Pods

## 🗂️ Subtask 3.1: Working with Namespaces

### List Namespaces

```bash
kubectl get namespaces
```

### Detailed View

```bash
kubectl get namespaces -o wide
```

### Create Namespace

```bash
kubectl create namespace lab-demo
```

### Verify Creation

```bash
kubectl get namespace lab-demo
```

### Set Default Namespace

```bash
kubectl config set-context --current --namespace=lab-demo
```

---

## 🚀 Subtask 3.2: Creating and Managing Pods

### Create Nginx Pod

```bash
kubectl run nginx-pod --image=nginx:latest --port=80
```

### Verify Pod

```bash
kubectl get pods
```

### Describe Pod

```bash
kubectl describe pod nginx-pod
```

---

### 📄 Create Apache Pod Using YAML

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: apache-pod
  namespace: lab-demo
  labels:
    app: apache
    environment: lab
spec:
  containers:
  - name: apache-container
    image: httpd:2.4
    ports:
    - containerPort: 80
    resources:
      requests:
        memory: "64Mi"
        cpu: "250m"
      limits:
        memory: "128Mi"
        cpu: "500m"
```

### Deploy Manifest

```bash
kubectl apply -f apache-pod.yaml
```

### Verify Pods

```bash
kubectl get pods -o wide
```

---

## 📜 Subtask 3.3: Pod Logs and Inspection

### View Logs

```bash
kubectl logs nginx-pod
kubectl logs apache-pod
```

### Follow Logs

```bash
kubectl logs -f nginx-pod
```

Stop with:

```bash
Ctrl+C
```

### Execute Inside Pod

```bash
kubectl exec -it nginx-pod -- /bin/bash
```

Inside Container:

```bash
ps aux
exit
```

### Resource Usage

```bash
kubectl top pods
```

---

## 🏷️ Subtask 3.4: Labels and Selectors

### View Labels

```bash
kubectl get pods --show-labels
```

### Add Label

```bash
kubectl label pod nginx-pod version=v1.0
```

### Filter Pods

```bash
kubectl get pods -l app=apache
kubectl get pods -l environment=lab
```

### Remove Label

```bash
kubectl label pod nginx-pod version-
```

---

## 🔴 Subtask 3.5: OpenShift-Specific Features

### Create Project

```bash
oc new-project openshift-demo --display-name="OpenShift Demo Project"
```

### Switch Project

```bash
oc project openshift-demo
```

### Deploy Application

```bash
oc new-app --name=hello-world --docker-image=quay.io/redhattraining/hello-world-nginx:v1.0
```

### View Resources

```bash
oc get all
```

### Expose Route

```bash
oc expose service hello-world
```

### View Routes

```bash
oc get routes
```

---

# 🩺 Troubleshooting Common Issues

## ❌ Issue 1: Pod Stuck in Pending

### Diagnose

```bash
kubectl describe pod <pod-name>
```

### Solutions

✅ Verify node resources

✅ Check image availability

✅ Review namespace quotas

---

## 🔒 Issue 2: Authentication Errors

### Re-login

```bash
oc login --server=https://your-cluster-url:6443
```

### Verify User

```bash
oc whoami
```

### Check Permissions

```bash
oc auth can-i create pods
```

---

## ⚠️ Issue 3: Command Not Found

### Verify Installation

```bash
which kubectl
which oc
```

If missing:

📞 Contact Lab Support

---

# 🧹 Lab Cleanup

## Delete Pods

```bash
kubectl delete pod nginx-pod
kubectl delete pod apache-pod
```

## Delete Namespace

```bash
kubectl delete namespace lab-demo
```

## Delete OpenShift Project

```bash
oc delete project openshift-demo
```

## Verify Cleanup

```bash
kubectl get pods --all-namespaces | grep -E "(nginx-pod|apache-pod)"
```

---

# 🎉 Conclusion

You have successfully:

✅ Accessed an OpenShift/Kubernetes Cluster

✅ Used kubectl and oc CLI tools

✅ Managed Namespaces and Projects

✅ Created and Managed Pods

✅ Worked with Labels and Selectors

✅ Explored OpenShift Features

✅ Applied Troubleshooting Techniques

---

# 💡 Why This Matters

Kubernetes and OpenShift are industry-leading container orchestration platforms used to deploy, scale, and manage applications in modern cloud environments.

The skills learned in this lab provide the foundation for:

🔹 Deployments

🔹 Services

🔹 Networking

🔹 Persistent Storage

🔹 CI/CD Pipelines

🔹 OpenShift Administration

🔹 Cloud-Native Application Management

---

# 🚀 Next Steps

Continue learning:

* Deployments & ReplicaSets
* Services & Networking
* ConfigMaps & Secrets
* Persistent Volumes
* Ingress & Routes
* OpenShift Builds
* Image Streams
* Cluster Administration

---

## 👨‍💻 Author

**Hafiz Muhammad Salman**

Cloud DevOps Engineer | Kubernetes Enthusiast | OpenShift Learner

⭐ Keep Learning • Keep Building • Keep Automating ⭐
