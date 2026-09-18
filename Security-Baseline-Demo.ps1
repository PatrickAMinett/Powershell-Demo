# Security Baseline Demo
# Patrick Minett
#
# A simple PowerShell script for experimenting with
# basic Windows security configuration checks.

Write-Host 
Write-Host ========================================== -ForegroundColor Cyan
Write-Host        Windows Security Baseline Demo -ForegroundColor Cyan
Write-Host ========================================== -ForegroundColor Cyan
Write-Host 

function Show-Check {
    param (
        [string]$Name,
        [bool]$Passed,
        [string]$Details
    )

    if ($Passed) {
        Write-Host [PASS]  -ForegroundColor Green -NoNewline
    }
    else {
        Write-Host [WARN]  -ForegroundColor Yellow -NoNewline
    }

    Write-Host $Name - $Details
}

# Firewall
$Firewall = Get-NetFirewallProfile 
    Where-Object { $_.Enabled -eq $true }

Show-Check `
    -Name Windows Firewall `
    -Passed ($Firewall.Count -eq 3) `
    -Details $($Firewall.Count)3 firewall profiles enabled

# BitLocker
$BitLocker = Get-BitLockerVolume -MountPoint $envSystemDrive -ErrorAction SilentlyContinue

if ($BitLocker) {
    $BitLockerEnabled = $BitLocker.ProtectionStatus -eq On
    Show-Check `
        -Name BitLocker `
        -Passed $BitLockerEnabled `
        -Details Protection status $($BitLocker.ProtectionStatus)
}
else {
    Show-Check `
        -Name BitLocker `
        -Passed $false `
        -Details Unable to determine BitLocker status
}

# Microsoft Defender
$Defender = Get-MpComputerStatus -ErrorAction SilentlyContinue

if ($Defender) {
    Show-Check `
        -Name Microsoft Defender `
        -Passed $Defender.RealTimeProtectionEnabled `
        -Details Real-time protection $($Defender.RealTimeProtectionEnabled)
}
else {
    Show-Check `
        -Name Microsoft Defender `
        -Passed $false `
        -Details Unable to determine Defender status
}

# Remote Desktop
$RDP = Get-ItemProperty `
    HKLMSystemCurrentControlSetControlTerminal Server `
    -Name fDenyTSConnections `
    -ErrorAction SilentlyContinue

$RDPEnabled = $RDP.fDenyTSConnections -eq 0

Show-Check `
    -Name Remote Desktop `
    -Passed (-not $RDPEnabled) `
    -Details Enabled $RDPEnabled

# SMBv1
$SMB = Get-WindowsOptionalFeature `
    -Online `
    -FeatureName SMB1Protocol `
    -ErrorAction SilentlyContinue

$SMBEnabled = $SMB.State -eq Enabled

Show-Check `
    -Name SMBv1 `
    -Passed (-not $SMBEnabled) `
    -Details Enabled $SMBEnabled

# Local Administrators
$Admins = Get-LocalGroupMember `
    -Group Administrators `
    -ErrorAction SilentlyContinue

Show-Check `
    -Name Local Administrators `
    -Passed ($Admins.Count -le 3) `
    -Details $($Admins.Count) members found

Write-Host 
Write-Host ========================================== -ForegroundColor Cyan
Write-Host Demo complete. -ForegroundColor Cyan
Write-Host ========================================== -ForegroundColor Cyan
Write-Host 