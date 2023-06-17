class TestA
{
    $UseDeepl = $false
    $DryRun
    $ShowGreen

    $DebugOnlyRulesets = @("Basic-Versionen #3 Game Events")

    $MarkerPreAndPostFix = "_____"
    $MarkerInvalid = "UNGÜLTIG"
    $MarkerNew = "NEU"
    $MarkerNotYetTranslated = "NOCH_NICHT_ÜBERSETZT"
    $MarkerNoDifference = "DEUTSCH_UND_ENGLISCH_GLEICH"
    [object]$MarkerOutdated = "VERALTET"
    [object]$MarkerDifferent = "UNTERSCHIEDLICH"

    [object]$FilePathRuleSets = "$PSScriptRoot\Regeln.ps1"

    [object]$FolderPathEnNew = "$PSScriptRoot\..\1 Englisch Neu"
    [object]$FolderPathEnOld = "$PSScriptRoot\..\2 Englisch Alt"
    [object]$FolderPathDe = "$PSScriptRoot\..\3 Deutsch Alt"

    [object]$FolderPathResult = "$PSScriptRoot\..\4 Deutsch Neu (Ergebnis)"

    [object]$Logger = @{
        FolderPath = "$PSScriptRoot\..\Logs"
        IncludeDateTimeStamp = $false
    }

    [object]$FilePathDeeplKey = "$PSScriptRoot\..\Schlüssel\Deepl.txt"
    [object]$DeeplUrl = "h"
}

class TestB : TestA 
{
    $UseDeepl = $false
    $UseX
}

[TestB]::new()

[TestA]::new()