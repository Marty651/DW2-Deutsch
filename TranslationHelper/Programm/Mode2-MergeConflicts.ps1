# << Drittes Programm - Zusammenführung von mehreren zeitgleichen Änderungen einer Datei (Aufzeigen von Konflikten). >>
# - Expects the structure to be identical
# - 2 Files -> One MASTER one (slave) -> Check master for rules and if slave different -> MARKER

<#
    Modus 2: Zusammenführung von mehreren zeitgleichen Änderungen einer Datei (Aufzeigen von Konflikten).
    -> Das kann zum Beispiel verwendet werden, wenn rxnnxs und frankycl an der gleichen Datei (versehentlich) arbeiten.
#>

# Write-Host -ForegroundColor Green "Starte Modus 2 - Zusammenführung von mehreren zeitgleichen Änderungen einer Datei (Aufzeigen von Konflikten)."



### Global Setup ###

# @{ ... }
$Config = @{
    DryRun = $false
    ShowGreen = $false

    MarkerPreAndPostFix = "#####"
    MarkerConflict = "KONFLIKT"

    FolderPathFirst = "$PSScriptRoot\1 Englisch Neu"
    FolderPathSecond = "$PSScriptRoot\2 Englisch Alt"

    FolderPathResult = "$PSScriptRoot\4 Deutsch Neu (Ergebnis)"
    FilePathLog = "$PSScriptRoot\Logs\Prototyp.2.Log.$(Get-Date -Format "yyyy-MM-dd_hh-mm-ss").csv"
}

$global:Log = @("TYP; DATEI; INFO");
$LogFn = {
    param($type, $file, $info, $steps, $foregroundColor)

    Write-Host -ForegroundColor $foregroundColor "$steps $type. $info"
    $global:Log += "$type; $file; $info"
};

$ProcessFn = {
    param($elementFirst, $elementSecond)

    if ($Config.DryRun) {
        Write-Host -ForegroundColor Magenta ">>>> OK"
        return
    }

    # Workaround: Some "empty" elements are not recognized as such, so we add a text node if it doesn't exist.
    # TODO: Maybe it's better to just ignore empty or throw a warning/error/invalid?
    if (!($elementFirst | Get-Member "#text" -MemberType Property)) {
        $elementFirst.AppendChild($xmlEnNew.CreateTextNode([String]::Empty)) | Out-Null
    }

    if (($elementNew.InnerText -eq $elementDe.InnerText) -and ($elementNew.InnerText -ne [String]::Empty)) {
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

foreach ($ruleSet in $RuleSetsOld) {
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