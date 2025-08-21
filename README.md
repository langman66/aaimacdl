# aaimacdl – Secure Hub (single VNet) on Azure with App Gateway + Firewall + Private Endpoints

This repository provisions a **simple but strict** hub-and-spoke-on-one-VNet design in **West US 2** using Terraform and GitHub Actions (OIDC), with:

- Application Gateway WAF v2 (ONLY public HTTP/S entry)
- Azure Bastion (ONLY ops ingress) + JumpBox VM
- Azure Firewall Premium + UDRs + DNS proxy
- Azure Functions (Elastic Premium, Linux .NET) with **Private Endpoint** (no public)
- Azure Service Bus Premium (private only) + queue `q-aaimacdl-hub`
- Azure Key Vault (private only) storing TLS cert for App Gateway
- Azure Private DNS zones in hub
- Log Analytics workspace
- Remote Terraform state in a **private Storage Account** via Private Endpoint

> **Subscription**: `be919d3c-e0c6-4f3a-87f3-826d529e6788`

## Quick start (operator flow)

> One-time bootstrap creates remote state (private Storage Account) with `-backend=false`, then we re-init to use that backend.

1. **Prereqs**
   - Azure CLI >= 2.60
   - Terraform CLI >= 1.12.x
   - You have Contributor/Owner on the subscription
   - You know your Tenant ID (set `ARM_TENANT_ID`)

2. **Create OIDC App Registration** (if not already)
   - See `docs/oidc-setup.md`

3. **Bootstrap remote state (from your machine)**

```bash
cd infra/envs/prod
# Create RG + Storage + Container (backend.tf intentionally points to them but we create with -backend=false first)
terraform init -backend=false
terraform apply -auto-approve -target=module.remote_state

# Now re-init to migrate state into the backend
terraform init 
# (Answer 'yes' to copy local state to remote)
```

4. **Plan / Apply infra**
```bash
terraform plan -out tfplan
terraform apply tfplan
```

5. **Set up self-hosted GitHub runner (inside VNet)**
   - After infra deploys, follow `docs/self-hosted-runner.md` to register the runner VM to your repo and enable the GitHub Actions workflow.

6. **Upload Key Vault self-signed cert for App Gateway**
   - From JumpBox (via Bastion), follow `docs/cert-keyvault.md`.

7. **Deploy sample Function code**
   - Build the sample in `samples/function-dotnet/` and deploy per `samples/function-dotnet/README.md`.
```

