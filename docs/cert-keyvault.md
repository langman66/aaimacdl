# Self-signed TLS certificate in Key Vault (private-only)

**Run these on the JumpBox via Bastion** so Key Vault Private Endpoint is reachable.

```bash
# 1) Create KV self-signed cert policy (CN = your FQDN)
cat > policy.json <<'EOF'
{
  "keyProps": {"kty": "RSA", "keySize": 2048, "reuseKey": true},
  "secretProps": {"contentType": "application/x-pkcs12"},
  "x509Props": {"subject": "CN=api.aaimacdl.example.com","validityMonths": 12},
  "issuer": {"name": "Self"}
}
EOF

# 2) Create the certificate in KV
az keyvault certificate create \
  --vault-name <kv-name> \
  --name agw-tls-aaimacdl \
  --policy @policy.json \
  --subscription be919d3c-e0c6-4f3a-87f3-826d529e6788

# 3) App Gateway will reference the secretId of this certificate automatically via Terraform
```

