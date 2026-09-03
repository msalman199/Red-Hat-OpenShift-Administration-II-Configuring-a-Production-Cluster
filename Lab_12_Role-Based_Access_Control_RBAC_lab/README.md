<div align="center">

# 🔐 Kubernetes RBAC Fundamentals: Roles, Bindings & Namespace-Based Access Control

![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?style=for-the-badge&logo=kubernetes&logoColor=white)
![RBAC](https://img.shields.io/badge/RBAC-Access%20Control-blue?style=for-the-badge&logo=letsencrypt&logoColor=white)
![OpenShift](https://img.shields.io/badge/Red%20Hat-OpenShift%20Admin%20II-EE0000?style=for-the-badge&logo=redhat&logoColor=white)
![Security](https://img.shields.io/badge/Security-Least%20Privilege-critical?style=for-the-badge&logo=shieldsdotio&logoColor=white)

</div>

---

## 📖 Table of Contents

- [🎯 Key Accomplishments](#-key-accomplishments)
- [📚 Key Concepts](#-key-concepts)
- [💡 Why This Matters](#-why-this-matters)
- [🎓 Certification Relevance](#-certification-relevance)

---

## 🎯 Key Accomplishments

By completing this lab, you have:

- ✅ **Mastered RBAC Fundamentals** — Learned the core components of Kubernetes RBAC, including `Roles`, `ClusterRoles`, `RoleBindings`, and `ClusterRoleBindings`, and how they work together to control access to cluster resources.
- ✅ **Implemented Namespace-Based Security** — Created distinct roles for development and production environments, demonstrating how to restrict access to specific namespaces and enforce environment-based security policies.
- ✅ **Configured User Access Controls** — Created service accounts representing different user types (developers, production viewers, testers) and bound them to appropriate roles with varying permission levels.
- ✅ **Tested Permission Boundaries** — Verified through hands-on testing that RBAC policies behave as expected, confirming authorized actions succeed while unauthorized actions are denied.
- ✅ **Applied Security Best Practices** — Implemented the principle of least privilege by granting only the minimum necessary permissions, and practiced auditing and troubleshooting RBAC configurations.

---

## 📚 Key Concepts

| Concept | Description |
|---|---|
| **Role** | Namespace-scoped set of permissions defining what actions can be performed on which resources |
| **ClusterRole** | Cluster-wide set of permissions, applicable across all namespaces or to non-namespaced resources |
| **RoleBinding** | Grants the permissions defined in a Role (or ClusterRole) to a user, group, or service account within a specific namespace |
| **ClusterRoleBinding** | Grants the permissions defined in a ClusterRole to a subject across the entire cluster |
| **Service Account** | Identity used by processes and users to authenticate and interact with the Kubernetes API |
| **Principle of Least Privilege** | Security practice of granting only the minimum permissions required to perform a task |
| **Namespace-Based Security** | Isolating access controls per namespace to separate environments (e.g., development vs. production) |
| **Permission Auditing** | Reviewing and verifying that RBAC configurations grant only intended, authorized access |

---

## 💡 Why This Matters

RBAC is a critical security feature in Kubernetes that enables organizations to implement fine-grained access control, ensuring that users and applications can only access the resources they need. This is essential for:

- 🛡️ **Security Compliance** — Meeting regulatory requirements and security standards
- 🏢 **Multi-Tenancy** — Safely sharing cluster resources among different teams and applications
- ⚙️ **Operational Safety** — Preventing accidental or malicious changes to critical resources
- 📋 **Audit and Governance** — Maintaining clear records of who can access what resources

---

## 🎓 Certification Relevance

The skills developed in this lab are directly applicable to real-world Kubernetes administration and are essential for the **Red Hat OpenShift Administration II** certification. You now have the knowledge to design, implement, and maintain secure access control policies in production Kubernetes environments.

---

<div align="center">

![Al Nafi](https://img.shields.io/badge/Al%20Nafi-Cybersecurity%20Training-orange?style=for-the-badge)

</div>
