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
if ($null -eq ($xml.ArrayOfResearchProjectDefinition | Get-Member "_ids_" -MemberType Property)) {
    Write-Host "A"
    $ids = $xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition.ResearchProjectId
    #$xml | gm
    
    #$xml.ArrayOfResearchProjectDefinition


    #$xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition 
    
    [int[]]$xml.ArrayOfResearchProjectDefinition.ResearchProjectDefinition.Row | sort
    
    $xml2 = $xml.Clone()
    
    $xml.ArrayOfResearchProjectDefinition.AppendChild($xml.CreateNode("element", "_ids_", ""))
    $xml.ArrayOfResearchProjectDefinition
    $xml2.ArrayOfResearchProjectDefinition


    #$idsnode = $xml.ArrayOfResearchProjectDefinition.AppendChild($xml.CreateNode("element", "_ids_", ""))
    #$idsnode.InnerText = $ids
    #$Worker.Save($xml, $file);
} else {
    Write-Host "B"
    $ids = $xml.ArrayOfResearchProjectDefinition._ids_
    #$ids
    #$xml.ArrayOfResearchProjectDefinition | gm
    $xml.ArrayOfResearchProjectDefinition.RemoveChild($xml.ArrayOfResearchProjectDefinition.Item("_ids_")) | Out-Null
    #$xml.ArrayOfResearchProjectDefinition
    $Worker.Save($xml, $file);
}




exit;


foreach ($ruleSet in $RuleSets) {
    $ruleSetName = $ruleSet.Name
    $fileNames = $ruleSet.Dateien
    $rules = $ruleSet.Regeln
    Write-Host "> Starte Verarbeitung von Regelset: $ruleSetName"

    # We allow file globs, this resolves them and returns an array of file names for the next steps.
    $fileNames = $Worker.ResolveFileGlobs($fileNames, $Config.FolderPathEnNew)

    if (($null -eq $fileNames) -or ($fileNames.Length -eq 0)) {
        $Worker.Log(">>", "Red", $Config.MarkerInvalid, $ruleSetName, "", "", "Keine Datei für 'Englisch Neu' gefunden.")
        continue
    }

    foreach ($fileName in $fileNames) {
        Write-Host ">> Starte Verarbeitung von Datei: $fileName"        

        $xmlEnNew = $Worker.Load("$($Config.FolderPathEnNew)\$fileName")
        if ($false -eq $xmlEnNew) {
            $Worker.Log(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, $fileName, "", "Datei 'Englisch Neu' konnte nicht geladen werden.")
            continue
        }

        $xmlEnOld = $Worker.Load("$($Config.FolderPathEnOld)\$fileName")
        if ($false -eq $xmlEnOld) {
            $Worker.Log(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, $fileName, "", "Datei 'Englisch Alt' konnte nicht gefunden/geladen werden.")
            continue
        }

        $xmlDe = $Worker.Load("$($Config.FolderPathDe)\$fileName")
        if ($false -eq $xmlDe) {
            $Worker.Log(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, $fileName, "", "Datei 'Deutsch Alt' konnte nicht gefunden/geladen werden.")
            continue
        }

        Write-Debug ">>> Alle 3 Dateien vorhanden. Starte Verarbeitung von Regeln."
        
        foreach ($rule in $rules) {
            $elementsEnNew = $xmlEnNew.SelectNodes($rule);
            $elementsEnOld = $xmlEnOld.SelectNodes($rule);
            $elementsDe = $xmlDe.SelectNodes($rule);

            $elementsEnNewCount = $elementsEnNew.Count

            if ($elementsEnNewCount -eq 0) {
                $Worker.Log(">>>>", "DarkYellow", $Config.MarkerInvalid, $ruleSetName, $fileName, $rule, "Kein Element gefunden in 'Englisch Neu'.")
                continue;
            } 

            if ($elementsEnNewCount -eq 1) {
                ProcessOne  -ElementEnNew $elementsEnNew -ElementEnOld $elementsEnOld -ElementDe $elementsDe `
                            -RuleSetName $ruleSetName -FileName $fileName -Rule $rule 
                continue
            }

            for ($i = 0; $i -lt $elementsEnNewCount; $i++) {
                ProcessOne  -ElementEnNew $elementsEnNew[$i] -ElementEnOld $elementsEnOld[$i] -ElementDe $elementsDe[$i] `
                            -RuleSetName $ruleSetName -FileName $fileName -Rule "$rule ($i)"
            }   
        }

        if ($false -eq $Config.DryRun) {
            Write-Debug "Saving"
            $Worker.Save($xmlEnNew, "$($Config.FolderPathResult)\$fileName")
        }

        Write-Host
    }

    Write-Host
}