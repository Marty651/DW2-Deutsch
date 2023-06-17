param($Helper, $Config, $RuleSets)

### Functions

$ProcessTraversingFn = {
    param($elementNew, $elementOld, $rule)

    if ($null -eq $elementOld) {
        $LogFn.Invoke(">>>>", "DarkCyan", $Config.MarkerNew, $name, $file, $rule, "Kein Element gefunden in 'Englisch Alt'.")
        $elementNew.SetAttribute($Config.MarkerNew, "yes")
        return $false
    }

    if ($elementNew.ToString() -ne $elementOld.ToString()) {
        $LogFn.Invoke(">>>>", "DarkCyan", $Config.MarkerDifferent, $name, $file, $rule, "Es wurde ein Element mit anderem Namen [$($elementOld.ToString())] gefunden in 'Englisch Alt'.")
        $elementNew.SetAttribute($Config.MarkerDifferent, "yes")
        return $false
    }

    $childrenNew = $elementNew.ChildNodes
    $childrenOld = $elementOld.ChildNodes

    for ($i = 0; $i -lt $childrenNew.Count; $i++) {
        $same = $ProcessTraversingFn.Invoke($childrenNew[$i], $childrenOld[$i], "$rule[$($i+1)]/$($childrenNew[$i].ToString())")
        if ($false -eq $same) {
            break
        }
    }

    # Element in EN_NEW exists and is the same as in EN_OLD and not the same as in DE!
    if ($Config.ShowGreen) {
        Write-Host -ForegroundColor DarkGreen ">>>> $rule -> OK."
    }

    return $true
}

### Main Program

Write-Host -ForegroundColor Green "Starte Modus 1 - Prüfung von Strukturänderungen einer Datei (Neu VS Alt)"
# Write-Host -ForegroundColor Green "Starte Modus 2 - Zusammenführung von mehreren zeitgleichen Änderungen einer Datei (Aufzeigen von Konflikten)."

# Write-Host -ForegroundColor Green "Starte Hilfsmodus 11 - Prüfung der richtigen Verwendung der GameEvent Namen"

foreach ($ruleSet in $RuleSets) {
    $name = $ruleSet.Name
    $files = $ruleSet.Files
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

        Write-Host ">>> Alle 2 Dateien vorhanden. Starte Verarbeitung."

        $elementNew = $xmlEnNew.SelectSingleNode("/*[1]");
        $elementOld = $xmlEnOld.SelectSingleNode("/*[1]");
        
        $ProcessTraversingFn.Invoke($elementNew, $elementOld, "/$($elementNew.ToString())") | Out-Null

        Write-Host ""

        $xmlEnNew.Save("$($Config.FolderPathResult)\$file")
    }
    Write-Host ""
}

if ($false -eq $Config.DryRun) {
    $log | Out-File -FilePath  $Config.FilePathLog -Encoding utf8BOM -Force
}