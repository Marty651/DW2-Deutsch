# Notes / TODO: 
# - Dad needs the other program first -> check glossar (component def. + names of galactopedia files) against the "fließtexte" (galactopedia)
# - Is not checking empty content really good?
# - Comment nodes instead of text nodes & show both (all) at the same time?
# - Out-Of-Scope FN variable usage !
# - .txt-Dateien (GameText.txt)
# - Optional rules (no invalid but "not found"?)
# - German Config
# - Use XDocument or XPathNavigator for Line Numbers? 
# - - https://learn.microsoft.com/en-us/dotnet/standard/linq/xdocument-class-overview
# - - https://stackoverflow.com/questions/1542073/xdocument-or-xmldocument
# - - https://learn.microsoft.com/en-us/dotnet/standard/data/xml/insert-xml-data-using-xpathnavigator
# - - https://stackoverflow.com/questions/1504467/c-sharp-xml-read-write-xpath-without-using-xmldocument
# - https://stackoverflow.com/questions/42107851/how-to-implement-using-statement-in-powershell
# - Extra:
# - - https://scoop.sh/
# - - https://ohmyposh.dev/docs/installation/windows
# - - https://github.com/dahlbyk/posh-git
# - https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/set-strictmode?view=powershell-7.3

# References:
# - https://learn.microsoft.com/en-us/dotnet/standard/data/xml/saving-and-writing-a-document
# - https://adamtheautomator.com/powershell-classes/
# - https://github.com/pester/Pester

# << Erstes Programm - Zusammenführung von Englisch Neu <- Englisch Alt <- Deutsch Alt (Automatische Übernahme bei neuen Versionen). >>

### Global Setup ###

$ErrorActionPreference = "Stop"

# @{ ... }
$Config = . $PSScriptRoot\..\Konfiguration\Programm.ps1

# @{Name = "", Dateien = @(), Pfade = @()}
$RuleSets = . $Config.FilePathRuleSets

$global:Log = @("TYP; REGELSET; DATEI; PFAD; INFO");
$LogFn = {
    param($type, $ruleSet, $file, $rule, $info, $steps, $foregroundColor)

    Write-Host -ForegroundColor $foregroundColor "$steps $rule -> $type. $info"
    $global:Log += "$type; $ruleSet; $file; $rule; $info"
}

$LoadFn = {
    param($path)

    # The files contain unusual white space (comment on same line for example) and we want to preserve the original formatting.
    # Using [xml] doesn't do that.
    # See:
    # - https://stackoverflow.com/questions/53518785/save-xml-file-without-formatting
    # - https://stackoverflow.com/questions/29624215/using-c-sharp-xml-serializer-to-produce-custom-xml-format
    # - https://stackoverflow.com/questions/203528/what-is-the-simplest-way-to-get-indented-xml-with-line-breaks-from-xmldocument
    # - https://stackoverflow.com/questions/1555028/how-do-i-edit-xml-in-c-sharp-without-changing-format-spacing
    # - https://stackoverflow.com/questions/32149676/custom-xmlwriter-to-skip-a-certain-element

    $xml = New-Object System.Xml.XmlDocument
    $xml.PreserveWhitespace = $true
    $xml.Load($path)

    return $xml
}

$TranslateFn = {
    param($text)

    $params = @{
        auth_key = Get-Content $Config.FilePathDeeplKey
        text = $text
        target_lang = "DE"
    }
    $response = Invoke-RestMethod -Uri $Config.DeeplUrl -Method Post -Body $params
    return $response.translations.text
}

$ProcessFn = {
    param($elementNew, $elementOld, $elementDe, $path)

    if ($Config.DryRun) {
        Write-Host -ForegroundColor Magenta ">>>> $path"
        return
    }

    # Workaround: Some "empty" elements are not recognized as such, so we add a text node if it doesn't exist.
    # TODO: Maybe it's better to just ignore empty or throw a warning/error/invalid?
    if (!($elementNew | Get-Member "#text" -MemberType Property)) {
        $elementNew.AppendChild($xmlEnNew.CreateTextNode([String]::Empty)) | Out-Null
    }

    if ($null -eq $elementOld) {
        $LogFn.Invoke($Config.MarkerNotYetTranslated, $ruleSetName, $file, $path, "Kein Element gefunden in 'Englisch Alt'.", ">>>>", "DarkCyan")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNotYetTranslated + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $TranslateFn.Invoke($elementNew."#text") : $elementNew."#text")
        return
    }
    elseif ($elementOld.InnerText -ne $elementNew.InnerText) {
        $LogFn.Invoke($Config.MarkerOutdated, $ruleSetName, $file, $path, "Neuen Text in 'Englisch Neu' gefunden, der nicht genau gleich in 'Englisch Alt' existiert.", ">>>>", "DarkCyan")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerOutdated + $Config.MarkerPreAndPostFix + " " + $elementNew."#text"
        return
    }

    # Elements in EN_NEW and EN_OLD exist and text is equal!

    if ($null -eq $elementDe) {
        $LogFn.Invoke($Config.MarkerNotYetTranslated, $ruleSetName, $file, $path, "Kein Element gefunden in 'Deutsch Alt'.", ">>>>", "DarkCyan")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNotYetTranslated + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $TranslateFn.Invoke($elementNew."#text") : $elementNew."#text")
        return
    }
    elseif (($elementNew.InnerText -eq $elementDe.InnerText) -and ($elementNew.InnerText -ne [String]::Empty)) {
        $LogFn.Invoke($Config.MarkerNotYetTranslated, $ruleSetName, $file, $path, "Texte von 'Englisch Neu' bzw. 'Englisch Alt' stimmen mit dem Text in 'Deutsch Alt' überein.", ">>>>", "DarkCyan")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNotYetTranslated + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $TranslateFn.Invoke($elementNew."#text") : $elementNew."#text")
        return
    }
        
    # Element in EN_NEW exists and is the same as in EN_OLD and not the same as in DE!
    if ($Config.ShowGreen) {
        Write-Host -ForegroundColor DarkGreen ">>>> $path -> Fertig, bereits übersetzt."
    }
    
    $elementNew."#text" = $elementDe."#text"
}

