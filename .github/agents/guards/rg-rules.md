# Azure Guard — Resource Group Rules

## Naming Convention
- Pattern: `rg-<project>-<env>`
- Example: `rg-webapp-dev`, `rg-payments-prod`

## Validation Checklist
1. Name matches `rg-<project>-<env>` pattern exactly
2. All shared rules pass (naming, tags, forbidden words — see shared-rules.md)

## Examples

### ✅ PASS Examples
- Name: `rg-payments-dev`, Project: `payments`, Env: `dev`, Owner: `vinayjain` → PASS
- Name: `rg-analytics-prod`, Project: `analytics`, Env: `production`, Owner: `team-data` → PASS
- Name: `rg-ankur-dev`, Project: `ankur`, Env: `dev`, Owner: `ankur` → PASS (ankur is 5 chars, valid)

### ❌ FAIL Examples
- Name: `MyResourceGroup` → FAIL (not rg-<project>-<env> pattern)
- Name: `rg-devil-prod` → FAIL (forbidden word)
- Name: `rg-WEBAPP-dev` → FAIL (uppercase)
- Name: `ankurrg` → FAIL (doesn't match rg-<project>-<env>)

## Expected JSON Response
```json
{
  "decision": "PASS or FAIL",
  "report": "A markdown table (see format below)",
  "rg_name": "the rg name from the issue body (NOT the title)",
  "region": "azure region",
  "environment": "dev/staging/prod",
  "owner": "owner value",
  "violations": []
}
```

## Report Format
The `report` field MUST be a **markdown table**, not JSON. Use this exact format:

### When PASS:
```
| Field | Value | Status |
|-------|-------|--------|
| RG Name | `rg-payments-dev` | ✅ Valid |
| Region | `eastus` | ✅ Valid |
| Environment | `dev` | ✅ Valid |
| Owner | `vinayjain` | ✅ Valid |
| Project | `payments` | ✅ Valid |
| Cost Center | `engineering` | ✅ Valid |
```

### When FAIL:
```
| Field | Value | Status | Issue |
|-------|-------|--------|-------|
| RG Name | `MyResourceGroup` | ❌ Fail | Must match `rg-<project>-<env>` |
| Region | `eastus` | ✅ Valid | — |
| Environment | `dev` | ✅ Valid | — |
```

Do NOT return JSON arrays, bullet lists, or raw objects in the report field.

## IMPORTANT
- Extract the RG name from the **issue body** (Resource Group Name field), NOT the issue title
- The title may be manually typed and could be wrong — the body field is authoritative
