# Notes / TODO: 
# - Dad needs the other program first -> check glossar (component def. + names of galactopedia files) against the "fließtexte" (galactopedia)
# - Second Program: 2 Level -> First compare structure (scan) -> Log+Marker -> THEN -> Second compare content (EN->EN->DE) -> Log+Marker
# - Third Program: Compare just 2 files and only show conflicts
# - Is not checking empty content really good?
# - Comment nodes instead of text nodes & show both (all) at the same time?

### Global Setup ###

# @{ ... }
$Config = . ".\Konfiguration\Config.ps1"

# @{Name = "", Files = @(), Rules = @()}
$RuleSets = . $Config.FilePathRuleSets

$global:Log = @("TYP; REGELSET; DATEI; REGEL; INFO");
$LogFn = {
    param($type, $ruleSet, $file, $rule, $info, $steps, $foregroundColor)

    Write-Host -ForegroundColor $foregroundColor "$steps $rule -> $type. $info"
    $global:Log += "$type; $ruleSet; $file; $rule; $info"
};

$TranslateFn = {
    param($text)

    $params = @{
        auth_key = Get-Content $Config.FilePathDeeplKey
        text = $text
        target_lang = "DE"
    }
    $response = Invoke-RestMethod -Uri $Config.DeeplUrl -Method Post -Body $params
    return $response.translations.text
};

$ProcessFn = {
    param($elementNew, $elementOld, $elementDe, $ruleInfo)

    if ($Config.DryRun) {
        Write-Host -ForegroundColor Magenta ">>>> $ruleInfo"
        return
    }

    # Workaround: Some "empty" elements are not recognized as such, so we add a text node if it doesn't exist.
    # TODO: Maybe it's better to just ignore empty or throw a warning/error/invalid?
    if (!($elementNew | Get-Member "#text" -MemberType Property)) {
        $elementNew.AppendChild($xmlEnNew.CreateTextNode([String]::Empty)) | Out-Null
    }

    if ($null -eq $elementOld) {
        $LogFn.Invoke($Config.MarkerNotYetTranslated, $name, $file, $ruleInfo, "Kein Element gefunden in 'Englisch Alt'.", ">>>>", "DarkCyan")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNotYetTranslated + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $TranslateFn.Invoke($elementNew."#text") : $elementNew."#text")
        return
    }
    elseif ($elementOld.InnerText -ne $elementNew.InnerText) {
        $LogFn.Invoke($Config.MarkerOutdated, $name, $file, $ruleInfo, "Neuen Text in 'Englisch Neu' gefunden, der nicht genau gleich in 'Englisch Alt' existiert.", ">>>>", "DarkCyan")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerOutdated + $Config.MarkerPreAndPostFix + " " + $elementNew."#text"
        return
    }

    # Elements in EN_NEW and EN_OLD exist and text is equal!

    if ($null -eq $elementDe) {
        $LogFn.Invoke($Config.MarkerNotYetTranslated, $name, $file, $ruleInfo, "Kein Element gefunden in 'Deutsch Alt'.", ">>>>", "DarkCyan")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNotYetTranslated + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $TranslateFn.Invoke($elementNew."#text") : $elementNew."#text")
        return
    }
    elseif (($elementNew.InnerText -eq $elementDe.InnerText) -and ($elementNew.InnerText -ne [String]::Empty)) {
        $LogFn.Invoke($Config.MarkerNotYetTranslated, $name, $file, $ruleInfo, "Texte von 'Englisch Neu' bzw. 'Englisch Alt' stimmen mit dem Text in 'Deutsch Alt' überein.", ">>>>", "DarkCyan")
        $elementNew."#text" = $Config.MarkerPreAndPostFix + $Config.MarkerNotYetTranslated + $Config.MarkerPreAndPostFix + " " + ($Config.UseDeepl ? $TranslateFn.Invoke($elementNew."#text") : $elementNew."#text")
        return
    }
        
    # Element in EN_NEW exists and is the same as in EN_OLD and not the same as in DE!
    if ($Config.ShowGreen) {
        Write-Host -ForegroundColor DarkGreen ">>>> $ruleInfo -> Fertig, bereits übersetzt."
    }
    
    $elementNew."#text" = $elementDe."#text"
}

### Main Program ###

Write-Host -ForegroundColor Green "Starting with configuration:"
$Config | Select-Object -Property UseDeepl, ShowGreen, DryRun | Format-List

foreach ($ruleSet in $RuleSets) {
    $name = $ruleSet.Name
    $files = $ruleSet.Files
    $rules = $ruleSet.Rules
    Write-Host "> Starte Verarbeitung von Regelset: $name"

    foreach ($file in $files) {
        Write-Host ">> Starte Verarbeitung von Datei: $($Config.FolderPathEnNew)\$file"        

        $xmlEnNew = [xml](Get-Content "$($Config.FolderPathEnNew)\$file" -Encoding UTF8);
        if ($null -eq $xmlEnNew) {
            $LogFn.Invoke($Config.MarkerInvalid, $name, $file, "", "Datei 'Englisch Neu' nicht gefunden.", ">>>", "Red")
            continue
        }

        $xmlEnOld = [xml](Get-Content "$($Config.FolderPathEnOld)\$file" -Encoding UTF8);
        if ($null -eq $xmlEnOld) {
            Write-Host ">>> $($Config.MarkerInvalid). Datei $($Config.FolderPathEnOld)\$file nicht gefunden."
            $LogFn.Invoke($Config.MarkerInvalid, $name, $file, "", "Datei 'Englisch Alt' nicht gefunden.", ">>>", "Red")
            continue
        }

        $xmlDe = [xml](Get-Content "$($Config.FolderPathDe)\$file" -Encoding UTF8);
        if ($null -eq $xmlDe) {
            Write-Host ">>> $($Config.MarkerInvalid). Datei $($Config.FolderPathDe)\$file nicht gefunden."
            $LogFn.Invoke($Config.MarkerInvalid, $name, $file, "", "Datei 'Deutsch Alt' nicht gefunden.", ">>>", "Red")
            continue
        }

        Write-Host ">>> Alle 3 Dateien vorhanden. Starte Verarbeitung von Regeln."

        foreach ($rule in $rules) {
            $elementsNew = $xmlEnNew.SelectNodes($rule);
            $elementsOld = $xmlEnOld.SelectNodes($rule);
            $elementsDe = $xmlDe.SelectNodes($rule);

            $elementsNewCount = $elementsNew.Count

            if ($elementsNewCount -eq 0) {
                $LogFn.Invoke($Config.MarkerInvalid, $name, $file, $rule, "Kein Element gefunden in 'Englisch Neu'.", ">>>>", "DarkYellow")
                continue;
            } 

            if ($elementsNewCount -eq 1) {
                $ProcessFn.Invoke($elementsNew[0], $elementsOld[0], $elementsDe[0], $rule)
                continue
            }

            for ($i = 0; $i -lt $elementsNewCount; $i++) {
                $ProcessFn.Invoke($elementsNew[$i], $elementsOld[$i], $elementsDe[$i], "$rule ($i)")
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