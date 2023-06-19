using module .\Helper.psm1

param([int]$Mode)

# Global Developer Settingsv
Set-StrictMode -Version 3.0
$global:ErrorActionPreference = "Stop"
$global:DebugPreference = "Continue"

# . $PSScriptRoot\Test.ps1
# exit

# Imports
Remove-Module "Helper.Real" -ErrorAction Ignore ; Import-Module $PSScriptRoot\Helper.Real.psm1

# @{ ... }
$Config = . $PSScriptRoot\..\Konfiguration\Programm.ps1

[Helper]$Helper = New-HelperClass -Config $Config

# @{Name = "", Dateien = @(), Regeln = @()}
$RuleSets = . $Config.FilePathRuleSets

if ($Helper.IsDebug()) {
    Write-Host -ForegroundColor Green "Programm startet mit Konfiguration:"
    $Config | Out-Host
}

if ($Config.DebugOnlyRulesets.Count -gt 0) {
    $RuleSets = $RuleSets | Where-Object { $Config.DebugOnlyRulesets -contains $_.Name }
    Write-Host -ForegroundColor Yellow "Debug-Modus: Es werden nur die Regelsets verarbeitet, die in der Konfiguration unter 'DebugOnlyRulesets' angegeben sind:"
    $RuleSets.Name
    Write-Host
}

if ($Helper.IsDebug()) {
    Write-Host -ForegroundColor Green "Folgende Dateien werden verarbeitet (siehe Regeln):"
    $RuleSets | Select-Object -ExpandProperty Dateien | Out-Host
    Write-Host
}

# Start Execution of the Mode
& $PSScriptRoot\Mode$Mode.ps1 -Helper $Helper -Config $Config -RuleSets $RuleSets

if ($false -eq $Config.DryRun) {
    $dateTimeStamp = $Config.Logger.IncludeDateTimeStamp ? (Get-Date -Format "yyyy-MM-dd_hh-mm-ss") : "AKTUELL"
    $filePathLog = "$($Config.Logger.FolderPath)\Modus-$Mode.$dateTimestamp.Log.csv"
    $Helper.SaveLogData($filePathLog)
}