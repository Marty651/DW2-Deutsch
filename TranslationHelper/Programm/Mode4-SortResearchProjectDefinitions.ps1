using module .\Worker.psm1

param([Worker]$Worker, $Config, $RuleSets)

### Functions

### Main Program

Write-Host -ForegroundColor Green "
Starte Modus 4 - Sortieren der ResearchProjectDefinitions.
Dieser Modus ist in zwei Teile geteilt:
    A: Die ResearchProjectDefinitions.xml wird ausgelesen 
        und sortiert nach Row und dann Column.
        Dabei wird die originale Reihenfolge in der Datei mit gespeichert.
    B: Die ResearchProjectDefinitions.xml wird ausgelesen
        und zurück in die originale Reihenfolge gebracht.
        Dazu wird die originale Reihenfolge aus der Datei gelesen.

    Das Programm erkennt selbst, welcher Teil ausgeführt wird.

"

$file = "$($Config.FolderPathResult)\ResearchProjectDefinitions_Ikkuro.xml"
$xml = $Worker.Load($file)
if ($null -eq ($xml.ArrayOfResearchProjectDefinition | Get-Member "_OriginalIds_" -MemberType Property)) {
    Write-Host "A: Von Original zu Sortiert"
    $originalIds = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition.ResearchProjectId

    $definitions = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition | % { [pscustomobject]@{"Column" = [int]$_.Column; "Row" = [int]$_.Row; "Element" = $_} }
    $sortedDefinitions = $definitions | Sort-Object -Property Row, Column
    
    $sortedRoot = $xml.ArrayOfResearchProjectDefinition.CloneNode($false)
    $sortedDefinitions | % { $sortedRoot.AppendChild($_.Element) | Out-Null }
    $xml.ReplaceChild($sortedRoot, $xml.ArrayOfResearchProjectDefinition) | Out-Null

    # Can also be used instead of the named document root: $xml.DocumentElement

    $originalIdsNode = $xml.ArrayOfResearchProjectDefinition.AppendChild($xml.CreateNode("element", "_OriginalIds_", ""))
    $xml.ArrayOfResearchProjectDefinition.AppendChild($xml.CreateWhitespace("`r`n")) | Out-Null
    $originalIdsNode.InnerText = $originalIds

    $sortedIds = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition.ResearchProjectId

    Write-Host "> Davor: Originale ID Reihenfolge: $originalIds"
    Write-Host "> Jetzt: Sortierte ID Reihenfolge: $sortedIds"

    $Worker.Save($xml, $file);
} else {
    Write-Host "B: Von Sortiert zu Original"
    [int[]]$originalIds = $xml.ArrayOfResearchProjectDefinition._OriginalIds_.Split(" ")

    $sortedIds = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition.ResearchProjectId

    $definitions = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition | % { [pscustomobject]@{"ID" = [int]$_.ResearchProjectId; "Element" = $_} }
    $originalDefinitions = $originalIds | % { $id = $_; $definitions | ? { $_.ID -eq $id } }

    $originalRoot = $xml.ArrayOfResearchProjectDefinition.CloneNode($false)
    $originalDefinitions | % { $originalRoot.AppendChild($_.Element) | Out-Null }
    $xml.ReplaceChild($originalRoot, $xml.ArrayOfResearchProjectDefinition) | Out-Null

    # _OriginalIds_ is automatically removed by removing all children of ArrayOfResearchProjectDefinition
    $xml.ArrayOfResearchProjectDefinition.AppendChild($xml.CreateWhitespace("`r`n")) | Out-Null

    Write-Host "> Davor: Sortierte ID Reihenfolge: $sortedIds"
    Write-Host "> Jetzt: Originale ID Reihenfolge: $originalIds"

    $Worker.Save($xml, $file);
}