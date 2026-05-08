# ============================================
# Service Hardening Script (Fixed Encoding)
# ============================================

Write-Host "`n=== Disabling Unnecessary Services ===" -ForegroundColor Cyan

$basePath = "C:\EndpointHardening\Baseline"

if (!(Test-Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
}

$backupFile = "$basePath\services_backup_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"

Write-Host "[*] Backing up current services..." -ForegroundColor Cyan
Get-Service | Select-Object Name, Status, StartType | Out-File $backupFile

$aggressiveMode = $false

$servicesToDisable = @(
    @{ Name="RemoteRegistry"; Reason="Remote registry access risk" },
    @{ Name="WMPNetworkSvc"; Reason="Media sharing not required" },
    @{ Name="XblAuthManager"; Reason="Xbox services not required" },
    @{ Name="XblGameSave"; Reason="Xbox services not required" },
    @{ Name="XboxNetApiSvc"; Reason="Xbox networking not required" }
)

if ($aggressiveMode) {
    $servicesToDisable += @(
        @{ Name="RemoteAccess"; Reason="Routing not needed" },
        @{ Name="Browser"; Reason="Legacy service" }
    )
}

foreach ($svc in $servicesToDisable) {

    try {
        $service = Get-Service -Name $svc.Name -ErrorAction Stop

        Write-Host "[+] Processing $($svc.Name)..." -ForegroundColor Yellow
        Write-Host "    Reason: $($svc.Reason)" -ForegroundColor Gray

        if ($service.Status -eq "Running") {
            Stop-Service -Name $svc.Name -Force -ErrorAction Stop
        }

        Set-Service -Name $svc.Name -StartupType Disabled -ErrorAction Stop

        Write-Host "    [OK] Disabled successfully" -ForegroundColor Green
    }
    catch {
        Write-Host "    [FAIL] Could not process $($svc.Name)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor DarkRed
    }
}

Write-Host "`n[OK] Service hardening complete!" -ForegroundColor Green

# ==============================
# Verify Critical Services
# ==============================
Write-Host "`n[*] Verifying critical security services:" -ForegroundColor Cyan

$criticalServices = @("WinDefend", "mpssvc", "EventLog", "WdNisSvc")

foreach ($svc in $criticalServices) {

    $service = Get-Service -Name $svc -ErrorAction SilentlyContinue

    if ($service) {

        if ($service.Status -eq "Running") {
            $status = "[OK]"
            $color = "Green"
        }
        else {
            $status = "[WARN]"
            $color = "Red"
        }

        Write-Host "$status $($service.DisplayName): $($service.Status)" -ForegroundColor $color
    }
}