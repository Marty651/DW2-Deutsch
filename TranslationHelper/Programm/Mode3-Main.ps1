using module .\Worker.psm1

param([Worker]$Worker, $Config, $RuleSets)

Write-Host -ForegroundColor Green "Starte Modus 3 - Der Hauptmodus."
Write-Host -ForegroundColor Green "Zusammenführung von Englisch Neu & Englisch Alt & Deutsch Alt"
Write-Host -ForegroundColor Green "(Automatische Übernahme bei neuen Versionen)"
Write-Host

### Functions

function MarkOne($ElementEnNew, $Marker, $ElementEnNewText, $ElementEnOldText, $ElementDeText) 
{
    $text = "Typ: $($Config.MarkerPreAndPostFix)$Marker$($Config.MarkerPreAndPostFix)"

    if ($null -ne $ElementEnNewText) {
        $text += [Environment]::NewLine + [Environment]::NewLine + "Englisch Neu:" + [Environment]::NewLine + $ElementEnNewText + [Environment]::NewLine + " - - - - - "
    }

    if ($null -ne $ElementEnOldText) {
        $text += [Environment]::NewLine + [Environment]::NewLine + "Englisch Alt:" + [Environment]::NewLine + $ElementEnOldText + [Environment]::NewLine + " - - - - - "
    }

    if ($null -ne $ElementDeText) {
        $text += [Environment]::NewLine + [Environment]::NewLine + "Deutsch Alt:" + [Environment]::NewLine + $ElementDeText + [Environment]::NewLine + " - - - - - "
    }

    $document = $ElementEnNew.OwnerDocument

    $comment = $document.CreateComment($text)
    $ws = $document.CreateWhitespace("`r`n")

    $ElementEnNew.ParentNode.InsertAfter($ws, $ElementEnNew.PreviousSibling.PreviousSibling) | Out-Null
    $ElementEnNew.ParentNode.InsertAfter($comment, $ElementEnNew.PreviousSibling.PreviousSibling) | Out-Null
}

function SetOne($ElementEnNew, $text) 
{
   # Note: For some reason, even though "#text" is here available, it's sometimes not settable.
   $ElementEnNew.RemoveAll() | Out-Null
   $document = $ElementEnNew.OwnerDocument
   $textNode = $document.CreateTextNode($text)
   $ElementEnNew.AppendChild($textNode) | Out-Null
}

function TranslateOne($ElementEnNew, $Text) 
{
    if ($Config.Deepl.Enabled -eq $false) { return }

    $wordCount = ($Text -split " ").Length
    if ($wordCount -lt $Config.Deepl.MinWords) { return }

    if ($Config.Deepl.ShowGreen) {
        Write-Host -ForegroundColor DarkGreen ">>>> $Rule -> Übersetze Text [$wordCount Wörter] mit Deepl:"
    }

    $translatedText =  $Worker.Translate($Text)

    if ($Config.Deepl.ShowGreen) {
        Write-Host -ForegroundColor DarkGreen ">>>>> $translatedText"
    }    

    SetOne -ElementEnNew $ElementEnNew -text $translatedText
}

function ProcessOne($ElementEnNew, $ElementEnOld, $ElementDe, $RuleSetName, $FileName, $Rule)
{
    if ($Config.DryRun) {
        Write-Host -ForegroundColor Magenta ">>>> $Rule"
        return
    }

    $elementEnNewText = ($ElementEnNew | Get-Member "#text" -MemberType Property) ? $ElementEnNew."#text" : $null

    if ($null -eq $elementEnNewText) {
        if ($Config.ShowGreen) {
            Write-Host -ForegroundColor DarkGreen ">>>> $Rule -> Fertig, kein Text nötig."
        }
        return
    }

    # Old english node missing, so was new and thus never german translated.
    if ($null -eq $ElementEnOld) {
        $Worker.Log(">>>>", "DarkCyan", $Config.MarkerNotYetTranslated, $RuleSetName, $FileName, $Rule, "Kein Element gefunden in 'Englisch Alt'.")
        MarkOne -ElementEnNew $ElementEnNew -Marker $Config.MarkerNotYetTranslated -ElementEnNewText $elementEnNewText -ElementEnOldText $null -ElementDeText $null
        TranslateOne -ElementEnNew $ElementEnNew -Text $elementEnNewText
        return
    }

    $elementEnOldText = ($ElementEnOld | Get-Member "#text" -MemberType Property) ? $ElementEnOld."#text" : $null

    # Old german node missing, so was never translated (should not happen but safety).
    if ($null -eq $ElementDe) {
        $Worker.Log(">>>>", "DarkCyan", $Config.MarkerNotYetTranslated, $RuleSetName, $FileName, $Rule, "Kein Element gefunden in 'Deutsch Alt'.")
        MarkOne -ElementEnNew $ElementEnNew -Marker $Config.MarkerNotYetTranslated -ElementEnNewText $elementEnNewText -ElementEnOldText $elementEnOldText -ElementDeText $null
        TranslateOne -ElementEnNew $ElementEnNew -Text $elementEnNewText
        return
    }    

    $elementDeText = ($ElementDe | Get-Member "#text" -MemberType Property) ? $ElementDe."#text" : $null

    # Old english and new english nodes are not the same -> Outdated.
    if ($elementEnOldText -ne $elementEnNewText) {
        $Worker.Log(">>>>", "DarkCyan", $Config.MarkerOutdated, $RuleSetName, $FileName, $Rule, "Neuen Text in 'Englisch Neu' gefunden, der nicht genau gleich in 'Englisch Alt' existiert.")
        MarkOne -ElementEnNew $ElementEnNew -Marker $Config.MarkerOutdated -ElementEnNewText $elementEnNewText -ElementEnOldText $elementEnOldText -ElementDeText $elementDeText
        TranslateOne -ElementEnNew $ElementEnNew -Text $elementEnNewText
        return
    }

    # Old english and new english nodes are the same, but the old german node is also the same -> No difference (still english), probably not translated.
    if ($elementDeText -eq $elementEnNewText) {
        $Worker.Log(">>>>", "DarkCyan", $Config.MarkerNoDifference, $RuleSetName, $FileName, $Rule, "Texte von 'Englisch Neu' bzw. 'Englisch Alt' stimmen mit dem Text in 'Deutsch Alt' überein.")
        MarkOne -ElementEnNew $ElementEnNew -Marker $Config.MarkerNoDifference -ElementEnNewText $elementEnNewText -ElementEnOldText $elementEnOldText -ElementDeText $elementDeText
        TranslateOne -ElementEnNew $ElementEnNew -Text $elementEnNewText
        return
    }

    if ($Config.ShowGreen) {
        Write-Host -ForegroundColor DarkGreen ">>>> $Rule -> Fertig, bereits übersetzt."
        Write-Host -ForegroundColor Green $elementDeText
    }
    
    # Directly use already translated text.
    SetOne -ElementEnNew $ElementEnNew -ElementDeText $elementDeText
}

### Main Program

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