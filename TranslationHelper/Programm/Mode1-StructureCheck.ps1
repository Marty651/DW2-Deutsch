using module .\Worker.psm1

param([Worker]$Worker, $Config, $RuleSetsOld, $RuleSetsNew)

### Functions

function MarkOne($ElementEnNew, $Marker)
{
    $text = "Typ: $($Config.MarkerPreAndPostFix)$Marker$($Config.MarkerPreAndPostFix)"

    $document = $ElementEnNew.OwnerDocument
    $comment = $document.CreateComment($text)
    
    if ($ElementEnNew.GetType().FullName -eq "System.Xml.XmlText") {
        $ElementEnNew.ParentNode.ParentNode.InsertBefore($comment, $ElementEnNew.ParentNode) | Out-Null
    } else {
        $ElementEnNew.ParentNode.InsertBefore($comment, $ElementEnNew) | Out-Null
    }
}

function ProcessTraversing($ElementEnNew, $ElementEnOld, $RuleSetName, $FileName, $Rule, $I)
{
    # Returns
    #   True: Same
    #   False: Different

    if ($null -eq $ElementEnNew) { return $true }
    $Rule = "$Rule/$($ElementEnNew.ToString())$I"

    if ($null -eq $ElementEnOld) {
        $Worker.Log(">>>>", "DarkCyan", $Config.MarkerNew, $RuleSetName, $FileName, $Rule, "Kein Element gefunden in 'Englisch Alt'.")
        MarkOne -ElementEnNew $ElementEnNew -Marker $Config.MarkerNew
        return $false
    }

    if ($ElementEnOld.ToString() -ne $ElementEnNew.ToString()) {
        $Worker.Log(">>>>", "DarkCyan", $Config.MarkerDifferent, $RuleSetName, $FileName, $Rule, "Es wurde ein Element mit anderem Namen [$($ElementEnOld.ToString())] gefunden in 'Englisch Alt'.")
        MarkOne -ElementEnNew $ElementEnNew -Marker $Config.MarkerDifferent
        return $false
    }
    Set-StrictMode -Off
    $elementEnNewChildren = $ElementEnNew.ChildNodes | ? { $_.GetType().FullName -ne "System.Xml.XmlWhiteSpace" }
    $elementEnOldChildren = $ElementEnOld.ChildNodes | ? { $_.GetType().FullName -ne "System.Xml.XmlWhiteSpace" }
    $elementEnNewChildrenCount = $elementEnNewChildren.Length
    #$elementEnNewChildrenCount | Out-Host

    if ($elementEnNewChildrenCount -eq 1) {
        #Write-Host "T1"
        $same = ProcessTraversing -ElementEnNew $elementEnNewChildren -ElementEnOld $elementEnOldChildren `
                                  -RuleSetName $RuleSetName -FileName $FileName `
                                  -Rule $Rule -I "[0]"
        if ($false -eq $same) {
            Write-Host "BREAKKK"
            return $false
        }
    } else {

        for ($i = 0; $i -lt $elementEnNewChildrenCount ; $i++) {
            if ($ElementEnNew.ToString() -eq "TriggerRaceIds") {
                Write-Host "UHU"
                $elementEnNewChildrenCount | Out-Host
                Write-Host $elementEnNewChildren[$i].ToString()
            }

            #$i | Out-Host
            $same = ProcessTraversing -ElementEnNew $elementEnNewChildren[$i] -ElementEnOld $elementEnOldChildren[$i] `
                                    -RuleSetName $RuleSetName -FileName $FileName `
                                    -Rule $Rule -I "[$i]"
            if ($false -eq $same) {
                Write-Host "BREAK"
                break
            }
        }
    }

    if ($Config.ShowGreen) {
        Write-Host -ForegroundColor DarkGreen ">>>> $Rule -> OK."
    }

    return $true
}

### Main Program

Write-Host -ForegroundColor Green "Starte Modus 1 - Prüfung von Strukturänderungen einer Datei (Neu VS Alt)"
Write-Host

foreach ($ruleSet in $RuleSetsOld) {
    $ruleSetName = $ruleSet.Name
    $fileNames = $ruleSet.Dateien
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

        Write-Debug ">>> Alle 2 Dateien vorhanden. Starte Vergleich."

        $rootElementEnNew = $xmlEnNew.SelectSingleNode("/*[1]")
        $rootElementEnOld = $xmlEnOld.SelectSingleNode("/*[1]")
        
        ProcessTraversing -ElementEnNew $rootElementEnNew -ElementEnOld $rootElementEnOld `
                          -RuleSetName $ruleSetName -FileName $fileName `
                          -Rule "/" -I "" `
        | Out-Null

        if ($false -eq $Config.DryRun) {
            Write-Debug "Saving"
            $Worker.Save($xmlEnNew, "$($Config.FolderPathResult)\$fileName")
        }

        Write-Host
    }

    Write-Host
}