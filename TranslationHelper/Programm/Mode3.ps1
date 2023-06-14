<#
    Modus 3: (Der Hauptmodus) 
    Zusammenführung von 
    Englisch Neu & Englisch Alt & Deutsch Alt 
    (Automatische Übernahme bei neuen Versionen)
#>

param($LogFn, $LoadFn, $TranslateFn, $Config, $RuleSets)

$ProcessFn = {
    param($elementNew, $elementOld, $elementDe, $rule)

    if ($Config.DryRun) {
        Write-Host -ForegroundColor Magenta ">>>> $rule"
        return
    }

    # Workaround: Some "empty" elements are not recognized as such, so we add a text node if it doesn't exist.
    # TODO: Maybe it's better to just ignore empty or throw a warning/error/invalid?
    if (!($elementNew | Get-Member "#text" -MemberType Property)) {
        $elementNew.AppendChild($xmlEnNew.CreateTextNode([String]::Empty)) | Out-Null
    }

    if ($null -eq $elementOld) {
        $LogFn.Invoke(">>>>", "DarkCyan", $Config.MarkerNotYetTranslated, $ruleSetName, $file, $rule, "Kein Element gefunden in 'Englisch Alt'.")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNotYetTranslated + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $TranslateFn.Invoke($elementNew."#text") : $elementNew."#text")
        return
    }
    elseif ($elementOld.InnerText -ne $elementNew.InnerText) {
        $LogFn.Invoke(">>>>", "DarkCyan", $Config.MarkerOutdated, $ruleSetName, $file, $rule, "Neuen Text in 'Englisch Neu' gefunden, der nicht genau gleich in 'Englisch Alt' existiert.")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerOutdated + $Config.MarkerPreAndPostFix + " " + $elementNew."#text"
        return
    }

    # Elements in EN_NEW and EN_OLD exist and text is equal!

    if ($null -eq $elementDe) {
        $LogFn.Invoke(">>>>", "DarkCyan", $Config.MarkerNotYetTranslated, $ruleSetName, $file, $rule, "Kein Element gefunden in 'Deutsch Alt'.")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNotYetTranslated + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $TranslateFn.Invoke($elementNew."#text") : $elementNew."#text")
        return
    }
    elseif (($elementNew.InnerText -eq $elementDe.InnerText) -and ($elementNew.InnerText -ne [String]::Empty)) {
        $LogFn.Invoke(">>>>", "DarkCyan", $Config.MarkerNoDifference, $ruleSetName, $file, $rule, "Texte von 'Englisch Neu' bzw. 'Englisch Alt' stimmen mit dem Text in 'Deutsch Alt' überein.")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNoDifference + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $TranslateFn.Invoke($elementNew."#text") : $elementNew."#text")
        return
    }
        
    # Element in EN_NEW exists and is the same as in EN_OLD and not the same as in DE!
    if ($Config.ShowGreen) {
        Write-Host -ForegroundColor DarkGreen ">>>> $rule -> Fertig, bereits übersetzt."
    }
    
    $elementNew."#text" = $elementDe."#text"
}

### Main Program ###

foreach ($ruleSet in $RuleSets) {
    $ruleSetName = $ruleSet.Name
    $fileNames = $ruleSet.Dateien
    $paths = $ruleSet.Pfade
    Write-Host "> Starte Verarbeitung von Regelset: $ruleSetName"

    # We allow file globs, this resolves them and returns an array of file names for the next steps.
    $files = $fileNames | % { Get-Item "$($Config.FolderPathEnNew)\$_" -ErrorAction SilentlyContinue } | Select-Object -ExpandProperty Name

    if ($files.Count -eq 0) {
        $LogFn.Invoke(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, "", "", "Keine Datei für 'Englisch Neu' gefunden.")
        continue
    }

    foreach ($file in $files) {
        Write-Host ">> Starte Verarbeitung von Datei: $file"        

        $xmlEnNew = $LoadFn.Invoke("$($Config.FolderPathEnNew)\$file")
        if ($false -eq $xmlEnNew) {
            $LogFn.Invoke(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, $file, "", "Datei 'Englisch Neu' konnte nicht geladen werden.")
            continue
        }

        $xmlEnOld = $LoadFn.Invoke("$($Config.FolderPathEnOld)\$file")
        if ($false -eq $xmlEnOld) {
            $LogFn.Invoke(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, $file, "", "Datei 'Englisch Alt' konnte nicht gefunden/geladen werden.")
            continue
        }

        $xmlDe = $LoadFn.Invoke("$($Config.FolderPathDe)\$file")
        if ($false -eq $xmlDe) {
            $LogFn.Invoke(">>>", "Red", $Config.MarkerInvalid, $ruleSetName, $file, "", "Datei 'Deutsch Alt' konnte nicht gefunden/geladen werden.")
            continue
        }

        Write-Host ">>> Alle 3 Dateien vorhanden. Starte Verarbeitung von Regeln."

        foreach ($path in $paths) {
            $elementsNew = $xmlEnNew.SelectNodes($path);
            $elementsOld = $xmlEnOld.SelectNodes($path);
            $elementsDe = $xmlDe.SelectNodes($path);

            $elementsNewCount = $elementsNew.Count

            if ($elementsNewCount -eq 0) {
                $LogFn.Invoke(">>>>", "DarkYellow", $Config.MarkerInvalid, $ruleSetName, $file, $path, "Kein Element gefunden in 'Englisch Neu'.")
                continue;
            } 

            if ($elementsNewCount -eq 1) {
                $ProcessFn.Invoke($elementsNew, $elementsOld, $elementsDe, $path)
                continue
            }

            for ($i = 0; $i -lt $elementsNewCount; $i++) {
                $ProcessFn.Invoke($elementsNew[$i], $elementsOld[$i], $elementsDe[$i], "$path ($i)")
            }   
        }

        Write-Host ""

        if ($false -eq $Config.DryRun) {
            $xmlEnNew.Save("$($Config.FolderPathResult)\$file")
        }
    }
    Write-Host ""
}