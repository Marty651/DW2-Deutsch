
class Helper
{
    [object]$Config
    [object]$LogData

    Helper($Config) { }

    [void] Log($Steps, $ForegroundColor, $Type, $RuleSet, $File, $Rule, $Info) { }
    [void] SaveLogData($FilePath) { }

    [object] Load($Path) { return $null }
    [void] Save($Xml, $Path) { }

    [object] Translate($Text) { return $null }

    [object] ResolveFileGlobs($FileNames, $FolderPath) { return $null }
    [object] ResolvePath($Path) { return $null }
}