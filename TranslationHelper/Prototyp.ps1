$Config = @{
    MarkerNew = "#####NEU##### "
    MarkerAutoTranslated = "#####AUTOMATISCH_ÜBERSETZT##### "
    MarkerOutdated = "#####ÜBERFÄLLIG##### "

    FilePathRules = ".\Regeln\Governments.ps1"

    FilePathEnOld = ".\1 Englisch Alt\Governments.xml"
    FilePathEnNew = ".\2 Englisch Neu\Governments.xml"
    FilePathDe = ".\3 Deutsch Alt\Governments.xml"

    FilePathResult = ".\4 Deutsch Neu (Ergebnis)\Governments.xml"
    FilePathLog = ".\Logs\Log.$(Get-Date -Format "yyyy-MM-dd_hh-mm-ss").csv"

    UseDeepl = $true
    FilePathDeeplKey = ".\Schlüssel\Deepl.txt"
    DeeplUrl = "https://api-free.deepl.com/v2/translate"
}

$Rules = . $Config.FilePathRules

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

# TODO: DEEPL AUTO TRANSLATE FOR NOT_TRANSLATED entries (with at switch)

# What if a new government (or property) is added and no rule exists? Will this be covered by other means?

# I think it makes more sense to use a "scanning" mechanism, meaning to check for all elements in EN_NEW and then check if they exist in EN_OLD and DE.
# This way, new governments will be automatically covered.
# The rules will then just be used to mark sections to include/ignore.
# Maybe is a separate program?
# We could also make it a bit easier and hard code the "ID" logic for the governments and other files (as having it super dynamic doesn't help us much)

# When doing it like above (fixed rules) and wanting some dynamic:
# Either it's defined by some attribute/property (like GovernmentId) or by index directly
# Or, when it's just multiple elements (and that is allowed, should be defined), we could just use the index of the element in the array to add to the XPath in the other documents - if there is a match, it's OK, otherwise not (new/invalid).

# Also, we need a better way to add completely new elements. 

$xmlDe = [xml](Get-Content $Config.FilePathDe -Encoding UTF8);
$xmlEnOld = [xml](Get-Content $Config.FilePathEnOld -Encoding UTF8);
$xmlEnNew = [xml](Get-Content $Config.FilePathEnNew -Encoding UTF8);

$log = @("STATUS; REGEL; INFO");

