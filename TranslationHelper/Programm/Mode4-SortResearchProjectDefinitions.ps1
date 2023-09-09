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
# We allow file globs, this resolves them and returns an array of file names for the next steps.
$fileNames = $Worker.ResolveFileGlobs(@("ResearchProjectDefinitions*.xml"), $Config.FolderPathResult)

if (($null -eq $fileNames) -or ($fileNames.Length -eq 0)) {
    $Worker.Log(">", "Red", $Config.MarkerInvalid, "MODE 4", "", "", "Keine Datei für Modus 4 gefunden.")
    return
}

foreach ($fileName in $fileNames) {
    Write-Host "> Starte Verarbeitung von Datei: $fileName"
    
    $file = "$($Config.FolderPathResult)\$fileName"

    $xml = $Worker.Load($file)
    if ($false -eq $xml) {
        $Worker.Log(">>", "Red", $Config.MarkerInvalid, "MODE 4", $fileName, "", "Datei für Modus 4 konnte nicht geladen werden.")
        continue
    }

    if ($null -eq ($xml.ArrayOfResearchProjectDefinition | Get-Member "_OriginalIds_" -MemberType Property)) {
        Write-Host -ForegroundColor Blue ">> A: Von Original zu Sortiert"
        $originalIds = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition.ResearchProjectId
    
        $definitions = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition | % { [pscustomobject]@{"Column" = [int]$_.Column; "Row" = [int]$_.Row; "Element" = $_} }
        $sortedDefinitions = $definitions | Sort-Object -Property Row, Column
        
        $sortedRoot = $xml.ArrayOfResearchProjectDefinition.CloneNode($false)
        $sortedDefinitions | % { $Worker.Append($xml, $sortedRoot, $_.Element) }
        
        # Can also be used instead of the named document root: $xml.DocumentElement
    
        $originalIdsNode = $xml.CreateNode("element", "_OriginalIds_", "")
        $originalIdsNode.InnerText = $originalIds
        $Worker.Append($xml, $sortedRoot, $originalIdsNode)
        $sortedRoot.AppendChild($xml.CreateWhitespace("`r`n")) | Out-Null
    
        $xml.ReplaceChild($sortedRoot, $xml.ArrayOfResearchProjectDefinition) | Out-Null
    
        $sortedIds = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition.ResearchProjectId
    
        Write-Host ">> Davor: Originale ID Reihenfolge: $originalIds"
        Write-Host ">> Danach: Sortierte ID Reihenfolge: $sortedIds"
    
        $Worker.Save($xml, $file)
    } else {
        Write-Host -ForegroundColor Cyan ">> B: Von Sortiert zu Original"
        [int[]]$originalIds = $xml.ArrayOfResearchProjectDefinition._OriginalIds_.Split(" ")
    
        $sortedIds = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition.ResearchProjectId
    
        $definitions = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition | % { [pscustomobject]@{"ID" = [int]$_.ResearchProjectId; "Element" = $_} }
        $originalDefinitions = $originalIds | % { $id = $_; $definitions | ? { $_.ID -eq $id } }
    
        $originalRoot = $xml.ArrayOfResearchProjectDefinition.CloneNode($false)
        $originalDefinitions | % { $Worker.Append($xml, $originalRoot, $_.Element) }
        $xml.ReplaceChild($originalRoot, $xml.ArrayOfResearchProjectDefinition) | Out-Null
    
        # _OriginalIds_ is automatically removed by removing all children of ArrayOfResearchProjectDefinition
        $xml.ArrayOfResearchProjectDefinition.AppendChild($xml.CreateWhitespace("`r`n")) | Out-Null
    
        Write-Host ">> Davor: Sortierte ID Reihenfolge: $sortedIds"
        Write-Host ">> Danach: Originale ID Reihenfolge: $originalIds"
    
        $Worker.Save($xml, $file)
    }
}


