# Advanced Windows Event Monitoring: A Comprehensive Implementation Guide

## Overview

This repository provides a complete implementation guide for advanced Windows Event Monitoring based on a comprehensive analysis of Windows Event IDs. The solution includes automated scripts to configure audit policies, enable operational logs, and implement real-time monitoring across multiple categories of security events.

## Background

Modern enterprise security requires comprehensive logging and monitoring of Windows systems. This project emerged from the need to implement a standardized, automated approach to configure Windows Event Auditing based on Microsoft's security guidelines and real-world threat detection requirements.

### Key Challenges Addressed:
- **Manual Configuration Complexity**: Configuring audit policies across multiple systems
- **Event Noise**: Filtering relevant security events from system noise  
- **Coverage Gaps**: Ensuring all critical security events are captured
- **Scalability**: Deploying consistent configurations across enterprise environments

## Event Categories Covered

Our implementation covers **10 major categories** with **200+ Event IDs**:

| Category | Event IDs | Critical Events | Description |
|----------|-----------|-----------------|-------------|
| **Account Activity** | 25+ | 4625, 4740, 4782 | Login failures, lockouts, password hash access |
| **Event Log Management** | 3 | 1102, 104 | Log clearing (highly suspicious) |
| **Network Activity** | 15+ | 4649, 4778, 4779 | RDP sessions, replay attacks, network connections |
| **Process Monitoring** | 20+ | 4688, 4689, 8004 | Process creation/termination, AppLocker blocks |
| **System Integrity** | 10+ | 5038, 6410 | Code integrity violations, security requirements |
| **Scheduled Tasks** | 8+ | 4698, 4699 | Task creation/deletion/modification |
| **Services** | 5+ | 4697, 7031 | Service installation, unexpected termination |
| **Sysmon** | 30+ | 1, 3, 8, 10 | Advanced process/network/registry monitoring |
| **Windows Defender** | 25+ | 1006, 1121, 1123 | Malware detection, ASR blocks |
| **PowerShell** | 5+ | 4104 | Script block logging |

## Implementation Scripts

The repository includes two main PowerShell scripts (attached in the repository):

### 1. Policy Application Script (`apply_audit_policies.ps1`)
Automatically configures all required audit policies and registry settings:
- ✅ Advanced Audit Policy Configuration via `auditpol` commands
- ✅ Registry Modifications for Enhanced Logging
- ✅ Operational Log Enablement (16 different log channels)
- ✅ Command Line Process Auditing
- ✅ PowerShell Script Block Logging
- ✅ Log Size Optimization (Security: 1GB, System/Application: 512MB)
- ✅ Group Policy Updates with `gpupdate /force`
- ✅ Sysmon Detection and Service Management
- ✅ Comprehensive Configuration Validation
- ✅ Automatic Restart Option

### 2. Simple Event Monitor (`simple_monitor.ps1`)
Provides real-time monitoring and validation of audit configuration:
- 🔍 Audit Policy Status Verification
- 🔍 Critical Event Detection (10 key Event IDs)
- 🔍 Windows Defender Event Monitoring
- 🔍 Sysmon Activity Tracking
- 🔍 Event Generation Testing
- 🔍 Continuous Monitoring Mode
- 🔍 Color-coded Alert Levels (CRITICAL/HIGH/MEDIUM)
- 🔍 Historical Event Analysis (configurable timeframe)

## Event ID Reference

### Critical Security Events (Immediate Alert)

| Event ID | Channel | Description | Threat Level |
|----------|---------|-------------|--------------|
| **1102** | Security | Security log cleared | 🔴 CRITICAL |
| **4782** | Security | Password hash accessed | 🔴 CRITICAL |
| **1006** | Defender | Malware detected | 🔴 CRITICAL |
| **4649** | Security | Kerberos replay attack | 🔴 CRITICAL |
| **5038** | Security | Invalid image hash | 🔴 CRITICAL |
| **6410** | Security | Security requirements not met | 🔴 CRITICAL |

### High Priority Events (Investigation Required)

| Event ID | Channel | Description | Threat Level |
|----------|---------|-------------|--------------|
| **4625** | Security | Failed logon attempt | 🟡 HIGH |
| **4740** | Security | Account lockout | 🟡 HIGH |
| **4697** | Security | Service installed | 🟡 HIGH |
| **4698** | Security | Scheduled task created | 🟡 HIGH |
| **8004** | AppLocker | Executable blocked | 🟡 HIGH |
| **4610** | Security | Authentication package loaded | 🟡 HIGH |
| **7031** | System | Service terminated unexpectedly | 🟡 HIGH |
| **1121** | Defender | ASR rule triggered (block mode) | 🟡 HIGH |

