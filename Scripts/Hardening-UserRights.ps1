# ============================================
# CIS User Rights Assignment (Fixed Version)
# ============================================

Write-Host "`n=== Configuring User Rights Assignment ===" -ForegroundColor Cyan

# Ensure directory exists
$basePath = "C:\EndpointHardening\Baseline"

if (!(Test-Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
}

$currentPolicy = "$basePath\current_security.inf"
$backupPolicy  = "$basePath\backup_security_$(Get-Date -Format 'yyyyMMdd_HHmm').inf"

# Backup current policy
Write-Host "[*] Backing up current security policy..." -ForegroundColor Cyan
secedit /export /cfg $backupPolicy

# Export working copy
Write-Host "[+] Exporting current security policy..." -ForegroundColor Yellow
secedit /export /cfg $currentPolicy

# Load content
$content = Get-Content $currentPolicy

# ==============================
# FIXED FUNCTION (IMPORTANT)
# ==============================
function Set-Privilege {
    param (
        [string]$Name,
        [string]$Value
    )

    $pattern = "^$([regex]::Escape($Name))\s*="

    if ($content -match $pattern) {
        $content = $content -replace $pattern + ".*", "$Name = $Value"
    }
    else {
        $content += "$Name = $Value"
    }
}

# Apply CIS restrictions
Write-Host "[+] Applying user rights restrictions..." -ForegroundColor Yellow

Set-Privilege "SeNetworkLogonRight" "*S-1-5-32-544,*S-1-5-32-545,*S-1-5-32-551"
Set-Privilege "SeRemoteInteractiveLogonRight" "*S-1-5-32-544"
Set-Privilege "SeDenyNetworkLogonRight" "*S-1-5-32-546"
Set-Privilege "SeDenyRemoteInteractiveLogonRight" "*S-1-5-32-546"
Set-Privilege "SeDebugPrivilege" "*S-1-5-32-544"

# Save updated policy
$updatedPolicy = "$basePath\updated_security.inf"
$content | Set-Content $updatedPolicy -Encoding Unicode

# Apply policy
try {
    Write-Host "[+] Applying updated security policy..." -ForegroundColor Yellow

    secedit /configure /db c:\windows\security\local.sdb /cfg $updatedPolicy /areas USER_RIGHTS

    Write-Host "[OK] User rights applied successfully" -ForegroundColor Green
}
catch {
    Write-Host "[FAIL] Failed to apply user rights assignment" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# ==============================
# Verification
# ==============================
Write-Host "`n[INFO] Verifying applied privileges..." -ForegroundColor Cyan

secedit /export /cfg "$basePath\verify_security.inf"

Write-Host "[INFO] Verification file saved for review" -ForegroundColor Green