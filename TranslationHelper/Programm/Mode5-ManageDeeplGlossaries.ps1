using module .\Worker.psm1

param([Worker]$Worker, $Config, $RuleSets)

Write-Host -ForegroundColor Green "Starte Modus 5 - Interaktive Glossarverwaltung."
Write-Host

### Functions

### Main Program

Write-Host -ForegroundColor Green "Was darf es sein?"
Write-Host -ForeGroundColor Green "1. Alle Glossare anzeigen"
Write-Host -ForeGroundColor Green "2. Glossar hinzufügen"
Write-Host -ForeGroundColor Green "3. Glossar löschen"
Write-Host -ForegroundColor Green "4. Glossar testen"
Write-Host -ForegroundColor Green "5. Abbrechen"
Write-Host -ForegroundColor Green "(Keine Eingabe = Abbruch)"
Write-Host

$choice = Read-Host "Meine Wahl"

# Cancel if no option was chosen.
if ($choice -notin "1", "2", "3", "4", "5") {
    Write-Host -ForegroundColor DarkYellow "Keine Eingabe. Abbruch."
    return
}

if ($choice -eq "1") {
    Write-Host -ForegroundColor Green "Okay, folgend alle verfügbaren Glossare."

    # https://www.deepl.com/de/docs-api/glossaries/list-glossaries
    $url = $Config.Deepl.Url.TrimEnd("/") + "/glossaries"

    $headers = @{
        Authorization = "DeepL-Auth-Key " + (Get-Content $Config.Deepl.KeyFilePath)
    }

    $params = @{ }

    if ($Worker.IsDebug()) {
        Write-Host -ForegroundColor Yellow "HTTP Request: $url"
        $headers | Out-Host
        $params | Out-Host
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method GET -Body $params
        if ($Worker.IsDebug()) {
            Write-Host -ForegroundColor Yellow "HTTP Response: $url"
            $response | Out-Host
        }

        Write-Host ($response | ConvertTo-Json)
    }
    catch {
        Write-Host -ForegroundColor Red ("ERROR: " + $_.Exception.Message)
    }
    
    return
}

if ($choice -eq "2") {
    Write-Host -ForegroundColor Green "Okay, folgend erstellen wir ein neues Glossar anhand der CSV-Datei."
    Write-Host "CSV-Datei: " $Config.Deepl.GlossaryFilePath
    Write-Host

    $name = Read-Host "Gib dem Glossar einen Namen"
    Write-Host

    if ([string]::IsNullOrWhiteSpace($name)) {
        Write-Host -ForegroundColor DarkYellow "Keine Eingabe. Abbruch."
        return
    }

    # https://www.deepl.com/de/docs-api/glossaries/create-glossary
    $url = $Config.Deepl.Url.TrimEnd("/") + "/glossaries"

    $headers = @{
        Authorization = "DeepL-Auth-Key " + (Get-Content $Config.Deepl.KeyFilePath)
        "Content-Type" = "application/json"
    }

    $params = @{
        name = $name
        source_lang = "en"
        target_lang = "de"
        entries_format = "csv"
        entries = (Get-Content $Config.Deepl.GlossaryFilePath -Raw)
    } | ConvertTo-Json

    if ($Worker.IsDebug()) {
        Write-Host -ForegroundColor Yellow "HTTP Request: $url"
        $headers | Out-Host
        $params | Out-Host
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Body $params 
        if ($Worker.IsDebug()) {
            Write-Host -ForegroundColor Yellow "HTTP Response: $url"
            $response | Out-Host
        }

        Write-Host "Erfolg. Neues Glossar [$name] mit ID [$($response.glossary_id)] wurde erstellt."
        Write-Host "Nutze es für die Übersetzung, indem Du es in der Konfiguration [Programm] unter 'Deepl.TranslateGlossarId' einträgst."
        Write-Host "Oder teste es erst mit der 4ten Auswahl vom Modus."
    }
    catch {
        Write-Host -ForegroundColor Red ("ERROR: " + $_.Exception.Message)
    }
    
    return
}

if ($choice -eq "3") {
    Write-Host -ForegroundColor Green "Okay, folgend wird ein bestehendes Glossar anhand der ID gelöscht."
    Write-Host

    $id = Read-Host "Zu löschendes Glossar (ID)"
    Write-Host

    if ([string]::IsNullOrWhiteSpace($id)) {
        Write-Host -ForegroundColor DarkYellow "Keine Eingabe. Abbruch."
        return
    }

    # https://www.deepl.com/de/docs-api/glossaries/delete-glossary
    $url = $Config.Deepl.Url.TrimEnd("/") + "/glossaries/$id"

    $headers = @{
        Authorization = "DeepL-Auth-Key " + (Get-Content $Config.Deepl.KeyFilePath)
    }

    $params = @{}

    if ($Worker.IsDebug()) {
        Write-Host -ForegroundColor Yellow "HTTP Request: $url"
        $headers | Out-Host
        $params | Out-Host
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method DELETE
        if ($Worker.IsDebug()) {
            Write-Host -ForegroundColor Yellow "HTTP Response: $url"
            $response | Out-Host
        }

        Write-Host "Erfolg. Glossar mit ID [$id] wurde gelöscht."
    }
    catch {
        Write-Host -ForegroundColor Red ("ERROR: " + $_.Exception.Message)
    }
    
    return
}


if ($choice -eq "4") {
    Write-Host -ForegroundColor Green "Okay, testen wir nun das Glossar."
    Write-Host

    $id = Read-Host "Welches Glossar (ID) oder leer = keins"
    Write-Host

    $textEn = Read-Host "Welchen Text (EN)"
    Write-Host

    if ([string]::IsNullOrWhiteSpace($textEn)) {
        Write-Host -ForegroundColor DarkYellow "Keine Eingabe. Abbruch."
        return
    }

    # https://www.deepl.com/docs-api/translate-text/translate-text
    $url = $Config.Deepl.Url.TrimEnd("/") + "/translate"

    $headers = @{ }

    $params = @{
        auth_key = Get-Content $Config.Deepl.KeyFilePath
        target_lang = "DE"
        source_lang = "EN"
        formality = "prefer_more"
        glossary_id = $id
        text = $textEn
        context = "You are many"
    } 

    if ($Worker.IsDebug()) {
        Write-Host -ForegroundColor Yellow "HTTP Request: $url"
        $headers | Out-Host
        $params | Out-Host
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Headers $headers -Method POST -Body $params 
        if ($Worker.IsDebug()) {
            Write-Host -ForegroundColor Yellow "HTTP Response: $url"
            $response | Out-Host
        }

        Write-Host "DeepL ist fertig"
        Write-Host "EN: $textEn"
        Write-Host "DE: $($response.translations.text)"
        Write-Host
        Write-Host "Wenn alles passt, dann setze die ID als 'Deepl.TranslateGlossaryId' in der Konfiguration [Programm]."
        Write-Host "Übersetzungen (Modus 3) werden dann mit dem Glossar durchgeführt."
        
    }
    catch {
        Write-Host -ForegroundColor Red ("ERROR: " + $_.Exception.Message)
    }
    
    return
}

if ($choice -eq "5") {
    Write-Host -ForegroundColor DarkYellow "Okay, Abbruch."
    return
}