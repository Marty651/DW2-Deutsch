using module .\Worker.psm1

param([Worker]$Worker, $Config, $RuleSetsOld, $RuleSetsNew)

Write-Host -ForegroundColor Green "Starte Modus 3 - Der (neue) Hauptmodus."
Write-Host -ForegroundColor Green "Zusammenführung von Englisch Neu & Englisch Alt & Deutsch Alt"
Write-Host -ForegroundColor Green "(Automatische Übernahme bei neuen Versionen)"
Write-Host -ForegroundColor Green "Neue Version:"
Write-Host -ForegroundColor Green "- Mit Information zu Zeilennummern."
Write-Host -ForegroundColor Green "- Benötigt nur gleiche Struktur innerhalb einer Entität. Reihenfolge/Einschübe machen keine Probleme."
Write-Host -ForegroundColor Green "- Funktioniert mit den neuen Regeln (mit ID-Regel)."
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

function SetOne($ElementEnNew, $Text) 
{
   # Note: For some reason, even though "#text" is here available, it's sometimes not settable.
   $ElementEnNew.RemoveAll() | Out-Null
   $document = $ElementEnNew.OwnerDocument
   $textNode = $document.CreateTextNode($Text)
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

    SetOne -ElementEnNew $ElementEnNew -Text $translatedText
}

function ProcessOne($ElementEnNew, $ElementEnOld, $ElementDe, $RuleSetName, $FileName, $Rule)
{
    # See: https://learn.microsoft.com/en-us/powershell/scripting/learn/deep-dives/everything-about-null?view=powershell-7.4#simple-if-check
    $isNoXmlNodeFn = { param($xmlNode)
        if ($null -eq $xmlNode) {
            return $true
        }

        if ($xmlNode -is [System.Xml.XmlNodeList] -and $xmlNode.Count -eq 0) {
            return $true
        }

        if ($xmlNode -isnot [System.Xml.XmlNode] -and $xmlNode -isnot [System.Xml.XmlNodeList]) {
            return $true
        }

        return $false;
    }

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
    if ($isNoXmlNodeFn.Invoke($ElementEnOld)) {
        $Worker.Log(">>>>", "DarkCyan", $Config.MarkerNotYetTranslated, $RuleSetName, $FileName, $Rule, "Kein Element gefunden in 'Englisch Alt'.")
        MarkOne -ElementEnNew $ElementEnNew -Marker $Config.MarkerNotYetTranslated -ElementEnNewText $elementEnNewText -ElementEnOldText $null -ElementDeText $null
        TranslateOne -ElementEnNew $ElementEnNew -Text $elementEnNewText
        return
    }

    $elementEnOldText = ($ElementEnOld | Get-Member "#text" -MemberType Property) ? $ElementEnOld."#text" : $null

    # Old german node missing, so was never translated (should not happen but safety).
    if ($isNoXmlNodeFn.Invoke($ElementDe)) {
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
    SetOne -ElementEnNew $ElementEnNew -Text $elementDeText
}

### Main Program

foreach ($ruleSet in $RuleSetsNew) {
    $ruleSetName = $ruleSet.Name
    $fileNames = $ruleSet.Dateien
    $rules = $ruleSet.Regeln
    $idRule = $ruleSet.IdRegel

    Write-Host "> Starte Verarbeitung von Regelset: $ruleSetName (ID: $idRule)"

    # We allow file globs, this resolves them and returns an array of file names for the next steps.
    $fileNames = $Worker.ResolveFileGlobs($fileNames, $Config.FolderPathEnNew)

    if (($null -eq $fileNames) -or ($fileNames.Length -eq 0)) {
        $Worker.Log(">>", "DarkRed", $Config.MarkerNoFile, $ruleSetName, "", "", "Keine Datei für 'Englisch Neu' gefunden.")
        continue
    }

    foreach ($fileName in $fileNames) {
        Write-Host ">> Starte Verarbeitung von Datei (EN-Neu): $fileName"        

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

        Write-Debug ">>> Alle 3 Dateien vorhanden. Starte Suche von Entitäten anhand ID."
        
        $idElementsEnNew = $xmlEnNew.SelectNodes($idRule)
        $ids = $idElementsEnNew | ForEach-Object { $_."#text" }
        $idRuleTag = $idRule -split "/" | Select-Object -Last 1

        Write-Debug ">>> Gefundene Entitäten mit Tag $idRuleTag" 
        Write-Debug "IDs: $($ids -join ", ")"

        foreach ($id in $ids) {
            # https://stackoverflow.com/questions/1091945/what-characters-do-i-need-to-escape-in-xml-documents/46637835#46637835
            # https://stackoverflow.com/questions/37542773/how-to-use-apostrophe-in-xpath-while-finding-element-using-webdriver
            $rulePrefix = if ($id.Contains("'")) {
                $idRule -replace "/$idRuleTag", "[$idRuleTag=`"$id`"]"
            } else { 
                $idRule -replace "/$idRuleTag", "[$idRuleTag='$id']" 
            }

            foreach ($innerRule in $rules) {
                $rule = "$rulePrefix/$innerRule"
                $elementsEnNew = $xmlEnNew.SelectNodes($rule)
                $elementsEnOld = $xmlEnOld.SelectNodes($rule)
                $elementsDe = $xmlDe.SelectNodes($rule)
    
                $elementsEnNewCount = $elementsEnNew.Count
    
                if ($elementsEnNewCount -eq 0) {
                    $Worker.Log(">>>>", "DarkYellow", $Config.MarkerInvalid, $ruleSetName, $fileName, $rule, "Kein Element gefunden in 'Englisch Neu'.")
                    continue;
                } 

                $ruleInfo = $rule;

                try {
                    if ($elementsEnNewCount -eq 1) {
                        # TODO: ElementsNew is 1 but old is multiple so the array does not have #text!
                        # Must be checked!
                        ProcessOne  -ElementEnNew $elementsEnNew -ElementEnOld $elementsEnOld -ElementDe $elementsDe `
                                    -RuleSetName $ruleSetName -FileName $fileName -Rule $rule 
                        continue
                    }
        
                    for ($i = 0; $i -lt $elementsEnNewCount; $i++) {
                        $ruleInfo = "$rule ($i)"
                        ProcessOne  -ElementEnNew $elementsEnNew[$i] -ElementEnOld $elementsEnOld[$i] -ElementDe $elementsDe[$i] `
                                    -RuleSetName $ruleSetName -FileName $fileName -Rule "$rule ($i)"
                    }   
                }
                catch {
                    Write-Error ("Fehler in Regel $($ruleInfo): " + $_.Exception.Message + $_.InvocationInfo.PositionMessage)
                }
                
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


