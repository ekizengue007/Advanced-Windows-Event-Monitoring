# APLICADOR REAL DE POLÍTICAS DE AUDITORIA
# Este script APLICA efetivamente todas as configurações baseadas no documento

param(
    [switch]$Force,
    [switch]$Restart,
    [string]$LogFile = "C:\AuditSetup\setup.log"
)

# Verificar privilégios administrativos
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "❌ ERRO: Execute como Administrador!" -ForegroundColor Red
    Write-Host "Clique com botão direito no PowerShell > 'Executar como administrador'" -ForegroundColor Yellow
    Read-Host "Pressione Enter para sair"
    exit 1
}

# Criar diretório de log
$logDir = Split-Path $LogFile -Parent
if (!(Test-Path $logDir)) {
    New-Item -ItemType Directory -Path $logDir -Force | Out-Null
}

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logEntry = "[$timestamp] [$Type] $Message"
    
    switch ($Type) {
        "SUCCESS" { Write-Host $logEntry -ForegroundColor Green }
        "ERROR" { Write-Host $logEntry -ForegroundColor Red }
        "WARNING" { Write-Host $logEntry -ForegroundColor Yellow }
        default { Write-Host $logEntry -ForegroundColor White }
    }
    
    Add-Content -Path $LogFile -Value $logEntry
}

Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host "APLICANDO POLÍTICAS DE AUDITORIA BASEADAS NO DOCUMENTO" -ForegroundColor Cyan
Write-Host "Este script vai REALMENTE aplicar as configurações!" -ForegroundColor Yellow
Write-Host "=" * 80 -ForegroundColor Cyan
Write-Host ""

Write-Log "Iniciando aplicação das políticas de auditoria..." "INFO"

# PASSO 1: APLICAR POLÍTICAS DE AUDITORIA AVANÇADA
Write-Host "1. Aplicando Políticas de Auditoria Avançada..." -ForegroundColor Yellow

try {
    # Account Management
    Write-Log "Configurando Account Management..." "INFO"
    & auditpol /set /subcategory:"User Account Management" /success:enable /failure:enable
    & auditpol /set /subcategory:"Security Group Management" /success:enable /failure:enable  
    & auditpol /set /subcategory:"Computer Account Management" /success:enable /failure:enable
    & auditpol /set /subcategory:"Other Account Management Events" /success:enable /failure:enable
    Write-Log "✓ Account Management configurado" "SUCCESS"

    # Logon/Logoff
    Write-Log "Configurando Logon/Logoff..." "INFO"
    & auditpol /set /subcategory:"Logon" /success:enable /failure:enable
    & auditpol /set /subcategory:"Logoff" /success:enable /failure:enable
    & auditpol /set /subcategory:"Account Lockout" /success:enable /failure:enable
    & auditpol /set /subcategory:"Special Logon" /success:enable /failure:enable
    & auditpol /set /subcategory:"Other Logon/Logoff Events" /success:enable /failure:enable
    & auditpol /set /subcategory:"Group Membership" /success:enable /failure:enable
    Write-Log "✓ Logon/Logoff configurado" "SUCCESS"

    # Detailed Tracking
    Write-Log "Configurando Detailed Tracking..." "INFO"
    & auditpol /set /subcategory:"Process Creation" /success:enable /failure:enable
    & auditpol /set /subcategory:"Process Termination" /success:enable /failure:enable
    & auditpol /set /subcategory:"Plug and Play Events" /success:enable /failure:enable
    Write-Log "✓ Detailed Tracking configurado" "SUCCESS"

    # Policy Change
    Write-Log "Configurando Policy Change..." "INFO"
    & auditpol /set /subcategory:"Audit Policy Change" /success:enable /failure:enable
    & auditpol /set /subcategory:"Authentication Policy Change" /success:enable /failure:enable
    Write-Log "✓ Policy Change configurado" "SUCCESS"

    # System
    Write-Log "Configurando System..." "INFO"
    & auditpol /set /subcategory:"Security System Extension" /success:enable /failure:enable
    & auditpol /set /subcategory:"System Integrity" /success:enable /failure:enable
    Write-Log "✓ System configurado" "SUCCESS"

    # Object Access
    Write-Log "Configurando Object Access..." "INFO"
    & auditpol /set /subcategory:"Registry" /success:enable /failure:enable
    & auditpol /set /subcategory:"File Share" /success:enable /failure:enable
    & auditpol /set /subcategory:"Kernel Object" /success:enable /failure:enable
    & auditpol /set /subcategory:"Other Object Access Events" /success:enable /failure:enable
    Write-Log "✓ Object Access configurado" "SUCCESS"

    # Account Logon
    Write-Log "Configurando Account Logon..." "INFO"
    & auditpol /set /subcategory:"Kerberos Authentication Service" /success:enable /failure:enable
    & auditpol /set /subcategory:"Kerberos Service Ticket Operations" /success:enable /failure:enable
    Write-Log "✓ Account Logon configurado" "SUCCESS"

} catch {
    Write-Log "Erro ao configurar políticas de auditoria: $($_.Exception.Message)" "ERROR"
}

