# ============================================
# System Information Gathering Script (Enhanced)
# Purpose: Collect baseline system configuration
# ============================================

Write-Host "=== Gathering System Information ===" -ForegroundColor Cyan

# Error handling preference
$ErrorActionPreference = "SilentlyContinue"

# Create timestamp
$timestamp = Get-Date -Format "yyyy-MM-dd_HHmm"

# Ensure directory exists
$folderPath = "C:\EndpointHardening\Baseline"
if (!(Test-Path $folderPath)) {
    New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
}

# Report path
$reportPath = "$folderPath\SystemInfo_$timestamp.txt"

# Header
"SYSTEM INFORMATION REPORT" | Out-File $reportPath
"Generated: $(Get-Date)" | Out-File $reportPath -Append
"="*60 | Out-File $reportPath -Append

# ==============================
# Operating System Information
# ==============================
"`n--- Operating System ---" | Out-File $reportPath -Append
Get-CimInstance Win32_OperatingSystem |
Select-Object Caption, Version, BuildNumber |
Format-Table -AutoSize |
Out-String |
Out-File $reportPath -Append

# ==============================
# Firewall Status
# ==============================
"`n--- Firewall Status ---" | Out-File $reportPath -Append
Get-NetFirewallProfile |
Select-Object Name, Enabled |
Format-Table -AutoSize |
Out-String |
Out-File $reportPath -Append

# ==============================
# Local User Accounts
# ==============================
"`n--- Local User Accounts ---" | Out-File $reportPath -Append
Get-LocalUser |
Select-Object Name, Enabled, PasswordRequired, PasswordLastSet |
Format-Table -AutoSize |
Out-String |
Out-File $reportPath -Append

# ==============================
# Installed Applications (64-bit + 32-bit)
# ==============================
"`n--- Installed Applications (Sample) ---" | Out-File $reportPath -Append

$apps = @()

$apps += Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*
$apps += Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*

$apps |
Where-Object { $_.DisplayName -ne $null } |
Select-Object DisplayName, DisplayVersion, Publisher |
Sort-Object DisplayName |
Select-Object -First 30 |
Format-Table -AutoSize |
Out-String |
Out-File $reportPath -Append

# ==============================
# Running Services
# ==============================
"`n--- Running Services (Sample) ---" | Out-File $reportPath -Append
Get-Service |
Where-Object { $_.Status -eq "Running" } |
Select-Object Name, DisplayName, StartType |
Sort-Object Name |
Select-Object -First 30 |
Format-Table -AutoSize |
Out-String |
Out-File $reportPath -Append

# ==============================
# Windows Defender Status
# ==============================
"`n--- Windows Defender Status ---" | Out-File $reportPath -Append
Get-MpComputerStatus |
Select-Object AMServiceEnabled, AntivirusEnabled, RealTimeProtectionEnabled |
Format-Table -AutoSize |
Out-String |
Out-File $reportPath -Append

# ==============================
# Open TCP Ports
# ==============================
"`n--- Open TCP Ports (Sample) ---" | Out-File $reportPath -Append
Get-NetTCPConnection |
Select-Object LocalAddress, LocalPort, State |
Sort-Object LocalPort |
Select-Object -First 30 |
Format-Table -AutoSize |
Out-String |
Out-File $reportPath -Append

# ==============================
# Running Processes (Top 20 by CPU)
# ==============================
"`n--- Running Processes (Top 20 by CPU) ---" | Out-File $reportPath -Append
Get-Process |
Sort-Object CPU -Descending |
Select-Object Name, Id, CPU |
Select-Object -First 20 |
Format-Table -AutoSize |
Out-String |
Out-File $reportPath -Append

# Completion message
Write-Host "Report saved to: $reportPath" -ForegroundColor Green