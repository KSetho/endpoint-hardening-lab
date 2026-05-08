# ============================================
# CIS Advanced Audit Policy Configuration
# ============================================

Write-Host "`n=== Configuring Advanced Audit Policies ===" -ForegroundColor Cyan

# Ensure baseline directory exists
$basePath = "C:\EndpointHardening\Baseline"

if (!(Test-Path $basePath)) {
    New-Item -ItemType Directory -Path $basePath -Force | Out-Null
}

# Backup current audit policy
$backupFile = "$basePath\audit_policy_backup_$(Get-Date -Format 'yyyyMMdd_HHmm').txt"

Write-Host "[*] Backing up current audit policy..." -ForegroundColor Cyan
auditpol /get /category:* > $backupFile

# Define audit configurations
$auditSettings = @(
    @{ Sub = "Credential Validation"; Success = "enable"; Failure = "enable" },
    @{ Sub = "User Account Management"; Success = "enable"; Failure = "enable" },
    @{ Sub = "Security Group Management"; Success = "enable"; Failure = "enable" },
    @{ Sub = "Logon"; Success = "enable"; Failure = "enable" },
    @{ Sub = "Logoff"; Success = "enable"; Failure = "" },
    @{ Sub = "Audit Policy Change"; Success = "enable"; Failure = "enable" },
    @{ Sub = "Authentication Policy Change"; Success = "enable"; Failure = "" },
    @{ Sub = "Sensitive Privilege Use"; Success = "enable"; Failure = "enable" },
    @{ Sub = "Security State Change"; Success = "enable"; Failure = "enable" },
    @{ Sub = "Security System Extension"; Success = "enable"; Failure = "enable" },
    @{ Sub = "System Integrity"; Success = "enable"; Failure = "enable" }
)

# Apply audit policies
foreach ($item in $auditSettings) {

    try {
        Write-Host "[+] Enabling auditing for: $($item.Sub)" -ForegroundColor Yellow

        if ($item.Failure -ne "") {
            auditpol /set /subcategory:"$($item.Sub)" /success:$($item.Success) /failure:$($item.Failure)
        }
        else {
            auditpol /set /subcategory:"$($item.Sub)" /success:$($item.Success)
        }

        Write-Host "[OK] Configured: $($item.Sub)" -ForegroundColor Green
    }
    catch {
        Write-Host "[FAIL] Could not configure: $($item.Sub)" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }
}

# ==============================
# Verification Step
# ==============================
Write-Host "`n[INFO] Verifying Audit Policy Configuration..." -ForegroundColor Cyan

$auditResult = auditpol /get /category:*

$auditResult | Select-String "Success|Failure" | Select-Object -First 20

Write-Host "`nAudit policy configuration complete!" -ForegroundColor Green
Write-Host "[INFO] Check Event Viewer -> Windows Logs -> Security" -ForegroundColor Cyan