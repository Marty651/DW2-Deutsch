<#
    << Hier wird das Programm konfiguriert. >> 

    Diese Datei wird von PowerShell gestartet/ausgeführt und ausgelesen.
    Es gibt ein paar Stellschrauben, mit denen Man das Programm etwas anpassen kann.
    In der Regel sind die empfohlenen Standardeinstellungen bereits gesetzt.
#>

@{
    DryRun = $false
    ShowGreen = $false
    CreateLogs = $true

    DebugOnlyRulesets = @()
    # DebugOnlyRulesets = @("DLC-Versionen #1 Game Events")
    # DebugOnlyRulesets = @("DLC-Versionen #3 Game Events")
    # DebugOnlyRulesets = @("Basic-Versionen #2 Name + Description")
    # DebugOnlyRulesets = @("Basic-Versionen #3 Game Events")

    MarkerPreAndPostFix = "_____"
    MarkerInvalid = "UNGÜLTIG"
    MarkerNew = "NEU"
    MarkerNotYetTranslated = "NOCH_NICHT_ÜBERSETZT"
    MarkerNoDifference = "DEUTSCH_UND_ENGLISCH_GLEICH"
    MarkerOutdated = "VERALTET"
    MarkerDifferent = "UNTERSCHIEDLICH"
    MarkerNoFile = "KEINE_DATEI"
    MarkerMissingFile = "FEHLENDE_DATEI"
    MarkerNoElements = "KEINE_ELEMENTE_GEFUNDEN"

    RuleSetsOld = (. "$PSScriptRoot\Regeln.ps1")
    RuleSetsNew = (. "$PSScriptRoot\Regeln-Neu.ps1")

    FolderPathEnNew = "$PSScriptRoot\..\1 Englisch Neu"
    FolderPathEnOld = "$PSScriptRoot\..\2 Englisch Alt"
    FolderPathDe = "$PSScriptRoot\..\3 Deutsch Alt"

    FolderPathResult = "$PSScriptRoot\..\4 Deutsch Neu (Ergebnis)"

    Logger = @{
        FolderPath = "$PSScriptRoot\..\Logs"
        IncludeDateTimeStamp = $false
    }

    Deepl = @{
        Enabled = $false
        ShowGreen = $false
        KeyFilePath = "$PSScriptRoot\..\Schlüssel\Deepl.txt"
        GlossaryFilePath = "$PSScriptRoot\Glossar.csv"
        Url = "https://api-free.deepl.com/v2/"
        TranslateGlossaryId = ""
        MinWords = 3
    }

    Mode6 = @{
        FilePathIn = "$PSScriptRoot\..\1 Englisch Neu\GameText.txt"
        FilePathOut = "$PSScriptRoot\..\1 Englisch Neu\GameText.txt"
        Skip = 0
        First = 10000
    }
}