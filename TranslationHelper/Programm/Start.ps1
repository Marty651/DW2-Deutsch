# Notes / TODO: 
# - Dad needs the other program first -> check glossar (component def. + names of galactopedia files) against the "fließtexte" (galactopedia)
# - Is not checking empty content really good?
# - Comment nodes instead of text nodes & show both (all) at the same time?
# - Out-Of-Scope FN variable usage !
# - .txt-Dateien (GameText.txt)
# - Optional rules (no invalid but "not found"?)
# - German Config
# - Use XDocument or XPathNavigator for Line Numbers? 
# - - https://learn.microsoft.com/en-us/dotnet/standard/linq/xdocument-class-overview
# - - https://stackoverflow.com/questions/1542073/xdocument-or-xmldocument
# - - https://learn.microsoft.com/en-us/dotnet/standard/data/xml/insert-xml-data-using-xpathnavigator
# - - https://stackoverflow.com/questions/1504467/c-sharp-xml-read-write-xpath-without-using-xmldocument
# - https://stackoverflow.com/questions/42107851/how-to-implement-using-statement-in-powershell
# - Extra:
# - - https://scoop.sh/
# - - https://ohmyposh.dev/docs/installation/windows
# - - https://github.com/dahlbyk/posh-git
# - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.3
# - Marker config (value, active (set), autotranslate, which one to set)
# - Separate rule config files (for normla game and dlc needed)
# - Support Unix better (/ instead of \)

# References:
# - https://learn.microsoft.com/en-us/dotnet/standard/data/xml/saving-and-writing-a-document
# - https://adamtheautomator.com/powershell-classes/
# - https://github.com/pester/Pester

param([int]$Mode)

$ErrorActionPreference = "Stop"

$global:Log = @("TYP; REGELSET; DATEI; PFAD; INFO");
$LogFn = {
    param($steps, $foregroundColor, $type, $ruleSet, $file, $rule, $info)

    Write-Host -ForegroundColor $foregroundColor "$steps $rule -> $type. $info"
    $global:Log += "$type; $ruleSet; $file; $rule; $info"
}

$LoadFn = {
    param($path)

    # The files contain unusual white space (comment on same line for example) and we want to preserve the original formatting.
    # Using [xml] doesn't do that.
    # See:
    # - https://stackoverflow.com/questions/53518785/save-xml-file-without-formatting
    # - https://stackoverflow.com/questions/29624215/using-c-sharp-xml-serializer-to-produce-custom-xml-format
    # - https://stackoverflow.com/questions/203528/what-is-the-simplest-way-to-get-indented-xml-with-line-breaks-from-xmldocument
    # - https://stackoverflow.com/questions/1555028/how-do-i-edit-xml-in-c-sharp-without-changing-format-spacing
    # - https://stackoverflow.com/questions/32149676/custom-xmlwriter-to-skip-a-certain-element

    if (!([System.IO.File]::Exists($path))) {
        # Null behaves weird here
        return $false
    }

    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $true
    $xml.Load($path)

    return $xml
}

$TranslateFn = {
    param($text)

    $params = @{
        auth_key = Get-Content $Config.FilePathDeeplKey
        text = $text
        target_lang = "DE"
    }
    $response = Invoke-RestMethod -Uri $Config.DeeplUrl -Method Post -Body $params
    return $response.translations.text
}

# @{ ... }
$Config = . $PSScriptRoot\..\Konfiguration\Programm.ps1

# @{Name = "", Dateien = @(), Pfade = @()}
$RuleSets = . $Config.FilePathRuleSets

Write-Host -ForegroundColor Green "Programm startet mit Konfiguration:"
$Config | Out-Host

if ($Config.DebugOnlyRulesets.Count -gt 0) {
    $RuleSets = $RuleSets | Where-Object { $Config.DebugOnlyRulesets -contains $_.Name }
    Write-Host -ForegroundColor Yellow "Debug-Modus: Es werden nur die Regelsets verarbeitet, die in der Konfiguration unter 'DebugOnlyRulesets' angegeben sind:"
    $RuleSets.Name
    Write-Host ""
}

Write-Host -ForegroundColor Green "Folgende Dateien werden verarbeitet (siehe Regeln):"
$RuleSets | Select-Object -ExpandProperty Dateien | Out-Host
Write-Host ""

if ($Mode -eq 1) {
    Write-Host -ForegroundColor Green "Starte Modus 1 - Prüfung von Strukturänderungen einer Datei (Neu VS Alt)."
    . $PSScriptRoot\Mode1.ps1 -LogFn $LogFn -LoadFn $LoadFn -TranslateFn $TranslateFn -Config $Config -RuleSets $RuleSets
} elseif ($Mode -eq 2) {
    Write-Host -ForegroundColor Green "Starte Modus 2 - Zusammenführung von Englisch Neu & Englisch Alt & Deutsch Alt"
    . $PSScriptRoot\Mode2.ps1 -LogFn $LogFn -LoadFn $LoadFn -TranslateFn $TranslateFn -Config $Config -RuleSets $RuleSets
} elseif ($Mode -eq 3) {
    Write-Host -ForegroundColor Green "Starte Modus 3 - Zusammenführung von Englisch Neu & Englisch Alt & Deutsch Alt"
    . $PSScriptRoot\Mode3.ps1 -LogFn $LogFn -LoadFn $LoadFn -TranslateFn $TranslateFn -Config $Config -RuleSets $RuleSets
} else {
    Write-Host -ForegroundColor Red "Abbruch. Modus $Mode nicht bekannt. Bitte anderen wählen."
}

if ($false -eq $Config.DryRun) {
    $dateTimeStamp = $Config.Logger.IncludeDateTimeStamp ? (Get-Date -Format "yyyy-MM-dd_hh-mm-ss") : "AKTUELL"
    $filePathLog = "$($Config.Logger.FolderPath)\Modus-$Mode.$dateTimestamp.Log.csv"
    $log | Out-File -FilePath  $filePathLog -Encoding utf8BOM -Force
}