using module .\Helper.psm1

param([Helper]$Helper, $Config, $RuleSets)

### Functions

function ProcessOne($Helper, $XmlEnNew, $ElementEnNew, $ElementEnOld, $ElementDe, $RuleSetName, $FileName, $Rule)
{
    if ($Config.DryRun) {
        Write-Host -ForegroundColor Magenta ">>>> $Rule"
        return
    }

    # Workaround: Some "empty" elements are not recognized as such, so we add a text node if it doesn't exist.
    # TODO: Maybe it's better to just ignore empty or throw a warning/error/invalid?
    if (!($ElementEnNew | Get-Member "#text" -MemberType Property)) {
        $ElementEnNew.AppendChild($XmlEnNew.CreateTextNode([String]::Empty)) | Out-Null
    }

    if ($null -eq $ElementEnOld) {
        $Helper.Log(">>>>", "DarkCyan", $Config.MarkerNotYetTranslated, $RuleSetName, $FileName, $Rule, "Kein Element gefunden in 'Englisch Alt'.")
        $ElementEnNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNotYetTranslated + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $Helper.Translate($ElementEnNew."#text") : $ElementEnNew."#text")
        return
    }
    elseif ($ElementEnOld.InnerText -ne $ElementEnNew.InnerText) {
        $Helper.Log(">>>>", "DarkCyan", $Config.MarkerOutdated, $RuleSetName, $File, $Rule, "Neuen Text in 'Englisch Neu' gefunden, der nicht genau gleich in 'Englisch Alt' existiert.")
        $ElementEnNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerOutdated + $Config.MarkerPreAndPostFix + " " + $ElementEnNew."#text"
        return
    }

    # Elements in EN_NEW and EN_OLD exist and text is equal!

    if ($null -eq $ElementDe) {
        $Helper.Log(">>>>", "DarkCyan", $Config.MarkerNotYetTranslated, $RuleSetName, $File, $Rule, "Kein Element gefunden in 'Deutsch Alt'.")
        $ElementEnNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNotYetTranslated + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $Helper.Translate($ElementEnNew."#text") : $ElementEnNew."#text")
        return
    }
    elseif (($ElementEnNew.InnerText -eq $ElementDe.InnerText) -and ($ElementEnNew.InnerText -ne [String]::Empty)) {
        $Helper.Log(">>>>", "DarkCyan", $Config.MarkerNoDifference, $RuleSetName, $File, $Rule, "Texte von 'Englisch Neu' bzw. 'Englisch Alt' stimmen mit dem Text in 'Deutsch Alt' überein.")
        $ElementEnNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNoDifference + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $Helper.Translate($ElementEnNew."#text") : $ElementEnNew."#text")
        return
    }
        
    # Element in EN_NEW exists and is the same as in EN_OLD and not the same as in DE!
    if ($Config.ShowGreen) {
        Write-Host -ForegroundColor DarkGreen ">>>> $Rule -> Fertig, bereits übersetzt."
    }
    
    $ElementEnNew."#text" = $ElementDe."#text"
}

### Main Program

Write-Host -ForegroundColor Green "Starte Modus 3 - Der Hauptmodus."
Write-Host -ForegroundColor Green "Zusammenführung von Englisch Neu & Englisch Alt & Deutsch Alt"
Write-Host -ForegroundColor Green "(Automatische Übernahme bei neuen Versionen)"

foreach ($ruleSet in $RuleSets) {
    $ruleSetName = $ruleSet.Name
    $fileNames = $ruleSet.Dateien
    $rules = $ruleSet.Regeln
    Write-Host "> Starte Verarbeitung von Regelset: $ruleSetName"

    # We allow file globs, this resolves them and returns an array of file names for the next steps.
    $fileNames = $Helper.ResolveFileGlobs($fileNames, $Config.FolderPathEnNew)

    if ($fileNames.Count -eq 0) {
        $Helper.Log(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, "", "", "Keine Datei für 'Englisch Neu' gefunden.")
        continue
    }

    foreach ($fileName in $fileNames) {
        Write-Host ">> Starte Verarbeitung von Datei: $fileName"        

        $xmlEnNew = $Helper.Load("$($Config.FolderPathEnNew)\$fileName")
        if ($false -eq $xmlEnNew) {
            $Helper.Log(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, $fileName, "", "Datei 'Englisch Neu' konnte nicht geladen werden.")
            continue
        }

        $xmlEnOld = $Helper.Load("$($Config.FolderPathEnOld)\$fileName")
        if ($false -eq $xmlEnOld) {
            $Helper.Log(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, $fileName, "", "Datei 'Englisch Alt' konnte nicht gefunden/geladen werden.")
            continue
        }

        $xmlDe = $Helper.Load("$($Config.FolderPathDe)\$fileName")
        if ($false -eq $xmlDe) {
            $Helper.Log(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, $fileName, "", "Datei 'Deutsch Alt' konnte nicht gefunden/geladen werden.")
            continue
        }

        Write-Host ">>> Alle 3 Dateien vorhanden. Starte Verarbeitung von Regeln."

        foreach ($rule in $rules) {
            $elementsEnNew = $xmlEnNew.SelectNodes($rule);
            $elementsEnOld = $xmlEnOld.SelectNodes($rule);
            $elementsDe = $xmlDe.SelectNodes($rule);

            $elementsEnNewCount = $elementsEnNew.Count

            if ($elementsEnNewCount -eq 0) {
                $Helper.Log(">>>>", "DarkYellow", $Config.MarkerInvalid, $ruleSetName, $fileName, $rule, "Kein Element gefunden in 'Englisch Neu'.")
                continue;
            } 

            if ($elementsEnNewCount -eq 1) {
                ProcessOne  -Helper $Helper `
                            -XmlEnNew $xmlEnNew `
                            -ElementEnNew $elementsEnNew -ElementEnOld $elementsEnOld -ElementDe $elementsDe `
                            -RuleSetName $ruleSetName -FileName $fileName -Rule $rule 
                continue
            }

            for ($i = 0; $i -lt $elementsEnNewCount; $i++) {
                ProcessOne  -Helper $Helper `
                            -XmlEnNew $xmlEnNew `
                            -ElementEnNew $elementsEnNew[$i] -ElementEnOld $elementsEnOld[$i] -ElementDe $elementsDe[$i] `
                            -RuleSetName $ruleSetName -FileName $fileName -Rule "$rule ($i)"
            }   
        }

        # Extra new line for better output
        Write-Host ""

        if ($false -eq $Config.DryRun) {
            $Helper.Save($xmlEnNew, "$($Config.FolderPathResult)\$fileName")
        }
    }

    # Extra new line for better output
    Write-Host ""
}