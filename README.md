# Azure-Cloud-Security-Platform

An end-to-end, production-grade Azure security platform built entirely in Terraform. Implements a hub-spoke secure landing zone with Azure Firewall, zero-trust identity via OIDC and Managed Identities, PaaS private networking with Private Endpoints, data encryption with Customer Managed Keys, cloud security posture management via Cloud Custodian and native Azure Policy, IaC security scanning in CI, and automated remediation via Logic Apps.

```mermaid
graph TB
    subgraph GitHub["GitHub Actions (OIDC)"]
        GHA[CI/CD Pipeline]
    end

    subgraph Hub["Hub VNet"]
        FW[Azure Firewall]
        GW[VPN Gateway]
    end

    subgraph Spoke["Spoke VNet"]
        VM[Virtual Machines]
        NSG[Network Security Groups]
    end

    subgraph PaaS["PaaS Services - Private Endpoints"]
        KV[Key Vault\nCMK Encryption]
        SA[Storage Accounts]
        SQ[Storage Queue\nCustodian Findings]
    end

    subgraph Security["Security Tooling"]
        CC[Cloud Custodian]
        PR[Prowler]
        LA[Logic App\nRemediation]
    end

    GHA -->|OIDC Token| Hub
    GHA --> CC
    GHA --> PR
    Hub <-->|VNet Peering| Spoke
    FW -->|Inspects Traffic| Spoke
    Spoke --> NSG
    Spoke -.->|Private Endpoint| PaaS
    CC -->|Findings| SQ
    SQ -->|Trigger| LA
    LA -->|Auto Remediate| Spoke
    KV -->|Manages Keys| SA
```​
