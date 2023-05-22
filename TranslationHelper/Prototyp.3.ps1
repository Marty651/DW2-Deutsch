# << Viertes Programm - Prüfung von Strukturänderungen einer Datei (Neu VS Alt). >>
# First compare structure (scan)

### Global Setup ###

# @{ ... }
$Config = @{
    ShowGreen = $false

    MarkerPreAndPostFix = "_____"
    MarkerNew = "NEU"
    MarkerDifferent = "UNTERSCHIEDLICH"
    MarkerInvalid = "UNGÜLTIG"

    FilePathRuleSets = "$PSScriptRoot\Konfiguration\Regeln.ps1"

    FolderPathEnNew = "$PSScriptRoot\1 Englisch Neu"
    FolderPathEnOld = "$PSScriptRoot\2 Englisch Alt"

    FolderPathResult = "$PSScriptRoot\4 Deutsch Neu (Ergebnis)"
    FilePathLog = "$PSScriptRoot\Logs\$($MyInvocation.MyCommand.Name).Log.$(Get-Date -Format "yyyy-MM-dd_hh-mm-ss").csv"
}

# @{Name = "", Files = @(), Rules = @()}
$RuleSets = . $Config.FilePathRuleSets

$global:Log = @("TYP; REGELSET; DATEI; REGEL; INFO");
$LogFn = {
    param($type, $ruleSet, $file, $rule, $info, $steps, $foregroundColor)

    Write-Host -ForegroundColor $foregroundColor "$steps $rule -> $type. $info"
    $global:Log += "$type; $ruleSet; $file; $rule; $info"
}

$ProcessTraversingFn = {
    param($elementNew, $elementOld, $path)

    if ($null -eq $elementOld) {
        $LogFn.Invoke($Config.MarkerNew, $name, $file, $path, "Kein Element gefunden in 'Englisch Alt'.", ">>>>", "DarkCyan")
        $elementNew.SetAttribute($Config.MarkerNew, "yes")
        return $false
    }

    if ($elementNew.ToString() -ne $elementOld.ToString()) {
        $LogFn.Invoke($Config.MarkerDifferent, $name, $file, $path, "Es wurde ein Element mit anderem Namen [$($elementOld.ToString())] gefunden in 'Englisch Alt'.", ">>>>", "DarkCyan")
        $elementNew.SetAttribute($Config.MarkerDifferent, "yes")
        return $false
    }

    $childrenNew = $elementNew.ChildNodes
    $childrenOld = $elementOld.ChildNodes

    for ($i = 0; $i -lt $childrenNew.Count; $i++) {
        $same = $ProcessTraversingFn.Invoke($childrenNew[$i], $childrenOld[$i], "$path[$($i+1)]/$($childrenNew[$i].ToString())")
        if ($false -eq $same) {
            break
        }
    }

    # Element in EN_NEW exists and is the same as in EN_OLD and not the same as in DE!
    if ($Config.ShowGreen) {
        Write-Host -ForegroundColor DarkGreen ">>>> $path -> OK."
    }

    return $true
}

### Main Program ###

Write-Host -ForegroundColor Green "Starting $($MyInvocation.MyCommand.Name) with configuration:"
$Config | Select-Object -Property ShowGreen | Format-List

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

        if ($false -eq $Config.DryRun) {
            $xmlEnNew.Save("$($Config.FolderPathResult)\$file")
        }
    }
    Write-Host ""
}

if ($false -eq $Config.DryRun) {
    $log | Out-File -FilePath  $Config.FilePathLog -Encoding utf8BOM -Force
}