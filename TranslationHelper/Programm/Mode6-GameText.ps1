using module .\Worker.psm1

param([Worker]$Worker, $Config, $RuleSets)

Write-Host -ForegroundColor Green "Starte Modus 6 - GameText Übersetzung mit Deepl."
Write-Host

$file = $Worker.ResolvePath($Config.Mode6.FilePathIn)
Write-Host "Lese $file ein."
$content = Get-Content $file
$lines = $content.Length
Write-Host "Eingelesen. Zeilen: $lines"

$contentToProcess = $content | select -Skip $Config.Mode6.Skip -First $Config.Mode6.First
$length = $contentToProcess.Length

Write-Host "Verarbeite $length Zeilen. $($Config.Mode6.Skip) übersprungen, auf $($Config.Mode6.First) beschränkt."

for ($l = 0; $l -lt $length; $l++) {
    $line = $contentToProcess[$l]

    Write-Host "> Verarbeite: $line"

    if ($line.Contains(";") -eq $false) {
        Write-Host ">> Kein ';', wird übersprungen."
        continue
    }

    $parts = $line -split ";"

    if ($parts.Length -ne 2) {
        Write-Host ">> Keine 2 Teile gefunden, wird übersprungen."
        continue
    }

    $left = $parts[0]
    $right = $parts[1]

    if ($right.Length -le 0) {
        Write-Host ">> Rechts kein Text, wird übersprungen."
        continue
    }

    if ($Config.Deepl.Enabled -eq $false) { 
        $contentToProcess[$l] = $line.Replace(";$right", ";Hier würde die Übersetzung stehen, wenn Deepl an wäre :)")
        continue 
    }

    $wordCount = ($right -split " ").Length
    if ($wordCount -lt $Config.Deepl.MinWords) { 
        Write-Host ">> Zu übersetzender Text ist weniger als die Minimalgrenze von $($Config.Deepl.MinWords), wird übersprungen."
        continue
    }

    $translated = $Worker.Translate($right)

    $contentToProcess[$l] = $line.Replace(";$right", ";$translated")
    Write-Host -ForegroundColor Green ">> Übersetz: $translated"
}

if ($false -eq $Config.DryRun) {
    Write-Host -ForegroundColor DarkYellow "Speichere"
    $file = $Worker.ResolvePath($Config.Mode6.FilePathOut)
    Set-Content -Path $file -Value $contentToProcess
}