# Azure Guard — Shared Rules

These rules apply to ALL Azure resource requests.

## Naming Rules
- `<env>` must be one of: `dev`, `staging`, `prod`
- `<project>` must be lowercase, alphanumeric, max 15 chars
- No uppercase letters anywhere
- No generic names like `test`, `temp`, `myresource`, `resource1`
- The word `devil` is **strictly forbidden** in any part of the resource name

## Required Tags

ALL resources MUST have these tags:

| Tag | Required | Example Value |
|-----|----------|---------------|
| `environment` | Yes | `dev` / `staging` / `prod` |
| `owner` | Yes | `team-platform` / `vinay` |
| `project` | Yes | `webapp` / `data-pipeline` |
| `cost-center` | Yes | `engineering` / `marketing` |
| `created-by` | Auto-set | `github-actions` (set by workflow) |
| `created-date` | Auto-set | Set by workflow |

### Tag Rules
- Tag values must be lowercase
- No empty tag values
- `environment` must match the `<env>` in the resource name
- Do NOT flag `created-by` or `created-date` — they are auto-set by the workflow

## General Security
- ❌ NEVER hardcode passwords, connection strings, keys, or tokens
- ✅ Use RBAC over access keys
- ✅ Prefer Managed Identity over service principals

## Environment-Specific Rules

### Dev
- Relaxed networking (public access OK)
- Lower SKUs acceptable

### Staging
- Must mirror production networking
- Private endpoints required

### Production
- Private endpoints REQUIRED for all PaaS
- Diagnostic settings MUST be enabled

## Constraints
- **Fail-fast** — report ALL violations at once
- **No false positives** — only flag REAL violations
- A valid lowercase string like `vinayjain` or `ankur` is a valid owner/project name
- Do NOT invent violations — if the value meets the rules, return PASS
