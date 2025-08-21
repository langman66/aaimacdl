# OIDC / Workload Identity for GitHub Actions

1. Create an App Registration (Service Principal) in Entra ID:

```bash
az ad app create --display-name "aaimacdl-github-oidc"
az ad app show --id "aaimacdl-github-oidc" --query appId -o tsv
```

2. Add **Federated Credential**:
- Issuer: `https://token.actions.githubusercontent.com`
- Subject: `repo:<ORG>/<REPO>:ref:refs/heads/main`
- Audience: `api://AzureADTokenExchange`

3. Role assignment on subscription (Owner or Contributor + User Access Administrator):
```bash
APP_ID=<appId>
SUB_ID=be919d3c-e0c6-4f3a-87f3-826d529e6788
az role assignment create --assignee $APP_ID --role Owner --scope /subscriptions/$SUB_ID
```

4. In GitHub repo **Settings → Secrets and variables → Actions → Secrets** create:
- `AZURE_TENANT_ID` – your tenant GUID
- `AZURE_CLIENT_ID` – the `appId` from step 1
- `AZURE_SUBSCRIPTION_ID` – `be919d3c-e0c6-4f3a-87f3-826d529e6788`