### Main Program ###

Write-Host -ForegroundColor Green "Starte mit Konfiguration:"
$Config | Out-Host

if ($Config.DebugOnlyRulesets.Count -gt 0) {
    $RuleSets = $RuleSets | Where-Object { $Config.DebugOnlyRulesets -contains $_.Name }
    Write-Host -ForegroundColor Yellow "Debug-Modus: Es werden nur die Regelsets verarbeitet, die in der Konfiguration unter 'DebugOnlyRulesets' angegeben sind:"
    $RuleSets.Name
    Write-Host ""
}

foreach ($ruleSet in $RuleSets) {
    $ruleSetName = $ruleSet.Name
    $fileNames = $ruleSet.Dateien
    $paths = $ruleSet.Pfade
    Write-Host "> Starte Verarbeitung von Regelset: $ruleSetName"

    # We allow file globs, this resolves them and returns an array of file names for the next steps.
    $files = $fileNames | % { Get-Item "$($Config.FolderPathEnNew)\$_" -ErrorAction SilentlyContinue } | Select-Object -ExpandProperty Name

    if ($files.Count -eq 0) {
        $LogFn.Invoke($Config.MarkerInvalid, $ruleSetName, "", "", "Keine Datei für 'Englisch Neu' gefunden.", ">>>", "Red")
        continue
    }

    foreach ($file in $files) {
        Write-Host ">> Starte Verarbeitung von Datei: $file"        

        $xmlEnNew = $LoadFn.Invoke("$($Config.FolderPathEnNew)\$file")
        if ($null -eq $xmlEnNew) {
            $LogFn.Invoke($Config.MarkerInvalid, $ruleSetName, $file, "", "Datei 'Englisch Neu' konnte nicht geladen werden.", ">>>", "Red")
            continue
        }

        $xmlEnOld = $LoadFn.Invoke("$($Config.FolderPathEnOld)\$file")
        if ($null -eq $xmlEnOld) {
            Write-Host ">>> $($Config.MarkerInvalid). Datei $($Config.FolderPathEnOld)\$file nicht gefunden."
            $LogFn.Invoke($Config.MarkerInvalid, $ruleSetName, $file, "", "Datei 'Englisch Alt' konnte nicht gefunden/geladen werden.", ">>>", "Red")
            continue
        }

        $xmlDe = $LoadFn.Invoke("$($Config.FolderPathDe)\$file")
        if ($null -eq $xmlDe) {
            Write-Host ">>> $($Config.MarkerInvalid). Datei $($Config.FolderPathDe)\$file nicht gefunden."
            $LogFn.Invoke($Config.MarkerInvalid, $ruleSetName, $file, "", "Datei 'Deutsch Alt' konnte nicht gefunden/geladen werden.", ">>>", "Red")
            continue
        }

        Write-Host ">>> Alle 3 Dateien vorhanden. Starte Verarbeitung von Regeln."

        foreach ($path in $paths) {
            $elementsNew = $xmlEnNew.SelectNodes($path);
            $elementsOld = $xmlEnOld.SelectNodes($path);
            $elementsDe = $xmlDe.SelectNodes($path);

            $elementsNewCount = $elementsNew.Count

            if ($elementsNewCount -eq 0) {
                $LogFn.Invoke($Config.MarkerInvalid, $ruleSetName, $file, $path, "Kein Element gefunden in 'Englisch Neu'.", ">>>>", "DarkYellow")
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

if ($false -eq $Config.DryRun) {
    $log | Out-File -FilePath  $Config.FilePathLog -Encoding utf8BOM -Force
}