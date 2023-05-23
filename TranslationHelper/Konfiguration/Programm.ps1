<#
    << Hier wird das Programm konfiguriert. >> 

    Diese Datei wird von PowerShell gestartet/ausgeführt und ausgelesen.
    Es gibt ein paar Stellschrauben, mit denen Man das Programm etwas anpassen kann.
    In der Regel sind die empfohlenene Standardeinstellungen bereits gesetzt.
#>

# Kommt noch ...

@{
    UseDeepl = $false
    DryRun = $false
    ShowGreen = $false

    DebugOnlyRulesets = @()

    MarkerPreAndPostFix = "#####"
    MarkerInvalid = "UNGÜLTIG"
    MarkerNew = "NEU"
    MarkerNotYetTranslated = "NOCH_NICHT_ÜBERSETZT"
    MarkerOutdated = "VERALTET"

    FilePathRuleSets = "$PSScriptRoot\Regeln.ps1"

    FolderPathEnNew = "$PSScriptRoot\..\1 Englisch Neu"
    FolderPathEnOld = "$PSScriptRoot\..\2 Englisch Alt"
    FolderPathDe = "$PSScriptRoot\..\3 Deutsch Alt"

    FolderPathResult = "$PSScriptRoot\..\4 Deutsch Neu (Ergebnis)"
    FilePathLog = "$PSScriptRoot\..\Logs\Prototyp.Log.$(Get-Date -Format "yyyy-MM-dd_hh-mm-ss").csv"

    FilePathDeeplKey = "$PSScriptRoot\..\Schlüssel\Deepl.txt"
    DeeplUrl = "https://api-free.deepl.com/v2/translate"
}