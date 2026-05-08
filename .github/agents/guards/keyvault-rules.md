# Azure Guard — Key Vault Rules

## Naming Convention
- Key Vault pattern: `kv-<project>-<env>`
- Resource Group pattern: `rg-<project>-<env>`
- Example: `kv-webapp-dev` in `rg-webapp-dev`

## Security Rules (environment-specific)

### All Environments
- ✅ RBAC authorization MUST be enabled (always)

### Dev
- Purge protection: optional
- Public network access: Enabled is OK
- Soft delete retention: minimum 7 days

### Staging
- ✅ Purge protection MUST be enabled
- Public network access: Enabled is OK
- Soft delete retention: minimum 7 days

### Production
- ✅ Purge protection MUST be enabled
- ❌ Public network access MUST be `Disabled`
- ✅ Soft delete retention MUST be exactly 90 days

## Validation Checklist
1. KV name matches `kv-<project>-<env>` pattern
2. RG name matches `rg-<project>-<env>` pattern
3. `<project>` is lowercase, alphanumeric, max 15 chars
4. `<env>` is one of: `dev`, `staging`, `prod`
5. All required tags provided (owner, project, cost-center, environment)
6. No forbidden words
7. Security rules match the environment (see above)

## Examples

### ✅ PASS Examples
- KV: `kv-payments-dev`, RG: `rg-payments-dev`, Purge: false, Public: Enabled, Retention: 7 → PASS (dev allows all)
- KV: `kv-orders-prod`, RG: `rg-orders-prod`, Purge: true, Public: Disabled, Retention: 90 → PASS (prod compliant)

### ❌ FAIL Examples
- KV: `MyKeyVault` → FAIL (naming)
- KV: `kv-orders-prod`, Purge: false → FAIL (prod requires purge protection)
- KV: `kv-orders-prod`, Public: Enabled → FAIL (prod requires Disabled)
- KV: `kv-orders-prod`, Retention: 7 → FAIL (prod requires 90)
- KV: `kv-devil-dev` → FAIL (forbidden word)

## Expected JSON Response
```json
{
  "decision": "PASS or FAIL",
  "report": "A markdown table (see format below)",
  "kv_name": "kv name from issue body",
  "rg_name": "rg name from issue body",
  "region": "azure region",
  "environment": "dev/staging/prod",
  "owner": "owner value",
  "sku": "standard or premium",
  "purge_protection": "true or false",
  "public_network_access": "Enabled or Disabled",
  "soft_delete_retention": "number of days",
  "violations": []
}
```

## Report Format
The `report` field MUST be a **markdown table**, not JSON. Use this exact format:

### When PASS:
```
| Field | Value | Status |
|-------|-------|--------|
| KV Name | `kv-payments-dev` | ✅ Valid |
| Resource Group | `rg-payments-dev` | ✅ Valid |
| Region | `eastus` | ✅ Valid |
| Environment | `dev` | ✅ Valid |
| SKU | `standard` | ✅ Valid |
| Purge Protection | `false` | ✅ Valid (dev) |
| Public Access | `Enabled` | ✅ Valid (dev) |
| Retention | `7` | ✅ Valid (dev) |
| Owner | `vinayjain` | ✅ Valid |
```

### When FAIL:
```
| Field | Value | Status | Issue |
|-------|-------|--------|-------|
| KV Name | `MyVault` | ❌ Fail | Must match `kv-<project>-<env>` |
| Purge Protection | `false` | ❌ Fail | Required in prod |
| Public Access | `Enabled` | ❌ Fail | Must be Disabled in prod |
| Retention | `30` | ❌ Fail | Must be 90 in prod |
```

Do NOT return JSON arrays, bullet lists, or raw objects in the report field.

## IMPORTANT
- Extract values from the **issue body** fields, NOT the issue title
- The title may be manually typed and wrong — the body fields are authoritative
