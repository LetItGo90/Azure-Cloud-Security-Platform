# Azure-Cloud-Security-Platform

An end-to-end, production-grade Azure security platform built entirely in Terraform. Implements a hub-spoke secure landing zone with Azure Firewall, zero-trust identity via OIDC and Managed Identities, PaaS private networking with Private Endpoints, data encryption with Customer Managed Keys, cloud security posture management via Cloud Custodian and native Azure Policy, IaC security scanning in CI, and automated remediation via Logic Apps.
```mermaid
flowchart LR
    subgraph CI["GitHub Actions"]
        GHA[CI/CD Pipeline\nOIDC Federation]
    end

    subgraph Hub["Hub VNet"]
        FW[Azure Firewall]
        GW[VPN Gateway]
    end

    subgraph Spoke["Spoke VNet"]
        VM[Virtual Machines]
        NSG[Network Security Groups]
    end

    subgraph PaaS["PaaS - Private Endpoints"]
        KV[Key Vault]
        SA[Storage Accounts]
        SQ[Findings Queue]
    end

    subgraph SEC["Security Tooling"]
        CC[Cloud Custodian]
        PR[Prowler]
        LA[Logic App]
    end

    GHA -->|OIDC Token| FW
    GHA --> CC & PR
    FW <-->|VNet Peering| VM
    FW -->|Inspects| NSG
    VM -.->|Private Endpoint| KV & SA
    CC -->|Findings| SQ
    SQ -->|Trigger| LA
    LA -->|Remediate| NSG
    KV -->|CMK| SA
```