foreach ($rule in $Rules) {
    Write-Host "Regel: $rule"

    $elementNew = $xmlEnNew.SelectNodes($rule);
    if ($elementNew.Count -eq 0) {
        $msg = "Invalide Regel. Kein Element gefunden in 'Englisch Neu'."
        Write-Host -ForegroundColor DarkYellow $msg
        $log += "INVALIDE; $rule; $msg"
        continue
    }
    elseif ($elementNew.Count -gt 1) {
        $msg = "Invalide Regel. Mehrere ($($elementNew.Count)) Elemente gefunden in 'Englisch Neu'."
        Write-Host -ForegroundColor DarkYellow $msg
        $log += "INVALIDE; $rule; $msg"
        continue

        # TODO: Check if possible to just go like
        # If 0 => Invalid
        # If 1 => Check Single Element
        # If >1 => Check Arrray Element (-> check for each index as new path in old -> 0/1/1+ -> check again (recursive))
        # Note: Only possible, if the order should match (but that is very likely)
    }

    # Element in EN_NEW exists!
    
    # Workaround: Some "empty" elements are not recognized as such, so we add a text node if it doesn't exist.
    if (!($elementNew | Get-Member "#text" -MemberType Property)) {
        $elementNew.AppendChild($xmlEnNew.CreateTextNode([String]::Empty)) | Out-Null
    }

    # TODO: Maybe it's better to just ignore empty or throw a warning/error/invalid?

    $elementOld = $xmlEnOld.SelectNodes($rule);
    if ($elementOld.Count -eq 0) {
        $msg = "Neu. Kein Element gefunden in 'Englisch Alt'." + ($Config.UseDeepl ? " Wurde automatisch mit Deepl übersetzt." : "")
        Write-Host -ForegroundColor DarkCyan $msg
        $log += "NEU; $rule; $msg"
        if ($Config.UseDeepl) {
            $elementNew[0]."#text" = $Config.MarkerAutoTranslated + $TranslateFn.Invoke($elementNew[0]."#text")
        } else {
            $elementNew[0]."#text" = $Config.MarkerNew + $elementNew[0]."#text"
        }
        continue
    }
    elseif ($elementOld.Count -gt 1) {
        $msg = "Invalide Regel. Mehrere ($($elementOld.Count)) Elemente gefunden in 'Englisch Alt'."
        Write-Host -ForegroundColor DarkYellow $msg
        $log += "INVALIDE; $rule; $msg"
        continue
    }
    elseif ($elementOld[0].InnerText -ne $elementNew[0].InnerText) {
        $msg = "Überfällig. Neuen Text in 'Englisch Neu' gefunden, der nicht genau gleich in 'Englisch Alt' existiert."
        Write-Host -ForegroundColor DarkBlue $msg
        $log += "ÜBERFÄLLIG; $rule; $msg"
        $elementNew[0]."#text" = $Config.MarkerOutdated + $elementNew[0]."#text"
        continue
    }

    # Elements in EN_NEW and EN_OLD exist and text is equal!

    $elementDe = $xmlDe.SelectNodes($rule);
    if ($elementDe.Count -eq 0) {
        $msg = "Fehlt. Kein Element gefunden in 'Deutsch Alt'." + ($Config.UseDeepl ? " Wurde automatisch mit Deepl übersetzt." : "")
        Write-Host -ForegroundColor DarkCyan $msg
        $log += "NEU; $rule; $msg"
        if ($Config.UseDeepl) {
            $elementNew[0]."#text" = $Config.MarkerAutoTranslated + $TranslateFn.Invoke($elementNew[0]."#text")
        } else {
            $elementNew[0]."#text" = $Config.MarkerNew + $elementNew[0]."#text"
        }
        continue
    }
    elseif ($elementDe.Count -gt 1) {
        $msg = "Invalide Regel. Mehrere ($($elementDe.Count)) Elemente gefunden in 'Deutsch Alt'."
        Write-Host -ForegroundColor DarkYellow $msg
        $log += "INVALIDE; $rule; $msg"
        continue
    }
    elseif (($elementNew[0].InnerText -eq $elementDe[0].InnerText) -and ($elementNew[0].InnerText -ne [String]::Empty)) {
        $msg = "Fehlende Übersetzung. Texte von 'Englisch Neu' bzw. 'Englisch Alt' stimmen mit dem Text in 'Deutsch Alt' überein." + ($Config.UseDeepl ? " Wurde automatisch mit Deepl übersetzt." : "")
        Write-Host -ForegroundColor DarkCyan $msg
        $log += "NEU; $rule; $msg"
        if ($Config.UseDeepl) {
            $elementNew[0]."#text" = $Config.MarkerAutoTranslated + $TranslateFn.Invoke($elementNew[0]."#text")
        } else {
            $elementNew[0]."#text" = $Config.MarkerNew + $elementNew[0]."#text"
        }
        continue
    }
        
        # Element in EN_NEW exists and is the same as in EN_OLD and not DE!
        Write-Host -ForegroundColor DarkGreen "Fertig, bereits übersetzt."
        $elementNew[0]."#text" = $elementDe[0]."#text"
    }
    
    $log | Out-File -FilePath  $Config.FilePathLog -Encoding utf8BOM -Force
    $xmlEnNew.Save($Config.FilePathResult);


    # $elementNew[0]."#text" = "#####AUTO_TRANSLATED##### " + [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::Default.GetBytes($response.translations.text))