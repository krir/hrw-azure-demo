# ================================================================
# HRW Entra ID — Stale Account & Access Governance Report
# ----------------------------------------------------------------
# JD #8  — PowerShell scripting
# JD #11 — Identity Access Management / Entra ID (Azure AD)
# JD #14 — MS Graph API
# ================================================================
# HOW TO RUN — in VS Code terminal:
#
#   .\scripts\Get-EntraReport.ps1 `
#     -TenantId     "your-tenant-id" `
#     -ClientId     "your-app-client-id" `
#     -ClientSecret "your-client-secret"
#
# ================================================================

param(
    [Parameter(Mandatory=$true)][string]$TenantId,
    [Parameter(Mandatory=$true)][string]$ClientId,
    [Parameter(Mandatory=$true)][string]$ClientSecret,
    [int]$InactiveDays = 90
)

Write-Host "`n=== HRW Entra ID Access Governance Report ===" -ForegroundColor Cyan
Write-Host "Checking for accounts inactive for $InactiveDays+ days`n" -ForegroundColor Cyan

# ── STEP 1: Authenticate to Microsoft Graph ───────────────────
# Client credentials flow — how service principals authenticate
# No user interaction needed — this is how pipelines and scripts auth
Write-Host "Authenticating to Microsoft Graph..." -ForegroundColor Yellow

$tokenBody = @{
    grant_type    = "client_credentials"
    scope         = "https://graph.microsoft.com/.default"
    client_id     = $ClientId
    client_secret = $ClientSecret
}

$tokenResponse = Invoke-RestMethod `
    -Uri    "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" `
    -Method POST `
    -Body   $tokenBody

$headers = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-Type"  = "application/json"
}

Write-Host "Authentication successful.`n" -ForegroundColor Green

# ── STEP 2: Pull all users from Entra ID via Graph API ────────
Write-Host "Fetching users from Entra ID..." -ForegroundColor Yellow

$usersUrl = "https://graph.microsoft.com/v1.0/users" +
    "?`$select=displayName,userPrincipalName,accountEnabled," +
    "signInActivity,assignedLicenses,userType" +
    "&`$top=999"

$response  = Invoke-RestMethod -Uri $usersUrl -Headers $headers
$allUsers  = $response.value

Write-Host "Total users found: $($allUsers.Count)`n" -ForegroundColor Green

# ── STEP 3: Find stale accounts ───────────────────────────────
$cutoff = (Get-Date).AddDays(-$InactiveDays)

$staleAccounts = $allUsers | Where-Object {
    $lastSignIn = $_.signInActivity.lastSignInDateTime
    if (-not $lastSignIn) { return $true }
    ([DateTime]$lastSignIn) -lt $cutoff
}

Write-Host "Stale accounts found: $($staleAccounts.Count)" -ForegroundColor Yellow

# ── STEP 4: Build the report ──────────────────────────────────
$report = $staleAccounts | ForEach-Object {
    $lastSignIn = $_.signInActivity.lastSignInDateTime
    $daysSince  = if ($lastSignIn) {
        [int]((Get-Date) - [DateTime]$lastSignIn).TotalDays
    } else { "Never signed in" }

    [PSCustomObject]@{
        DisplayName    = $_.displayName
        UPN            = $_.userPrincipalName
        AccountEnabled = $_.accountEnabled
        UserType       = $_.userType
        LastSignIn     = if ($lastSignIn) { $lastSignIn } else { "Never" }
        DaysSinceLogin = $daysSince
        HasLicense     = ($_.assignedLicenses.Count -gt 0)
        Action         = if (-not $_.accountEnabled)  { "Already disabled" }
                         elseif (-not $lastSignIn)    { "Review — never logged in" }
                         else                          { "Recommend deprovisioning" }
    }
}

# ── STEP 5: Display results in terminal ───────────────────────
Write-Host "`nResults:" -ForegroundColor Cyan
$report | Format-Table DisplayName, UPN, LastSignIn, DaysSinceLogin, Action -AutoSize

# ── STEP 6: Export to CSV in docs folder ──────────────────────
New-Item -ItemType Directory -Force -Path ".\docs" | Out-Null
$csvPath = ".\docs\stale_accounts_report.csv"
$report | Export-Csv -Path $csvPath -NoTypeInformation

Write-Host "Report saved to: $csvPath" -ForegroundColor Green
Write-Host "Review this list for deprovisioning, MFA enforcement, or licence reclamation.`n" -ForegroundColor Cyan