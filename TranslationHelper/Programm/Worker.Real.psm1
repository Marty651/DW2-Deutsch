using module .\Worker.psm1

class RealWorker : Worker
{
    [object]$Config
    [object]$LogData = @("TYP; REGELSET; DATEI; PFAD; INFO")

    RealWorker($Config) : base($Config)
    {
        $this.Config = $Config
    }

    [void] Log($Steps, $ForegroundColor, $Type, $RuleSet, $File, $Rule, $Info) 
    {
        Write-Host -ForegroundColor $ForegroundColor "$Steps $Rule -> $Type"
        $this.LogData += "$Type; $RuleSet; $file; $Rule; $info"
    }

    [void] SaveLogData($FilePath) 
    {
        $FilePath = $this.ResolvePath($FilePath)
        $this.LogData | Out-File -FilePath $FilePath -Encoding utf8BOM -Force
    }

    [object] Load($Path) 
    {
        # The files contain unusual white space (comment on same line for example) and we want to preserve the original formatting.
        # Using [xml] doesn't do that.
        # See:
        # - https://stackoverflow.com/questions/53518785/save-xml-file-without-formatting
        # - https://stackoverflow.com/questions/29624215/using-c-sharp-xml-serializer-to-produce-custom-xml-format
        # - https://stackoverflow.com/questions/203528/what-is-the-simplest-way-to-get-indented-xml-with-line-breaks-from-xmldocument
        # - https://stackoverflow.com/questions/1555028/how-do-i-edit-xml-in-c-sharp-without-changing-format-spacing
        # - https://stackoverflow.com/questions/32149676/custom-xmlwriter-to-skip-a-certain-element

        $Path = $this.ResolvePath($Path)

        if (!([System.IO.File]::Exists($Path))) {
            # Null behaves weird when used with .Invoke() so we return $false instead.
            return $false
        }

        $xml = New-Object System.Xml.XmlDocument
        $xml.PreserveWhitespace = $true
        $xml.Load($Path)

        return $xml
    }

    [void] Save($Xml, $Path)
    {
        # Saves the file as-is without changing the format.

        $Path = $this.ResolvePath($Path)
        $Xml.Save($Path)
    }

    [void] SaveFormatted($Xml, $Path)
    {
        # Saves the file with format.

        $Path = $this.ResolvePath($Path)
        
        $settings = New-Object System.Xml.XmlWriterSettings
        $settings.Indent = $true
        $writer = [System.Xml.XmlWriter]::Create($Path, $settings)
        $Xml.Save($writer)
        $writer.Dispose()
    }

    [void] Append($Xml, $AnchorElement, $ElementToAppend)
    {
        $indentationSymbol = " "
        $indentationAmount = 2
        function getDepth($node) {
            $parents = 0
            while ($node.ParentNode) {
                $parents++
                $node = $node.ParentNode
            }
            return $parents
        }

        $depth = getDepth -node $AnchorElement
    
        $indentation = $indentationSymbol * ($indentationAmount * ($depth + 1))
        $AnchorElement.AppendChild($Xml.CreateWhitespace("`r`n" + $indentation)) | Out-Null
        $AnchorElement.AppendChild($ElementToAppend) | Out-Null
    }

#    [object] Translate($Text) 
#    {
#        # https://www.deepl.com/docs-api/translate-text/translate-text
#        $url = $this.Config.Deepl.Url.TrimEnd("/") + "/translate"
#        $params = @{
#            auth_key = Get-Content $this.Config.Deepl.KeyFilePath
#            target_lang = "DE"
#            source_lang = "EN"
#            formality = "prefer_more"
#            text = $Text
#            glossary_id = $this.Config.Deepl.TranslateGlossaryId
#        }
#        try {
#            $response = Invoke-RestMethod -Uri $url -Method Post -Body $params
#        }
#        catch {
#            return ("ERROR: " + $_.Exception.Message)
#        }
#        
#        return $response.translations.text
#    }

