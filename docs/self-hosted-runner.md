# Self-Hosted GitHub Runner inside the VNet

We provision a dedicated Linux VM (`aaimacdl-ghrunner-01`) in the **Management** subnet. It has no public IP and is reachable via **Bastion**. The VM has outbound via **Azure Firewall**.

## 1) Generate a short-lived runner registration token
In GitHub:
- Go to **Settings → Actions → Runners → New self-hosted runner → Linux → x64**.
- Copy the **Registration token** (valid ~1 hour).

## 2) Connect to the VM via Bastion
Azure Portal → Bastion → **SSH** to `aaimacdl-ghrunner-01` as `azureuser`.

## 3) Install and register the runner (script provided on VM)
Run:
```bash
sudo su -
cd /opt/aaimacdl/runner
./install_runner.sh
```
Paste your **registration token** when prompted.

The script will:
- Download the latest actions runner
- Register the runner with labels: `self-hosted`, `aaimacdl`, `prod`
- Install as a systemd service and start it

> To rotate the runner token, re-run the script.

## 4) Validate in GitHub
- Repo → **Settings → Actions → Runners** should show one online runner with labels `aaimacdl`.

## 5) Security notes
- The VM has **no inbound public**. Access only via Bastion.
- Outbound is restricted through Azure Firewall. Ensure application rules allow:
  - `token.actions.githubusercontent.com`
  - `github.com`, `api.github.com`, `objects.githubusercontent.com`, `ghcr.io`, `packages.actions.githubusercontent.com`
  - Azure endpoints: `login.microsoftonline.com`, `management.azure.com`, `graph.microsoft.com`, `*.blob.core.windows.net`

