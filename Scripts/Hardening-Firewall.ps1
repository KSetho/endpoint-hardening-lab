# ============================================
# CIS Windows Firewall Hardening (Fixed)
# ============================================

Write-Host "`n=== Hardening Windows Firewall ===" -ForegroundColor Cyan

$ErrorActionPreference = "Stop"

# Ensure baseline directory exists
$basePath = "C:\EndpointHardening\Baseline"

if (!(Test-Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
}

# Backup current firewall configuration
$backupFile = "$basePath\firewall_backup_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"

Write-Host "[*] Backing up firewall configuration..." -ForegroundColor Cyan
Get-NetFirewallProfile | Out-File $backupFile

# ==============================
# Profiles
# ==============================
$profiles = @("Domain", "Private", "Public")

foreach ($profile in $profiles) {

    try {
        Write-Host "`n[+] Configuring $profile profile..." -ForegroundColor Yellow

        Set-NetFirewallProfile -Profile $profile -Enabled True

        Set-NetFirewallProfile -Profile $profile `
            -DefaultInboundAction Block `
            -DefaultOutboundAction Allow

        Set-NetFirewallProfile -Profile $profile `
            -LogFileName "$env:SystemRoot\System32\LogFiles\Firewall\$($profile.ToLower())fw.log" `
            -LogMaxSizeKilobytes 16384 `
            -LogAllowed True `
            -LogBlocked True

        Write-Host "    [SUCCESS] $profile configured" -ForegroundColor Green
    }
    catch {
        Write-Host "    [FAILED] $profile configuration failed" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# ==============================
# Verification
# ==============================
Write-Host "`n[+] Verifying Firewall Configuration..." -ForegroundColor Cyan

Get-NetFirewallProfile |
Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction |
Format-Table -AutoSize

$disabled = Get-NetFirewallProfile | Where-Object { $_.Enabled -ne $true }

if ($disabled) {
    Write-Host "`n[!] Some firewall profiles are NOT enabled!" -ForegroundColor Red
}
else {
    Write-Host "`n[OK] All firewall profiles are enabled." -ForegroundColor Green
}

Write-Host "`nFirewall hardening complete!" -ForegroundColor Green