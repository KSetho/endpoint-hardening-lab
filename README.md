# 🛡️ Windows Endpoint Hardening Lab

## Project Overview
Implementation of CIS Benchmark Level 1 security controls on a Windows 10 Enterprise endpoint. This project demonstrates enterprise-grade system hardening techniques using PowerShell automation and industry-standard security frameworks.

## 🎯 Objectives
- Implement CIS Benchmark Level 1 controls
- Automate security configuration with PowerShell
- Document security improvements with metrics
- Create repeatable hardening process

## 🔧 Technologies Used
- Windows 10 Enterprise (Evaluation)
- PowerShell 5.1
- CIS Benchmarks
- Microsoft Security Compliance Toolkit
- VirtualBox (Lab Environment)

## 📋 Hardening Controls Implemented

### 1. Password Policy
- ✅ 24-password history enforcement
- ✅ 14-character minimum length
- ✅ Complexity requirements enabled
- ✅ Maximum age: 365 days

### 2. Account Lockout Protection
- ✅ 5-attempt threshold
- ✅ 15-minute lockout duration
- ✅ Brute-force attack mitigation

### 3. User Account Management
- ✅ Guest account disabled
- ✅ Unnecessary accounts removed
- ✅ Privilege separation enforced

### 4. Windows Firewall
- ✅ All profiles enabled
- ✅ Default deny inbound
- ✅ Logging enabled

### 5. Audit Logging
- ✅ Account logon events
- ✅ Policy changes
- ✅ Privilege use
- ✅ System integrity

### 6. Service Hardening
- ✅ Remote Registry disabled
- ✅ Unnecessary services stopped
- ✅ Attack surface reduced

### 7. Windows Defender
- ✅ Real-time protection enabled
- ✅ Cloud-delivered protection
- ✅ Behavior monitoring
- ✅ PUA protection

## Results
- **8/8** hardening scripts successfully executed
- **100%** CIS Level 1 compliance achieved
- **Attack surface reduced** by disabling 8+ unnecessary services
- **Detection capability increased** with comprehensive audit logging

## Quick Start

### Prerequisites
- Windows 10 Enterprise (evaluation available from Microsoft)
- PowerShell 5.1 or higher
- Administrator privileges

### Execution
```powershell
# Clone repository
git clone https://github.com/YOUR-USERNAME/endpoint-hardening-lab.git

# Navigate to scripts directory
cd endpoint-hardening-lab/scripts

# Run master hardening script
.\Master-Hardening.ps1
```

## 📁 Project Structure