    [object] Translate($Text) 
    {
        # https://www.deepl.com/docs-api/translate-text/translate-text
        $url = $this.Config.Deepl.Url.TrimEnd("/") + "/translate"
        $params = @{
            auth_key = Get-Content $this.Config.Deepl.KeyFilePath
            target_lang = "DE"
            source_lang = "EN"
            formality = "prefer_more"
            text = $Text
            glossary_id = $this.Config.Deepl.TranslateGlossaryId
        }
        # Wiederholungslogik für Rate-Limiting
        $attempts = 0
        while ($attempts -lt 5) {
            try {
                $response = Invoke-RestMethod -Uri $url -Method Post -Body $params
			    return $response.translations.text
            }
            catch {
                $attempts++
			    Write-Host -ForegroundColor Red "API Fehler, versuche erneut in 2s."
			    Start-Sleep -Milliseconds 2000
            }
        }
	    # Maximale Anzahl an Versuchen erreicht
        Write-Host -ForegroundColor Red "Maximale Anzahl von Versuchen erreicht. Die Übersetzung konnte nicht abgeschlossen werden."
        return $null
    }

    [object] ResolveFileGlobs($FileNames, $FolderPath) 
    {
        $FolderPath = $this.ResolvePath($FolderPath)

        return $FileNames | 
            ForEach-Object { Get-Item "$FolderPath/$_" -ErrorAction SilentlyContinue } |
            Select-Object -ExpandProperty Name
    }

    [object] ResolvePath($Path) 
    {
        # 2 Safety Measures:
        # 1. Using \ on macOS does not work when using paths with .NET
        #    We should use / instead for compatibility (Windows supports / and \)
        #    
        # 2. Using absolute paths is often better. 
        #    Using the normal PowerShell resolving doesn't work in classes.
        #    https://stackoverflow.com/questions/3038337/powershell-resolve-path-that-might-not-exist

        $Path = $Path -replace "\\","/"
        return [System.IO.Path]::GetFullPath($Path);
    }

    [object] IsDebug()
    {
        # See: https://stackoverflow.com/a/44442925/4629825

        return (
            $global:DebugPreference -ne "SilentlyContinue" -or
            $global:PSBoundParameters.Debug.IsPresent -or
            $global:PSDebugContext
        )
    }

    [object] DebugType($Object)
    {
        if (-not $this.IsDebug()) { return $null }

        # Get BaseType of type recursively
        $baseTypes = @()
        $type = $Object.GetType()
        while ($type) {
            if ($type.BaseType) {
                $baseTypes += $type.BaseType
            }
            $type = $type.BaseType
        }

        return [pscustomobject]@{
            "GM" = $Object | Get-Member
            "Type" = $Object.GetType()
            "DirectProperties" = $Object.GetType().GetProperties()
            "BaseTypes" = $baseTypes
            "AllProperties" = $baseTypes | % { $_.GetProperties() }
        }
    }
}

function New-Worker
{ 
    param($Config)

    # Using classes has a flaw: Regardless of what used (. / &) the class is not hot-loaded, so changes are only loaded after a restart of PowerShell.
    # To work around this we use PSM1 files and load them via Import-Module. We can then remove them via Remove-Module in dev mode, this hot-loads them.
    # Problem is, that classes can not be exported. For this we export a function that creates the class and returns it.
    # Also the type is not known this way often, until you execute in your shell `using module .\xyz.psm1`.

    # https://github.com/PowerShell/PowerShell/issues/2505
    # https://stackoverflow.com/questions/31051103/how-to-export-a-class-in-a-powershell-v5-module
    # https://stackoverflow.com/questions/42838107/remove-class-from-memory-in-powershell/42878789#42878789
    # https://stackoverflow.com/questions/41037575/how-to-export-classes-from-modules-when-the-class-definition-is-dotsourced

    return [RealWorker]::new($Config)
}

### Export all functions
Export-ModuleMember *
Write-Debug "Imported: [$(Split-Path -Leaf $MyInvocation.MyCommand.Path)]"
