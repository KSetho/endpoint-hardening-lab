# ============================================
# CIS User Account Hardening (Clean Fixed Version)
# ============================================

Write-Host "`n=== Hardening User Accounts ===" -ForegroundColor Cyan

# Ensure baseline directory exists
$basePath = "C:\EndpointHardening\Baseline"

if (!(Test-Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
}

# Backup current users
$backupFile = "$basePath\users_backup_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"

Write-Host "[*] Backing up current user accounts..." -ForegroundColor Cyan
Get-LocalUser | Out-File $backupFile

# ==============================
# Disable Guest Account
# ==============================
Write-Host "[+] Disabling Guest account..." -ForegroundColor Yellow

try {
    Disable-LocalUser -Name "Guest" -ErrorAction Stop
    Write-Host "[OK] Guest account disabled" -ForegroundColor Green
}
catch {
    Write-Host "[INFO] Guest account already disabled or unavailable" -ForegroundColor DarkYellow
}

# ==============================
# Identify Non-Standard Accounts
# ==============================
Write-Host "`n[*] Checking for non-standard local accounts..." -ForegroundColor Yellow

$defaultAccounts = @(
    "Administrator",
    "Guest",
    "DefaultAccount",
    "WDAGUtilityAccount"
)

$users = Get-LocalUser

$customUsers = $users | Where-Object {
    $_.Name -notin $defaultAccounts -and $_.Enabled -eq $true
}

if ($customUsers) {
    Write-Host "[WARNING] Additional enabled accounts found:" -ForegroundColor Red
    $customUsers | Format-Table Name, Enabled, LastLogon -AutoSize
}
else {
    Write-Host "[OK] No unexpected enabled accounts found" -ForegroundColor Green
}

# ==============================
# Rename Administrator (Optional)
# ==============================
$renameAdmin = $false

if ($renameAdmin -eq $true) {

    $newName = "SecAdmin_$((Get-Random -Minimum 100 -Maximum 999))"

    Write-Host "[+] Renaming Administrator to $newName..." -ForegroundColor Yellow

    try {
        Rename-LocalUser -Name "Administrator" -NewName $newName -ErrorAction Stop
        Write-Host "[OK] Administrator renamed successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "[FAIL] Could not rename Administrator" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}
else {
    Write-Host "`n[INFO] Administrator renaming skipped (safe mode)" -ForegroundColor Yellow
}

# ==============================
# Final Output
# ==============================
Write-Host "`n[INFO] Current local accounts:" -ForegroundColor Cyan
Get-LocalUser | Format-Table Name, Enabled, LastLogon -AutoSize

Write-Host "`nUser account hardening complete!" -ForegroundColor Green