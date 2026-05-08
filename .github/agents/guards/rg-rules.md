# Azure Guard — Resource Group Rules

## Naming Convention
- Pattern: `rg-<project>-<env>`
- Example: `rg-webapp-dev`, `rg-payments-prod`

## Validation Checklist
1. Name matches `rg-<project>-<env>` pattern exactly
2. `<project>` is lowercase, alphanumeric, max 15 chars
3. `<env>` is one of: `dev`, `staging`, `prod`
4. All required tags are provided (owner, project, cost-center, environment)
5. No forbidden words (devil, test, temp, myresource)

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
  "report": "markdown compliance table",
  "rg_name": "the rg name from the issue body (NOT the title)",
  "region": "azure region",
  "environment": "dev/staging/prod",
  "owner": "owner value",
  "violations": []
}
```

## IMPORTANT
- Extract the RG name from the **issue body** (Resource Group Name field), NOT the issue title
- The title may be manually typed and could be wrong — the body field is authoritative
