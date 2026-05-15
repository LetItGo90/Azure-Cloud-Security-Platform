# Architecture

## Overview

This homelab project implements an automated cloud security and compliance pipeline on Azure. Infrastructure is provisioned via Terraform, compliance is enforced by Cloud Custodian running in GitHub Actions, and remediations are handled either directly by Custodian or asynchronously via an Azure Logic App.

---

## High-Level Architecture

```
GitHub Actions
     │
     ├── Terraform (plan / apply)
     │
     └── Cloud Custodian
               │
               ├── Direct remediation (tags)
               │
               └── Storage Queue → Logic App → ARM API
```

---

## Components

### Networking — Hub VNet
A hub VNet hosts all core infrastructure. Subnets are segmented by workload type:

| Subnet | Purpose |
|---|---|
| AzureFirewallSubnet | Azure Firewall |
| app-subnet | Application workloads |
| data-subnet | Data workloads |
| pe-subnet | Private Endpoints |

All egress traffic is routed through Azure Firewall via a UDR on each workload subnet.

---

### Firewall
Azure Firewall sits at the hub perimeter. Network and application rules restrict outbound traffic to known-good destinations. Diagnostic logs are sent to Log Analytics Workspace.

---

### Key Vault
Stores secrets and encryption keys. Access is restricted via private endpoint — no public network access. Soft delete and purge protection are enforced by Cloud Custodian policy. Diagnostic logs sent to LAW.

---

### Storage
Azure Storage Account with:
- Customer-managed encryption key (CMK) via Key Vault
- User-assigned managed identity for CMK access
- Public blob access disabled
- HTTPS-only enforced
- Private endpoint on `pe-subnet`

---

### Identity
Two managed identities:

| Identity | Purpose |
|---|---|
| github-actions-identity | Federated OIDC identity for GitHub Actions — no stored credentials |
| workload-identity | Used by Storage for CMK access |

---

### Monitoring
Log Analytics Workspace (`PerGB2018`, 30-day retention) receives diagnostic logs from:
- Azure Firewall
- Key Vault
- Logic App (WorkflowRuntime + AllMetrics)

---

### Compliance — Cloud Custodian
Policies run on a schedule via GitHub Actions. Each policy targets a specific misconfiguration:

| Policy | Resource | Remediation |
|---|---|---|
| cloud-custodian-tagging | All resources | Auto — applies `environment: dev` tag |
| storage-container-public-access | azure.storage-container | Auto — via Logic App |
| storage-https-not-enforced | azure.storage | Auto — via Logic App |
| keyvault-missing-deletion-protection | azure.keyvault | Auto — via Logic App |
| nsg-open-ssh | azure.networksecuritygroup | Detect only |
| close-rdp-access | azure.networksecuritygroup | Detect only |

---

### Remediation — Logic App
`tag-remediation-workflow` processes findings from the `custodian-findings` storage queue. It runs on a daily recurrence trigger, parses the resource ID and policy name from the queue message, and applies fixes via HTTP PATCH to the ARM API. The Logic App authenticates using a system-assigned managed identity with Tag Contributor scope on the resource group.

---

### Private Endpoints
Private endpoints land on `pe-subnet` and cover:
- Key Vault (`vault` subresource)

DNS resolution for private endpoints uses Azure Private DNS Zones linked to the hub VNet.

---

## Security Principles

- **No public endpoints** — Key Vault and Storage are accessible only via private endpoint
- **No stored credentials** — GitHub Actions authenticates via OIDC federation
- **Least privilege** — managed identities are scoped to the minimum required role
- **Encryption at rest** — Storage uses CMK via Key Vault
- **Forced egress** — all outbound traffic routes through Azure Firewall
- **Automated compliance** — misconfigurations are detected and remediated on a schedule without manual intervention

---

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       ├── terraform.yml
│       └── custodian.yml
├── infra/
│   ├── environments/
│   │   └── dev/
│   │       ├── main.tf
│   │       ├── variables.tf
│   │       └── outputs.tf
│   └── modules/
│       ├── networking/
│       ├── firewall/
│       ├── key-vault/
│       ├── storage/
│       ├── identity/
│       ├── monitoring/
│       └── remediation/
│           └── logic-apps/
├── policies/
│   ├── tagging.yml
│   ├── storage.yml
│   ├── keyvault.yml
│   └── nsg.yml
└── docs/
    ├── architecture.md
    └── runbook.md
```