
<#
    Worker that contains shared logic for the TranslationHelper program modes.
    Also contains helper methods like logging, loading and saving files, resolving paths and globs, etc.
#>
class Worker
{
    [object]$Config
    [object]$LogData

    Worker($Config) { }

    [void] Log($Steps, $ForegroundColor, $Type, $RuleSet, $File, $Rule, $Info) { }
    [void] SaveLogData($FilePath) { }

    [object] Load($Path) { return $null }
    [void] Save($Xml, $Path) { }

    [object] Translate($Text) { return $null }

    [object] ResolveFileGlobs($FileNames, $FolderPath) { return $null }
    [object] ResolvePath($Path) { return $null }

    [object] IsDebug() { return $null }
}