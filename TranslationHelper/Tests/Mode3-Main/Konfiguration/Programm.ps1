@{
    DryRun = $false
    ShowGreen = $true
    CreateLogs = $false

    DebugOnlyRulesets = @()

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
}