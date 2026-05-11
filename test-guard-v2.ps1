$ErrorActionPreference = "Continue"
Set-Location "c:\Users\vinayjain\git-practice"

# 40 tests: 20 per workflow (TF / CLI), mix of PASS and FAIL
$tests = @(
    # --- VALID (PASS expected) — 20 cases ---
    # TF workflow (azure-tf label)
    @("azure-tf", "rg-webapp-dev",       "eastus",        "dev",     "alice",     "webapp",        "engineering", "PASS"),    # 1
    @("azure-tf", "rg-api-staging",      "westus2",       "staging", "bob",       "api",           "finance",     "PASS"),    # 2
    @("azure-tf", "rg-data-prod",        "centralus",     "prod",    "charlie",   "data",          "research",    "PASS"),    # 3
    @("azure-tf", "rg-ml-dev",           "westeurope",    "dev",     "deepak",    "ml",            "marketing",   "PASS"),    # 4
    @("azure-tf", "rg-infra-prod",       "uksouth",       "prod",    "emma",      "infra",         "operations",  "PASS"),    # 5
    @("azure-tf", "rg-a-dev",            "eastus",        "dev",     "zoe",       "a",             "engineering", "PASS"),    # 6
    @("azure-tf", "rg-platform1-staging","canadacentral", "staging", "kumar",     "platform1",     "finance",     "PASS"),    # 7
    @("azure-tf", "rg-longproject-dev",  "australiaeast", "dev",     "sarah",     "longproject",   "marketing",   "PASS"),    # 8  previously miscounted
    @("azure-tf", "rg-queue-prod",       "japaneast",     "prod",    "irene",     "queue",         "research",    "PASS"),    # 9
    @("azure-tf", "rg-app2-staging",     "brazilsouth",   "staging", "vinexjain", "app2",          "operations",  "PASS"),    # 10 previously rejected owner
    # CLI workflow (azure label)
    @("azure",    "rg-cache-dev",        "eastus",        "dev",     "frank",     "cache",         "engineering", "PASS"),    # 11
    @("azure",    "rg-logs-staging",     "northeurope",   "staging", "grace",     "logs",          "finance",     "PASS"),    # 12
    @("azure",    "rg-core-prod",        "southeastasia", "prod",    "hassan",    "core",          "research",    "PASS"),    # 13
    @("azure",    "rg-net-dev",          "eastus",        "dev",     "vincenzo",  "net",           "marketing",   "PASS"),    # 14
    @("azure",    "rg-db-prod",          "westus2",       "prod",    "maria",     "db",            "operations",  "PASS"),    # 15
    @("azure",    "rg-auth-staging",     "centralus",     "staging", "tommy",     "auth",          "engineering", "PASS"),    # 16
    @("azure",    "rg-pay-dev",          "uksouth",       "dev",     "ankur",     "pay",           "finance",     "PASS"),    # 17
    @("azure",    "rg-edge-prod",        "japaneast",     "prod",    "priya",     "edge",          "research",    "PASS"),    # 18
    @("azure",    "rg-sync-dev",         "australiaeast", "dev",     "lucas",     "sync",          "marketing",   "PASS"),    # 19
    @("azure",    "rg-msg-staging",      "brazilsouth",   "staging", "nina",      "msg",           "operations",  "PASS"),    # 20

    # --- INVALID (FAIL expected) — 20 cases ---
    # TF workflow
    @("azure-tf", "MyResourceGroup",        "eastus",        "dev",     "alice",     "webapp",              "engineering", "FAIL"),  # 21 no rg- prefix
    @("azure-tf", "rg-WEBAPP-dev",          "eastus",        "dev",     "alice",     "webapp",              "engineering", "FAIL"),  # 22 uppercase
    @("azure-tf", "rg-devil-dev",           "eastus",        "dev",     "alice",     "devil",               "engineering", "FAIL"),  # 23 forbidden word
    @("azure-tf", "rg-webapp-test",         "eastus",        "test",    "alice",     "webapp",              "engineering", "FAIL"),  # 24 bad env
    @("azure-tf", "",                       "eastus",        "dev",     "alice",     "webapp",              "engineering", "FAIL"),  # 25 empty name
    @("azure-tf", "rg-webapp-dev",          "",              "dev",     "alice",     "webapp",              "engineering", "FAIL"),  # 26 empty region
    @("azure-tf", "rg-webapp-dev",          "eastus",        "",        "alice",     "webapp",              "engineering", "FAIL"),  # 27 empty env
    @("azure-tf", "rg-webapp-dev",          "eastus",        "dev",     "",          "webapp",              "engineering", "FAIL"),  # 28 empty owner
    @("azure-tf", "rg-webapp-dev",          "eastus",        "dev",     "alice",     "webapp",              "",            "FAIL"),  # 29 empty cost center
    @("azure-tf", "rg-abcdefghijklmnop-dev","eastus",        "dev",     "alice",     "abcdefghijklmnop",   "engineering", "FAIL"),  # 30 project >15 chars
    # CLI workflow
    @("azure",    "rg_webapp_dev",          "eastus",        "dev",     "alice",     "webapp",              "engineering", "FAIL"),  # 31 underscores
    @("azure",    "RG-WEBAPP-DEV",          "eastus",        "dev",     "alice",     "webapp",              "engineering", "FAIL"),  # 32 all caps
    @("azure",    "rg-webapp-development",  "eastus",        "dev",     "alice",     "webapp",              "engineering", "FAIL"),  # 33 long env suffix
    @("azure",    "rg-webapp",              "eastus",        "dev",     "alice",     "webapp",              "engineering", "FAIL"),  # 34 missing env suffix
    @("azure",    "rg-temp-dev",            "eastus",        "dev",     "alice",     "temp",                "engineering", "FAIL"),  # 35 generic name
    @("azure",    "rg-myresource-dev",      "eastus",        "dev",     "alice",     "myresource",          "engineering", "FAIL"),  # 36 generic name
    @("azure",    "ankurrg",                "eastus",        "dev",     "ankur",     "ankur",               "engineering", "FAIL"),  # 37 completely wrong
    @("azure",    "rg-web.app-dev",         "eastus",        "dev",     "alice",     "webapp",              "engineering", "FAIL"),  # 38 dot in name
    @("azure",    "",                       "eastus",        "dev",     "alice",     "webapp",              "engineering", "FAIL"),  # 39 empty RG (previously passed!)
    @("azure",    "rg-webapp-dev",          "fakeregion",    "dev",     "alice",     "webapp",              "engineering", "FAIL")   # 40 fake region
)