### Medium Priority Events (Monitoring)

| Event ID | Channel | Description | Threat Level |
|----------|---------|-------------|--------------|
| **4624** | Security | Successful logon | 🔵 MEDIUM |
| **4688** | Security | Process created | 🔵 MEDIUM |
| **4672** | Security | Special privileges assigned | 🔵 MEDIUM |
| **4778** | Security | TS session reconnected | 🔵 MEDIUM |
| **4779** | Security | TS session disconnected | 🔵 MEDIUM |
| **200** | TaskScheduler | Task launched | 🔵 MEDIUM |
| **3008** | DNS-Client | DNS query completed | 🔵 MEDIUM |

### Sysmon Events (Advanced Monitoring)

| Event ID | Channel | Description | Threat Level |
|----------|---------|-------------|--------------|
| **1** | Sysmon | Process creation | 🔵 MEDIUM |
| **3** | Sysmon | Network connection | 🔵 MEDIUM |
| **5** | Sysmon | Process terminated | 🔵 MEDIUM |
| **8** | Sysmon | CreateRemoteThread | 🟡 HIGH |
| **10** | Sysmon | Process access | 🟡 HIGH |
| **13** | Sysmon | Registry value set | 🔵 MEDIUM |
| **19** | Sysmon | WMI filter activity | 🟡 HIGH |
| **22** | Sysmon | DNS query | 🔵 MEDIUM |
| **23** | Sysmon | File delete | 🔵 MEDIUM |

### Windows Defender Events

| Event ID | Channel | Description | Threat Level |
|----------|---------|-------------|--------------|
| **1006** | Defender | Malware detected | 🔴 CRITICAL |
| **1116** | Defender | Malware detected | 🔴 CRITICAL |
| **1007** | Defender | Malware removed | 🟡 HIGH |
| **1117** | Defender | Malware removed | 🟡 HIGH |
| **1121** | Defender | ASR rule blocked | 🟡 HIGH |
| **1123** | Defender | Controlled folder access blocked | 🟡 HIGH |
| **1125** | Defender | Network protection blocked | 🟡 HIGH |

---

## Bibliography and References

### Microsoft Official Documentation
- [Advanced Security Audit Policy Configuration](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/advanced-security-auditing) - Microsoft Official Guide
- [Windows Security Event ID Encyclopedia](https://docs.microsoft.com/en-us/windows/security/threat-protection/auditing/event-descriptions) - Comprehensive Event ID Reference
- [PowerShell Script Block Logging](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_logging) - PowerShell Security Logging
- [Windows Event Log Management](https://docs.microsoft.com/en-us/windows/win32/eventlog/event-logging) - Event Log APIs and Management

### Security Frameworks and Standards
- [NIST Cybersecurity Framework v1.1](https://www.nist.gov/cyberframework) - National Institute of Standards and Technology
- [CIS Controls v8](https://www.cisecurity.org/controls/) - Center for Internet Security Critical Security Controls
- [MITRE ATT&CK Framework](https://attack.mitre.org/) - Adversarial Tactics, Techniques & Common Knowledge
- [SANS Windows Event Logging Cheat Sheet](https://www.sans.org/white-papers/2962/) - SANS Institute

### Technical Resources
- [Ultimate Windows Security Encyclopedia](https://www.ultimatewindowssecurity.com/securitylog/encyclopedia/) - Comprehensive Event ID Database
- [Sysinternals Sysmon](https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon) - System Monitor Tool Documentation
- [Windows Event Forwarding Reference](https://docs.microsoft.com/en-us/windows/security/threat-protection/use-windows-event-forwarding-to-assist-in-intrusion-detection) - Log Centralization
- [PowerShell Execution Policy](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_execution_policies) - PowerShell Security Policies

### Security Research and Best Practices
- [Malware Archaeology Windows Logging Cheat Sheets](https://www.malwarearchaeology.com/cheat-sheets) - Incident Response Logging
- [NSA Windows Event Monitoring Guidance](https://media.defense.gov/2023/Sep/28/2003314465/-1/-1/0/CSI_DETECTING_CYBER_THREATS_WINDOWS_SYSTEM_LOGS_UOO68956-23.PDF) - National Security Agency
- [Australian Cyber Security Centre - Windows Event Logging](https://www.cyber.gov.au/acsc/view-all-content/publications/windows-event-logging-and-forwarding) - ACSC Guidelines
- [UK NCSC Logging Guidance](https://www.ncsc.gov.uk/collection/mobile-device-guidance) - National Cyber Security Centre

⭐ **Star this repository** if you find it useful for your Windows security monitoring needs!

**Version**: 1.0.0  
**Compatibility**: Windows 10/11, Windows Server 2016+
