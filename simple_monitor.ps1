# MONITOR SIMPLES - Verifica eventos críticos baseados no documento
# Execute este após aplicar as políticas para ver se está funcionando

param(
    [int]$Minutes = 60,
    [switch]$Continuous
)

function Show-CriticalEvents {
    param([int]$TimeframeMinutes = 60)
    
    Write-Host "🔍 Verificando eventos críticos dos últimos $TimeframeMinutes minutos..." -ForegroundColor Cyan
    Write-Host ""
    
    $startTime = (Get-Date).AddMinutes(-$TimeframeMinutes)
    $criticalEvents = @()
    
    # Eventos críticos do documento
    $criticalEventIDs = @{
        4625 = "Failed Login"
        4740 = "Account Lockout" 
        4782 = "Password Hash Accessed"
        1102 = "Security Log Cleared"
        104 = "Event Log Cleared"
        4697 = "Service Installed"
        4698 = "Scheduled Task Created"
        4688 = "Process Created"
        4624 = "Successful Login"
        4672 = "Special Privileges"
    }
    
    foreach ($eventID in $criticalEventIDs.Keys) {
        try {
            $events = Get-WinEvent -FilterHashtable @{
                LogName = 'Security'
                ID = $eventID
                StartTime = $startTime
            } -MaxEvents 10 -ErrorAction SilentlyContinue
            
            foreach ($event in $events) {
                $criticalEvents += [PSCustomObject]@{
                    Time = $event.TimeCreated
                    EventID = $event.Id
                    Description = $criticalEventIDs[$event.Id]
                    Computer = $event.MachineName
                    Level = switch ($event.Id) {
                        {$_ -in @(1102, 104, 4782)} { "🔴 CRITICAL" }
                        {$_ -in @(4625, 4740, 4697, 4698)} { "🟡 HIGH" }
                        default { "🔵 MEDIUM" }
                    }
                }
            }
        } catch {
            # Evento não encontrado ou log não disponível
        }
    }
    
    # Verificar eventos do Windows Defender
    try {
        $defenderEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-Windows Defender/Operational'
            ID = @(1006, 1116, 1121, 1123)  # Malware detected, ASR blocks
            StartTime = $startTime
        } -MaxEvents 5 -ErrorAction SilentlyContinue
        
        foreach ($event in $defenderEvents) {
            $criticalEvents += [PSCustomObject]@{
                Time = $event.TimeCreated
                EventID = $event.Id
                Description = "Windows Defender Alert"
                Computer = $event.MachineName
                Level = "🔴 CRITICAL"
            }
        }
    } catch {
        # Defender log não disponível
    }
    
    # Verificar eventos do Sysmon (se disponível)
    try {
        $sysmonEvents = Get-WinEvent -FilterHashtable @{
            LogName = 'Microsoft-Windows-Sysmon/Operational'
            ID = @(1, 3, 8, 10)  # Process creation, network, remote thread, process access
            StartTime = $startTime
        } -MaxEvents 5 -ErrorAction SilentlyContinue
        
        foreach ($event in $sysmonEvents) {
            $criticalEvents += [PSCustomObject]@{
                Time = $event.TimeCreated
                EventID = $event.Id
                Description = "Sysmon Activity"
                Computer = $event.MachineName
                Level = "🔵 MEDIUM"
            }
        }
    } catch {
        # Sysmon não disponível
    }
    
    # Mostrar resultados
    if ($criticalEvents.Count -eq 0) {
        Write-Host "✅ Nenhum evento crítico encontrado nos últimos $TimeframeMinutes minutos" -ForegroundColor Green
        Write-Host "   (Isso pode significar que o sistema está seguro ou que a auditoria não está funcionando)" -ForegroundColor Gray
    } else {
        Write-Host "📊 Encontrados $($criticalEvents.Count) eventos relevantes:" -ForegroundColor Yellow
        Write-Host ""
        
        $criticalEvents | Sort-Object Time -Descending | ForEach-Object {
            $timeStr = $_.Time.ToString("HH:mm:ss")
            Write-Host "$($_.Level) [$timeStr] Event $($_.EventID): $($_.Description)" -ForegroundColor White
        }
        
        # Estatísticas
        $criticalCount = ($criticalEvents | Where-Object { $_.Level -like "*CRITICAL*" }).Count
        $highCount = ($criticalEvents | Where-Object { $_.Level -like "*HIGH*" }).Count
        $mediumCount = ($criticalEvents | Where-Object { $_.Level -like "*MEDIUM*" }).Count
        
        Write-Host ""
        Write-Host "📈 Resumo: CRITICAL: $criticalCount | HIGH: $highCount | MEDIUM: $mediumCount" -ForegroundColor Cyan
    }
    
    Write-Host ""
    Write-Host "⏰ Última verificação: $(Get-Date -Format 'HH:mm:ss')" -ForegroundColor Gray
    Write-Host "-" * 70
}

