using module .\Helper.psm1

class RealHelper : Helper
{
    [object]$Config
    [object]$LogData = @("TYP; REGELSET; DATEI; PFAD; INFO")

    RealHelper($Config) : base($Config)
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
        $Path = $this.ResolvePath($Path)
        $Xml.Save($Path)
    }

    [object] Translate($Text) 
    {
        $params = @{
            auth_key = Get-Content $this.Config.FilePathDeeplKey
            text = $Text
            target_lang = "DE"
        }
        $response = Invoke-RestMethod -Uri $this.Config.DeeplUrl -Method Post -Body $params
        return $response.translations.text
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

        [switch]$IgnorePSBoundParameters = $false
        [switch]$IgnoreDebugPreference = $false
        [switch]$IgnorePSDebugContext = $false

        return (
            ((-not $IgnoreDebugPreference.IsPresent) -and ($global:DebugPreference -ne "SilentlyContinue")) -or
            ((-not $IgnorePSBoundParameters.IsPresent) -and $global:PSBoundParameters.Debug.IsPresent) -or
            ((-not $IgnorePSDebugContext.IsPresent) -and ($global:PSDebugContext))
        )
    }
}

# Using classes has a flaw: Regardless of what used (. / &) the class is not hot-loaded, so changes are only loaded after a restart of PowerShell.
# To work around this we use PSM1 files and load them via Import-Module. We can then remove them via Remove-Module in dev mode, this hot-loads them.
# Problem is, that classes can not be exported. For this we export a function that creates the class and returns it.
# Ah, bad but the type is also not known this way.

function New-HelperClass
{ 
    param($Config)

    # https://github.com/PowerShell/PowerShell/issues/2505
    # https://stackoverflow.com/questions/31051103/how-to-export-a-class-in-a-powershell-v5-module
    # https://stackoverflow.com/questions/42838107/remove-class-from-memory-in-powershell/42878789#42878789
    # https://stackoverflow.com/questions/41037575/how-to-export-classes-from-modules-when-the-class-definition-is-dotsourced

    return [RealHelper]::new($Config)
}

### Export all functions
Export-ModuleMember *
Write-Debug "Imported: [$(Split-Path -Leaf $MyInvocation.MyCommand.Path)]"