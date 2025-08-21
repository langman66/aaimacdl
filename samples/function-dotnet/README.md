# Sample .NET 8 Azure Function (HTTP → Service Bus)

This is an **isolated worker** .NET 8 function with a single HTTP POST at `/api/send` that sends the request body to the Service Bus queue.

## Build & publish

> Run from a dev machine with .NET 8 SDK and Azure Functions Core Tools installed.

```bash
cd samples/function-dotnet
func start --build  # local test

# To publish to Azure (once Function App exists):
# (Option A) Zip deploy via az (requires SCM private endpoint reachability)
# dotnet publish -c Release
# (Option B) Build artifact in CI and use Run-From-Package by uploading to the Function's Storage (recommended)
```

## Runtime config
- `SERVICEBUS_FQDN` and `QUEUE_NAME` are injected by Terraform as app settings.
- The Function uses **Managed Identity**; RBAC is granted in Terraform.
