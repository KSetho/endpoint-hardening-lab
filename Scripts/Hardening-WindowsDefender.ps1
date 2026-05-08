# ============================================
# Windows Defender Hardening (Clean Fixed Version)
# ============================================

Write-Host "`n=== Configuring Windows Defender ===" -ForegroundColor Cyan

$ErrorActionPreference = "SilentlyContinue"

# Ensure baseline directory exists
$basePath = "C:\EndpointHardening\Baseline"

if (!(Test-Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
}

# Backup current Defender settings
$backupFile = "$basePath\defender_backup_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"

Write-Host "[*] Backing up Defender configuration..." -ForegroundColor Cyan
Get-MpPreference | Out-File $backupFile

# Check Defender status
$status = Get-MpComputerStatus

if ($status.AntivirusEnabled -eq $false) {
    Write-Host "[WARNING] Windows Defender is not active" -ForegroundColor Red
}

# ==============================
# Apply Defender Settings
# ==============================
try {
    Write-Host "[+] Applying Defender settings..." -ForegroundColor Yellow

    Set-MpPreference -DisableRealtimeMonitoring $false
    Set-MpPreference -MAPSReporting Advanced
    Set-MpPreference -SubmitSamplesConsent SendAllSamples
    Set-MpPreference -DisableBehaviorMonitoring $false
    Set-MpPreference -DisableArchiveScanning $false
    Set-MpPreference -DisableRemovableDriveScanning $false
    Set-MpPreference -DisableScanningNetworkFiles $false
    Set-MpPreference -PUAProtection Enabled

    Write-Host "[OK] Defender settings applied successfully" -ForegroundColor Green
}
catch {
    Write-Host "[FAIL] Failed to apply Defender settings" -ForegroundColor Red
    Write-Host $_.Exception.Message -ForegroundColor Red
}

# ==============================
# Update Signatures
# ==============================
Write-Host "[+] Updating virus definitions..." -ForegroundColor Yellow
Update-MpSignature

# Optional scan
$runScan = $false

if ($runScan -eq $true) {
    Write-Host "[+] Running quick scan..." -ForegroundColor Yellow
    Start-MpScan -ScanType QuickScan
}

# ==============================
# Verification
# ==============================
Write-Host "`n[INFO] Verifying Defender Status..." -ForegroundColor Cyan

Get-MpComputerStatus |
Select-Object AntivirusEnabled, RealTimeProtectionEnabled, BehaviorMonitorEnabled, IoavProtectionEnabled, NISEnabled |
Format-List

Write-Host "`nDefender configuration complete!" -ForegroundColor Green