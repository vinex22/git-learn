# Azure Resource Group Provisioner

Self-service Azure Resource Group creation via GitHub Issues, with an AI-powered compliance gate.

## How It Works

```
Open Issue → AI Validates → Creates Resource Group → Closes Issue
```

1. You fill out an issue form requesting a new Resource Group
2. An AI agent (**Azure Guard**) checks your request against compliance rules
3. If it **passes** → the RG is created in Azure automatically
4. If it **fails** → you get a comment explaining what to fix

## Quick Start

### 1. Open an Issue

Go to **Issues → New Issue → "Request Azure Resource Group"** and fill out the form:

| Field | Example | Notes |
|-------|---------|-------|
| Resource Group Name | `rg-webapp-dev` | Must follow `rg-<project>-<env>` |
| Azure Region | `eastus` | Pick from dropdown |
| Environment | `dev` | `dev`, `staging`, or `prod` |
| Owner | `vinayjain` | Your name or team name |
| Project | `webapp` | Lowercase, max 15 chars |
| Cost Center | `engineering` | Pick from dropdown |
| Purpose | Free text | Describe what it's for |

### 2. Wait for AI Validation

The workflow triggers automatically. Within ~30 seconds you'll see a comment:

- **✅ PASSED** — Resource group creation proceeds
- **❌ BLOCKED** — Comment lists exactly what's wrong

### 3. Fix & Resubmit (if blocked)

Two ways to retry:
- **Edit the issue** body with corrected values (auto re-triggers)
- **Comment** `/revalidate` to manually re-trigger

## Naming Rules

| Resource | Pattern | Example |
|----------|---------|---------|
| Resource Group | `rg-<project>-<env>` | `rg-webapp-dev` |

- `<env>` must be: `dev`, `staging`, or `prod`
- `<project>` must be lowercase, alphanumeric, max 15 chars
- No uppercase letters, no generic names (`test`, `temp`)
- The word `devil` is forbidden

## Required Tags (auto-applied)

| Tag | Source |
|-----|--------|
| `environment` | From issue form |
| `owner` | From issue form |
| `project` | From issue form |
| `cost-center` | From issue form |
| `created-by` | Auto-set to `github-actions` |
| `created-date` | Auto-set to current date |
| `issue-number` | Auto-set from GitHub issue |

## Setup (for repo admins)

### Prerequisites

- An Azure subscription
- A GitHub repository
- Azure CLI and GitHub CLI installed locally

### 1. Create an Azure Service Principal

```bash
az ad sp create-for-rbac --name "github-rg-creator" \
  --role Contributor \
  --scopes /subscriptions/<YOUR_SUBSCRIPTION_ID> \
  --sdk-auth
```

Save the JSON output — you'll need it for the next step. It looks like this:

```json
{
  "clientId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "clientSecret": "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "subscriptionId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "tenantId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "activeDirectoryEndpointUrl": "https://login.microsoftonline.com",
  "resourceManagerEndpointUrl": "https://management.azure.com/",
  "sqlManagementEndpointUrl": "https://management.core.windows.net:8443/",
  "galleryEndpointUrl": "https://gallery.azure.com/",
  "managementEndpointUrl": "https://management.core.windows.net/"
}
```

> **⚠️ Keep this secret!** Never commit this JSON to your repo. Store it only as a GitHub Secret.

### 2. Add GitHub Secrets

Go to **Settings → Secrets and variables → Actions** and add:

| Secret | Value |
|--------|-------|
| `AZURE_CREDENTIALS` | The full JSON from step 1 |
| `GH_MODELS_TOKEN` | A GitHub PAT with `models` permission ([create one here](https://github.com/settings/tokens)) |

### 3. Create Required Labels

```bash
gh label create azure --color 0075ca --description "Azure resource request"
gh label create infrastructure --color d4c5f9 --description "Infrastructure provisioning"
```

### 4. That's It

The workflow, issue template, and AI rules are already in the repo. Open an issue to test.

## Repo Structure

```
.github/
├── workflows/
│   └── create-azure-rg.yml      # Main workflow (AI gate + Azure provisioning)
├── agents/
│   └── azure-guard.agent.md     # Compliance rules the AI enforces
└── ISSUE_TEMPLATE/
    └── azure-rg.yml             # Issue form template
```

## Architecture

```
┌──────────────────┐     ┌──────────────────────┐     ┌─────────────────┐
│  GitHub Issue     │────▶│  Job 1: Azure Guard   │────▶│  Job 2: Create  │
│  (user request)  │     │  (AI validation)      │     │  Resource Group  │
└──────────────────┘     └──────────────────────┘     └─────────────────┘
                                │                            │
                                ▼                            ▼
                         GitHub Models API            Azure CLI
                         (GPT-4o)                     (az group create)
```

## AI Response Format

The workflow calls the GitHub Models API (GPT-4o) and expects a JSON response. Here's what the raw AI output looks like:

**PASS example:**
```json
{
  "decision": "PASS",
  "report": "| # | Rule | Status | Details |\n|---|------|--------|---------|...",
  "rg_name": "rg-webapp-dev",
  "region": "eastus",
  "environment": "dev",
  "owner": "vinayjain",
  "violations": []
}
```

**FAIL example:**
```json
{
  "decision": "FAIL",
  "report": "| # | Rule | Status | Details |\n|---|------|--------|---------|...",
  "rg_name": "Devil-PROD-RG",
  "region": "eastus",
  "environment": "prod",
  "owner": "vinayjain",
  "violations": [
    "Name 'Devil-PROD-RG' contains forbidden word 'devil'",
    "Name does not follow pattern rg-<project>-<env>",
    "Uppercase letters are not allowed"
  ]
}
```

This JSON is wrapped inside the GitHub Models API response:
```json
{
  "choices": [
    {
      "message": {
        "content": "{\"decision\":\"PASS\", ...}"  // ← AI's JSON is here
      }
    }
  ]
}
```

The workflow extracts it with `jq -r '.choices[0].message.content'`, then parses each field into `$GITHUB_OUTPUT` for use by later steps and jobs.

## Customizing Rules

Edit `.github/agents/azure-guard.agent.md` to:
- Add/remove naming patterns
- Change required tags
- Add forbidden words
- Modify security rules
- Adjust environment-specific policies

The AI reads this file on every run — changes take effect immediately.

## Troubleshooting

| Problem | Fix |
|---------|-----|
| Workflow doesn't trigger | Make sure the issue has the `azure` label |
| AI gives false positives | Edit the issue and comment `/revalidate` |
| Azure deployment fails | Check the workflow logs (link in the error comment) |
| Re-running workflow uses old code | Don't re-run — create a new issue or comment `/revalidate` |
