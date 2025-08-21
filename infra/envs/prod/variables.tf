variable "subscription_id" { type = string }
variable "location"        { type = string }
variable "env"             { type = string }
variable "project"         { type = string }

# Optional tenant for role assignments (can be auto-detected)
variable "tenant_id" { 
    type = string 
    default = null 
}

# Admin object id for Key Vault access (your UPN)
variable "admin_object_id" { type = string }

# GitHub repo owner/name for runner labels (informational)
variable "github_org" { type = string }
variable "github_repo" { type = string }