$results = @()
Write-Host "=== CREATING $($tests.Count) TEST ISSUES ===" -ForegroundColor Cyan

for ($i = 0; $i -lt $tests.Count; $i++) {
    $t = $tests[$i]
    $label = $t[0]; $rg = $t[1]; $region = $t[2]; $env_val = $t[3]
    $owner = $t[4]; $project = $t[5]; $cc = $t[6]; $expected = $t[7]
    $num = $i + 1

    $prefix = if ($label -eq "azure-tf") { "[TF-RG Request]:" } else { "[RG Request]:" }
    $title = if ([string]::IsNullOrEmpty($rg)) { "$prefix (empty-name-$num)" } else { "$prefix $rg" }

    if ($label -eq "azure-tf") {
        $body = "### Resource Group Name`n`n$rg`n`n### Azure Region`n`n$region`n`n### Environment`n`n$env_val`n`n### Owner`n`n$owner`n`n### Project`n`n$project`n`n### Cost Center`n`n$cc`n`n### Purpose`n`nStress test $num"
    } else {
        $body = "### Resource Group Name`n`n$rg`n`n### Azure Region`n`n$region`n`n### Environment`n`n$env_val`n`n### Owner`n`n$owner`n`n### Project`n`n$project`n`n### Cost Center`n`n$cc"
    }

    $url = gh issue create --title $title --label "infrastructure,$label" --body $body 2>&1
    $issueNum = if ($url -match '/issues/(\d+)') { $Matches[1] } else { "?" }

    $results += [PSCustomObject]@{ TestNum=$num; IssueNum=$issueNum; Label=$label; RGName=$rg; Expected=$expected; Actual=""; Match="" }
    Write-Host "  [$num/40] #$issueNum ($label) $(if($expected -eq 'PASS'){'VALID'}else{'INVALID'}) — $rg" -ForegroundColor Gray

    if ($num % 12 -eq 0) { Write-Host "  --- Batch pause (15s) ---" -ForegroundColor Yellow; Start-Sleep -Seconds 15 }
    else { Start-Sleep -Seconds 2 }
}

Write-Host "`n=== ALL 40 ISSUES CREATED ===" -ForegroundColor Green
Write-Host "Waiting 4.5 minutes for workflows..." -ForegroundColor Yellow
Start-Sleep -Seconds 270

