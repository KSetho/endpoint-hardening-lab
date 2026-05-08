# ============================================
# CIS Account Lockout Policy (Fixed Safe Version)
# ============================================

Write-Host "`n=== Configuring Account Lockout Policy ===" -ForegroundColor Cyan

# Ensure baseline directory exists
$basePath = "C:\EndpointHardening\Baseline"

if (!(Test-Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
}

# Backup current settings
$backupFile = "$basePath\lockout_backup_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"

Write-Host "[*] Backing up current account policy..." -ForegroundColor Cyan
net accounts > $backupFile

# ==============================
# Apply Policy
# ==============================
try {
    Write-Host "[+] Setting lockout threshold to 5 attempts..." -ForegroundColor Yellow
    net accounts /lockoutthreshold:5

    Write-Host "[+] Setting lockout duration to 15 minutes..." -ForegroundColor Yellow
    net accounts /lockoutduration:15

    Write-Host "[+] Setting lockout reset window to 15 minutes..." -ForegroundColor Yellow
    net accounts /lockoutwindow:15

    Write-Host "[OK] Account lockout policy applied successfully" -ForegroundColor Green
}
catch {
    Write-Host "[FAIL] Account lockout policy configuration failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# ==============================
# Display Result
# ==============================
Write-Host "`n[INFO] Current Account Lockout Settings:" -ForegroundColor Cyan
net accounts

Write-Host "`nAccount lockout policy configured!" -ForegroundColor Green