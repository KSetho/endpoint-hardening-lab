# ============================================
# CIS Password Policy Hardening (Fixed Safe Version)
# ============================================

Write-Host "`n=== Hardening Password Policies ===" -ForegroundColor Cyan

# Ensure base directory exists
$basePath = "C:\EndpointHardening\Baseline"

if (!(Test-Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
}

$configFile = "$basePath\secpol.cfg"
$backupFile  = "$basePath\secpol_backup_$(Get-Date -Format 'yyyyMMdd_HHmm').cfg"

# Backup current policy
Write-Host "[*] Backing up current security policy..." -ForegroundColor Cyan
secedit /export /cfg $backupFile

# CIS Policies
Write-Host "[+] Setting password history to 24..." -ForegroundColor Yellow
net accounts /uniquepw:24

Write-Host "[+] Setting max password age to 365..." -ForegroundColor Yellow
net accounts /maxpwage:365

Write-Host "[+] Setting min password age to 1..." -ForegroundColor Yellow
net accounts /minpwage:1

Write-Host "[+] Setting minimum length to 14..." -ForegroundColor Yellow
net accounts /minpwlen:14

# Enable password complexity
Write-Host "[+] Enabling password complexity..." -ForegroundColor Yellow

secedit /export /cfg $configFile

$content = Get-Content $configFile

if ($content -match "PasswordComplexity") {
    $content = $content -replace "PasswordComplexity\s*=\s*\d", "PasswordComplexity = 1"
}
else {
    $content += "`nPasswordComplexity = 1"
}

$content | Set-Content $configFile

try {
    secedit /configure /db c:\windows\security\local.sdb /cfg $configFile /areas SECURITYPOLICY

    Write-Host "[OK] Password complexity applied successfully" -ForegroundColor Green
}
catch {
    Write-Host "[FAIL] Password complexity configuration failed" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# Cleanup
Remove-Item $configFile -ErrorAction SilentlyContinue

# Display result
Write-Host "`n[INFO] Current Password Policy:" -ForegroundColor Green
net accounts

Write-Host "`nPassword policy hardening complete!" -ForegroundColor Green