# PASSO 2: CONFIGURAÇÕES DE REGISTRO
Write-Host "`n2. Aplicando Configurações de Registro..." -ForegroundColor Yellow

try {
    # Command Line Process Auditing
    Write-Log "Habilitando Command Line Auditing..." "INFO"
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System\Audit"
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    Set-ItemProperty -Path $regPath -Name "ProcessCreationIncludeCmdLine_Enabled" -Value 1 -Type DWord
    Write-Log "✓ Command Line Auditing habilitado" "SUCCESS"

    # PowerShell Logging
    Write-Log "Habilitando PowerShell Logging..." "INFO"
    
    # Module Logging
    $psModuleRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ModuleLogging"
    if (!(Test-Path $psModuleRegPath)) {
        New-Item -Path $psModuleRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $psModuleRegPath -Name "EnableModuleLogging" -Value 1 -Type DWord
    
    # Script Block Logging
    $psScriptRegPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging"
    if (!(Test-Path $psScriptRegPath)) {
        New-Item -Path $psScriptRegPath -Force | Out-Null
    }
    Set-ItemProperty -Path $psScriptRegPath -Name "EnableScriptBlockLogging" -Value 1 -Type DWord
    Write-Log "✓ PowerShell Logging habilitado" "SUCCESS"

    # Aumentar tamanho dos logs
    Write-Log "Configurando tamanho dos logs..." "INFO"
    
    # Security Log
    $securityLogPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Security"
    Set-ItemProperty -Path $securityLogPath -Name "MaxSize" -Value 1073741824 -Type DWord  # 1GB
    
    # System Log  
    $systemLogPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\System"
    Set-ItemProperty -Path $systemLogPath -Name "MaxSize" -Value 536870912 -Type DWord  # 512MB
    
    # Application Log
    $appLogPath = "HKLM:\SYSTEM\CurrentControlSet\Services\EventLog\Application"
    Set-ItemProperty -Path $appLogPath -Name "MaxSize" -Value 536870912 -Type DWord  # 512MB
    
    Write-Log "✓ Tamanho dos logs configurado" "SUCCESS"

} catch {
    Write-Log "Erro ao aplicar configurações de registro: $($_.Exception.Message)" "ERROR"
}

# PASSO 3: HABILITAR LOGS OPERACIONAIS
Write-Host "`n3. Habilitando Logs Operacionais..." -ForegroundColor Yellow

$operationalLogs = @(
    "Microsoft-Windows-PowerShell/Operational",
    "Microsoft-Windows-TaskScheduler/Operational", 
    "Microsoft-Windows-Windows Defender/Operational",
    "Microsoft-Windows-Sysmon/Operational",
    "Microsoft-Windows-WMI-Activity/Operational",
    "Microsoft-Windows-TerminalServices-RDPClient/Operational",
    "Microsoft-Windows-Bits-Client/Operational",
    "Microsoft-Windows-DNS-Client/Operational",
    "Microsoft-Windows-Dhcp-Client/Operational",
    "Microsoft-Windows-DHCPv6-Client/Operational",
    "Microsoft-Windows-AppLocker/EXE and DLL",
    "Microsoft-Windows-AppLocker/MSI and Script",
    "Microsoft-Windows-AppLocker/Packaged app-Execution",
    "Microsoft-Windows-Security-Mitigations/KernelMode",
    "Microsoft-Windows-Security-Mitigations/UserMode",
    "Microsoft-Windows-Win32k/Operational"
)

foreach ($logName in $operationalLogs) {
    try {
        $eventLog = Get-WinEvent -ListLog $logName -ErrorAction SilentlyContinue
        if ($eventLog) {
            if (!$eventLog.IsEnabled) {
                $eventLog.IsEnabled = $true
                $eventLog.SaveChanges()
                Write-Log "✓ Habilitado: $logName" "SUCCESS"
            } else {
                Write-Log "○ Já habilitado: $logName" "INFO"
            }
        } else {
            Write-Log "⚠ Não encontrado: $logName" "WARNING"
        }
    } catch {
        Write-Log "✗ Erro em $logName`: $($_.Exception.Message)" "ERROR"
    }
}

# PASSO 4: CONFIGURAR WEVTUTIL PARA LOGS ESPECÍFICOS
Write-Host "`n4. Configurando logs via WEVTUTIL..." -ForegroundColor Yellow

try {
    # DNS Client
    & wevtutil set-log "Microsoft-Windows-DNS-Client/Operational" /enabled:true /retention:false /maxsize:104857600
    Write-Log "✓ DNS Client Operational configurado" "SUCCESS"
    
    # DHCP Client
    & wevtutil set-log "Microsoft-Windows-Dhcp-Client/Operational" /enabled:true /retention:false /maxsize:104857600
    Write-Log "✓ DHCP Client Operational configurado" "SUCCESS"
    
    # PowerShell
    & wevtutil set-log "Microsoft-Windows-PowerShell/Operational" /enabled:true /retention:false /maxsize:104857600
    Write-Log "✓ PowerShell Operational configurado" "SUCCESS"

} catch {
    Write-Log "Erro ao configurar logs via WEVTUTIL: $($_.Exception.Message)" "ERROR"
}

# PASSO 5: VERIFICAR CONFIGURAÇÕES APLICADAS
Write-Host "`n5. Verificando Configurações Aplicadas..." -ForegroundColor Yellow

try {
    Write-Log "Gerando relatório de auditoria..." "INFO"
    $auditReport = & auditpol /get /category:*
    
    # Contar políticas habilitadas
    $enabledPolicies = ($auditReport | Select-String "Success and Failure|Success|Failure").Count
    Write-Log "✓ Políticas de auditoria ativas: $enabledPolicies" "SUCCESS"
    
    # Salvar relatório
    $reportPath = "$logDir\audit_report.txt"
    $auditReport | Out-File -FilePath $reportPath -Encoding UTF8
    Write-Log "✓ Relatório salvo em: $reportPath" "SUCCESS"

} catch {
    Write-Log "Erro ao verificar configurações: $($_.Exception.Message)" "ERROR"
}

# PASSO 6: APLICAR CONFIGURAÇÕES DE GRUPO DE POLÍTICA LOCAL
Write-Host "`n6. Aplicando Configurações de Política Local..." -ForegroundColor Yellow

try {
    # Forçar atualização de política
    & gpupdate /force /wait:0
    Write-Log "✓ Política de grupo atualizada" "SUCCESS"
    
} catch {
    Write-Log "Erro ao atualizar política: $($_.Exception.Message)" "ERROR"
}

# PASSO 7: CONFIGURAR SYSMON (SE DISPONÍVEL)
Write-Host "`n7. Verificando Sysmon..." -ForegroundColor Yellow

$sysmonService = Get-Service -Name "Sysmon*" -ErrorAction SilentlyContinue
if ($sysmonService) {
    Write-Log "✓ Sysmon detectado: $($sysmonService.Name)" "SUCCESS"
    
    # Verificar se está rodando
    if ($sysmonService.Status -ne "Running") {
        try {
            Start-Service $sysmonService.Name
            Write-Log "✓ Sysmon iniciado" "SUCCESS"
        } catch {
            Write-Log "Erro ao iniciar Sysmon: $($_.Exception.Message)" "ERROR"
        }
    }
} else {
    Write-Log "⚠ Sysmon não instalado. Recomenda-se instalar para monitoramento avançado." "WARNING"
    Write-Log "  Download: https://docs.microsoft.com/en-us/sysinternals/downloads/sysmon" "INFO"
}

# RESUMO FINAL
Write-Host "`n" + "=" * 80 -ForegroundColor Green
Write-Host "CONFIGURAÇÃO CONCLUÍDA!" -ForegroundColor Green
Write-Host "=" * 80 -ForegroundColor Green

Write-Log "Configuração de auditoria concluída com sucesso!" "SUCCESS"

# Verificar status final
$finalAuditCheck = & auditpol /get /category:* | Select-String "Success and Failure|Success|Failure"
$totalEnabled = $finalAuditCheck.Count

Write-Host ""
Write-Host "📊 RESUMO DA CONFIGURAÇÃO:" -ForegroundColor Cyan
Write-Host "   • Políticas de auditoria habilitadas: $totalEnabled" -ForegroundColor White
Write-Host "   • Logs operacionais configurados: $($operationalLogs.Count)" -ForegroundColor White
Write-Host "   • Command Line Auditing: HABILITADO" -ForegroundColor White
Write-Host "   • PowerShell Logging: HABILITADO" -ForegroundColor White
Write-Host "   • Tamanho dos logs aumentado: SIM" -ForegroundColor White
Write-Host "   • Log de setup: $LogFile" -ForegroundColor White
Write-Host ""

Write-Host "🎯 PRÓXIMOS PASSOS:" -ForegroundColor Yellow
Write-Host "   1. REINICIAR O SISTEMA (Obrigatório)" -ForegroundColor White
Write-Host "   2. Testar geração de eventos" -ForegroundColor White
Write-Host "   3. Configurar monitoramento" -ForegroundColor White
Write-Host ""

if ($Restart) {
    Write-Host "Reiniciando em 30 segundos..." -ForegroundColor Yellow
    Start-Sleep 30
    Restart-Computer -Force
} else {
    Write-Host "⚠ IMPORTANTE: Reinicie o sistema para ativar todas as configurações!" -ForegroundColor Red
    Write-Host ""
    $rebootChoice = Read-Host "Deseja reiniciar agora? (S/N)"
    if ($rebootChoice -match "^[Ss]") {
        Write-Host "Reiniciando..." -ForegroundColor Yellow
        Restart-Computer -Force
    } else {
        Write-Host "Lembre-se de reiniciar manualmente!" -ForegroundColor Yellow
    }
}

Write-Log "Script finalizado." "INFO"