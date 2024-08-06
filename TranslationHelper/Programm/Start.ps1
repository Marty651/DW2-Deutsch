using module .\Worker.psm1

param([string]$Mode, [switch]$Debug, [hashtable]$TestConfig)

# Global Developer Settings
#Requires -Version 7
Set-StrictMode -Version 3.0
$global:ErrorActionPreference = "Stop"
$global:DebugPreference = "Continue"
$global:VerbosePreference = "Continue"

# Global Production Settings
if ($Debug.IsPresent -eq $false) {
    $global:ErrorActionPreference = "Stop"
    $global:DebugPreference = "SilentlyContinue"
    $global:VerbosePreference = "Ignore"
}

# . $PSScriptRoot\Test.ps1
# exit

# Imports
Remove-Module "Worker.Real" -ErrorAction Ignore ; Import-Module $PSScriptRoot\Worker.Real.psm1

# @{ ... }
if ($TestConfig) {
    $Config = $TestConfig
} else {
    $Config = . $PSScriptRoot\..\Konfiguration\Programm.ps1
}

[Worker]$Worker = New-Worker -Config $Config

# @{Name = "", Dateien = @(), Regeln = @()}
$RuleSets = $Config.RuleSets

Write-Host -ForegroundColor Green "
_______          _____        _____             _            _       _____      _       _     
|  __ \ \        / /__ \      |  __ \           | |          | |     |  __ \    | |     | |    
| |  | \ \  /\  / /   ) |_____| |  | | ___ _   _| |_ ___  ___| |__   | |__) |_ _| |_ ___| |__  
| |  | |\ \/  \/ /   / /______| |  | |/ _ \ | | | __/ __|/ __| '_ \  |  ___/ _` | __/ __| '_ \ 
| |__| | \  /\  /   / /_      | |__| |  __/ |_| | |_\__ \ (__| | | | | |  | (_| | || (__| | | |
|_____/   \/  \/   |____|     |_____/ \___|\__,_|\__|___/\___|_| |_| |_|   \__,_|\__\___|_| |_|
GitHub: https://github.com/Marty651/DW2-Deutsch

Entwickler vom Translation-Helper: Countryen (Pascal Schwarz) | c0@countryen.de
Ausgeführt am $(Get-Date -Format "dd.MM.yyyy") mit PowerShell v$($PSVersionTable.PSVersion) ($($PSVersionTable.OS))
"

if ($Worker.IsDebug()) {
    Write-Host -ForegroundColor Yellow "Programm startet mit Konfiguration:"
    $Config | Out-Host
}

if ($Config.DebugOnlyRulesets.Count -gt 0) {
    $RuleSets = $RuleSets | Where-Object { $Config.DebugOnlyRulesets -contains $_.Name }
    Write-Host -ForegroundColor Yellow "Debug-Modus: Es werden nur die Regelsets verarbeitet, die in der Konfiguration unter 'DebugOnlyRulesets' angegeben sind:"
    $RuleSets.Name
    Write-Host
}

if ($Worker.IsDebug()) {
    Write-Host -ForegroundColor Yellow "Folgende Dateien werden verarbeitet (siehe Regeln):"
    $RuleSets | Select-Object -ExpandProperty Dateien | Out-Host
    Write-Host
}

# Start Main Execution of the Selected Program Mode
& $PSScriptRoot\Mode$Mode.ps1 -Worker $Worker -Config $Config -RuleSets $RuleSets

if ($true -eq $Config.CreateLogs) {
    $dateTimeStamp = $Config.Logger.IncludeDateTimeStamp ? (Get-Date -Format "yyyy-MM-dd_hh-mm-ss") : "AKTUELL"
    $filePathLog = "$($Config.Logger.FolderPath)\Modus-$Mode.$dateTimestamp.Log.csv"
    $Worker.SaveLogData($filePathLog)
}