# Verificar se auditoria está funcionando
function Test-AuditingActive {
    Write-Host "🔧 Testando se auditoria está ativa..." -ForegroundColor Yellow
    
    try {
        # Verificar política de Process Creation
        $processAudit = & auditpol /get /subcategory:"Process Creation" | Select-String "Success and Failure|Success"
        if ($processAudit) {
            Write-Host "✅ Process Creation Auditing: ATIVO" -ForegroundColor Green
        } else {
            Write-Host "❌ Process Creation Auditing: INATIVO" -ForegroundColor Red
            return $false
        }
        
        # Verificar política de Logon
        $logonAudit = & auditpol /get /subcategory:"Logon" | Select-String "Success and Failure|Success"
        if ($logonAudit) {
            Write-Host "✅ Logon Auditing: ATIVO" -ForegroundColor Green
        } else {
            Write-Host "❌ Logon Auditing: INATIVO" -ForegroundColor Red
            return $false
        }
        
        # Testar geração de evento
        Write-Host "🧪 Gerando evento de teste..." -ForegroundColor Yellow
        $testProcess = Start-Process notepad -PassThru -WindowStyle Hidden
        Start-Sleep 2
        Stop-Process $testProcess -Force
        
        # Verificar se evento foi gerado
        Start-Sleep 3
        $testEvent = Get-WinEvent -FilterHashtable @{
            LogName = 'Security'
            ID = 4688
            StartTime = (Get-Date).AddMinutes(-2)
        } -MaxEvents 1 -ErrorAction SilentlyContinue
        
        if ($testEvent) {
            Write-Host "✅ Evento de teste detectado: Auditoria funcionando!" -ForegroundColor Green
            return $true
        } else {
            Write-Host "⚠️ Evento de teste não detectado. Pode precisar de reinicialização." -ForegroundColor Yellow
            return $false
        }
        
    } catch {
        Write-Host "❌ Erro ao testar auditoria: $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Função principal
function Start-SimpleMonitor {
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host "MONITOR SIMPLES DE EVENTOS - BASEADO NO DOCUMENTO" -ForegroundColor Cyan
    Write-Host "=" * 70 -ForegroundColor Cyan
    Write-Host ""
    
    # Testar se auditoria está funcionando
    $auditWorking = Test-AuditingActive
    Write-Host ""
    
    if (!$auditWorking) {
        Write-Host "⚠️ ATENÇÃO: Auditoria pode não estar funcionando corretamente!" -ForegroundColor Red
        Write-Host "   Recomendação: Execute o script de aplicação e reinicie o sistema." -ForegroundColor Yellow
        Write-Host ""
    }
    
    if ($Continuous) {
        Write-Host "🔄 Modo contínuo ativado. Pressione Ctrl+C para parar." -ForegroundColor Green
        Write-Host ""
        
        while ($true) {
            Show-CriticalEvents -TimeframeMinutes $Minutes
            Start-Sleep 60  # Verificar a cada minuto
        }
    } else {
        Show-CriticalEvents -TimeframeMinutes $Minutes
    }
}

# Executar
Start-SimpleMonitor