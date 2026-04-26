# HRW Azure Infrastructure Demo

Production-style Azure infrastructure built to demonstrate cloud engineering
competency for the Azure Engineer role at Human Rights Watch.

## What this project covers

| JD Requirement | What is built |
|---|---|
| #2 + #9 — Azure Pipelines + GitHub | 3-stage CI/CD pipeline with manual approval gate |
| #5 — Infrastructure as Code | Terraform modules for all Azure resources |
| #7 — Networking | VNet, Subnet, NSG with least-privilege rules |
| #11 — Identity Access Management | Entra ID SSO + Graph API stale account report |
| #12 — Application Monitoring | Log Analytics Workspace + Azure Monitor |
| #13 — Backup Review | Recovery Services Vault with soft-delete |
| #14 — MS Graph API + PowerShell | Automated identity governance script |

## Resources provisioned

- Resource Group
- Azure Key Vault (with purge protection + prevent_destroy)
- Virtual Network, Subnet, NSG
- Log Analytics Workspace
- Recovery Services Vault

## CI/CD Pipeline

Three stages with a human approval gate before anything deploys:
Secrets are stored in GitHub Secrets — never in YAML or code.
State is stored in Azure Blob Storage with state locking.

## Identity Governance Script

`scripts/Get-EntraReport.ps1` authenticates to Microsoft Graph and
produces a CSV report of Entra ID accounts inactive for 90+ days —
flagging accounts for deprovisioning, MFA review, or licence reclamation.

## Stack

Terraform · Azure Resource Manager · GitHub Actions · PowerShell · MS Graph API · Entra ID

---
## Status
![CI/CD](https://github.com/krir/hrw-azure-demo/actions/workflows/terraform.yml/badge.svg)

*Built by Kennedy K. Korir — April 2026*