Write-Host "`n=== COLLECTING RESULTS ===" -ForegroundColor Cyan
for ($i = 0; $i -lt $results.Count; $i++) {
    $n = $results[$i].IssueNum
    if ($n -eq "?") { $results[$i].Actual = "ERR"; $results[$i].Match = "ERR"; continue }
    $comment = gh issue view $n --json comments --jq '.comments[0].body' 2>$null
    if ($comment -match 'PASSED') { $results[$i].Actual = "PASS" }
    elseif ($comment -match 'BLOCKED') { $results[$i].Actual = "FAIL" }
    else { $results[$i].Actual = "NONE" }
    $results[$i].Match = if ($results[$i].Actual -eq $results[$i].Expected) { "OK" } else { "MISMATCH" }
    Start-Sleep -Milliseconds 400
}

# Print results
Write-Host "`n=== TEST RESULTS ===" -ForegroundColor Cyan
Write-Host ("{0,-5} {1,-8} {2,-10} {3,-30} {4,-8} {5,-8} {6,-8}" -f "#", "Issue", "Workflow", "RG Name", "Expect", "Actual", "Result")
Write-Host ("-" * 85)

$ok = 0; $bad = 0; $err = 0
foreach ($r in $results) {
    $wf = if ($r.Label -eq "azure-tf") { "TF" } else { "CLI" }
    $c = if ($r.Match -eq "OK") { "Green" } elseif ($r.Match -eq "MISMATCH") { "Red" } else { "Yellow" }
    $name = if ([string]::IsNullOrEmpty($r.RGName)) { "(empty)" } else { $r.RGName }
    Write-Host ("{0,-5} {1,-8} {2,-10} {3,-30} {4,-8} {5,-8} {6,-8}" -f $r.TestNum, "#$($r.IssueNum)", $wf, $name, $r.Expected, $r.Actual, $r.Match) -ForegroundColor $c
    if ($r.Match -eq "OK") { $ok++ } elseif ($r.Match -eq "MISMATCH") { $bad++ } else { $err++ }
}

Write-Host "`n=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "  Correct:    $ok / $($results.Count)" -ForegroundColor Green
Write-Host "  Mismatches: $bad / $($results.Count)" -ForegroundColor $(if ($bad -gt 0) {"Red"} else {"Green"})
Write-Host "  Errors:     $err / $($results.Count)" -ForegroundColor $(if ($err -gt 0) {"Yellow"} else {"Green"})

# Print any mismatches
if ($bad -gt 0) {
    Write-Host "`n=== MISMATCHES ===" -ForegroundColor Red
    $results | Where-Object { $_.Match -eq "MISMATCH" } | ForEach-Object {
        Write-Host "  #$($_.IssueNum) ($($_.Label)) — Expected $($_.Expected), Got $($_.Actual) — $($_.RGName)"
        $c = gh issue view $_.IssueNum --json comments --jq '.comments[0].body' 2>$null
        Write-Host "  >>> $($c.Substring(0, [Math]::Min(200, $c.Length)))..." -ForegroundColor DarkRed
    }
}

# Cleanup
Write-Host "`n=== CLEANUP ===" -ForegroundColor Yellow
foreach ($wf in @("create-azure-rg-terraform.yml", "create-azure-rg.yml")) {
    $runs = gh run list --workflow=$wf --status=waiting --json databaseId --jq '.[].databaseId' 2>&1
    foreach ($rid in ($runs -split "`n" | Where-Object { $_ -match '^\d+$' })) { gh run cancel $rid 2>$null; Write-Host "  Cancelled run $rid" -ForegroundColor Gray }
    $runs2 = gh run list --workflow=$wf --status=in_progress --json databaseId --jq '.[].databaseId' 2>&1
    foreach ($rid in ($runs2 -split "`n" | Where-Object { $_ -match '^\d+$' })) { gh run cancel $rid 2>$null; Write-Host "  Cancelled run $rid" -ForegroundColor Gray }
}

foreach ($r in $results) {
    if ($r.IssueNum -ne "?") { gh issue close $r.IssueNum -c "Auto-closed: stress test" 2>$null }
}
Write-Host "  All issues closed" -ForegroundColor Gray

# Check Azure for any created RGs
Write-Host "`n=== CHECKING AZURE FOR LEAKED RGs ===" -ForegroundColor Yellow
$allRgs = az group list --query "[?starts_with(name, 'rg-') && name != 'rg-tfstate'].name" -o tsv 2>$null
$testNames = $results | Where-Object { $_.Actual -eq "PASS" -and $_.RGName -ne "" } | ForEach-Object { $_.RGName }
foreach ($rg in $testNames) {
    if ($allRgs -contains $rg) {
        Write-Host "  FOUND: $rg — deleting" -ForegroundColor Red
        az group delete --name $rg --yes --no-wait 2>$null
    }
}
Write-Host "  Azure check complete" -ForegroundColor Green

Write-Host "`n=== STRESS TEST COMPLETE ===" -ForegroundColor Cyan
