<#
    << Hier wird das Programm konfiguriert. >> 

    Diese Datei wird von PowerShell gestartet/ausgeführt und ausgelesen.
    Es gibt ein paar Stellschrauben, mit denen Man das Programm etwas anpassen kann.
    In der Regel sind die empfohlenene Standardeinstellungen bereits gesetzt.
#>

@{
    UseDeepl = $false
    DryRun = $false
    ShowGreen = $false

    MarkerPreAndPostFix = "#####"
    MarkerInvalid = "UNGÜLTIG"
    MarkerNew = "NEU"
    MarkerNotYetTranslated = "NOCH_NICHT_ÜBERSETZT"
    MarkerOutdated = "VERALTET"

    FilePathRuleSets = ".\Konfiguration\Regeln.ps1"

    FolderPathEnNew = ".\1 Englisch Neu"
    FolderPathEnOld = ".\2 Englisch Alt"
    FolderPathDe = ".\3 Deutsch Alt"

    FolderPathResult = ".\4 Deutsch Neu (Ergebnis)"
    FilePathLog = ".\Logs\Log.$(Get-Date -Format "yyyy-MM-dd_hh-mm-ss").csv"

    FilePathDeeplKey = ".\Schlüssel\Deepl.txt"
    DeeplUrl = "https://api-free.deepl.com/v2/translate"
}