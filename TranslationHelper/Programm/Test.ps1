<#
    Diese Datei enthält Entwicklungstests für die TranslationHelper-Programm-Module und generelle PowerShell-Tests.
    Bitte einfach ignorieren.
#>

{
    exit
        function X($y) {

        
        Write-Host $local:y
    }

    $y = 1

    X 0
}

{    
    exit
    
    # This could be used to override settings in the command via a simple hashtable (without need to change the actual config file)
    # Load class A, B, C config
    # Load (from args) the given config hashtable D
    # Combine all in order to the config class
    # Use that (fully typed) in the program
    # Type is only needed if you want autocomplete
    
    class TestA
    {
        $DebugA
        $DebugB
    
        $MarkerA
        $MarkerB
    
        $LogA
        $LogB
    }
    
    class TestB : TestA 
    {
        $DebugA = $true
        $DebugB = $true
    }
    
    $zz = @{ 
    
        LogA = $true
        LogB = $true
    }
    
    $z = @{    
        DebugA = $false
        LogA = $false
    }
    
    # Class and hashtable is combinable, the "base class" is used for combining
    # We'll always use the last set value (that is not $null)
    $x = 
    [TestA]::new(),
    [TestB]::new(),
    $zz,
    $z
    
    # Use only hashtable, then we need Keys
    $x.Keys | select -unique
    $y = [TestA]::new()
    foreach ($p in ( $x.Keys | select -Unique)) {
        $y."$($p)" = $($x."$($p)" | ? { $_ -ne $null } | select -Last 1)
    }
    $y
    
    # Use class and hashtable works
    $yy = [TestA]::new()
    foreach ($p in ( $yy | gm -MemberType Property)) {
        $yy."$($p.Name)" = $($x."$($p.Name)" | ? { $_ -ne $null } | select -Last 1)
    }
    $yy
    
    # Use only class works also
    $yyy = [TestA]::new()
    foreach ($p in ( $yyy | gm -MemberType Property)) {
        $yyy."$($p.Name)" = $($x."$($p.Name)" | ? { $_ -ne $null } | select -Last 1)
    }
    $yyy
}

{
    exit
    class TestA
    {
        $UseDeepl = $false
        $DryRun
        $ShowGreen
    
        $DebugOnlyRulesets = @("Basic-Versionen #3 Game Events")
    
        $MarkerPreAndPostFix = "_____"
        $MarkerInvalid = "UNGÜLTIG"
        $MarkerNew = "NEU"
        $MarkerNotYetTranslated = "NOCH_NICHT_ÜBERSETZT"
        $MarkerNoDifference = "DEUTSCH_UND_ENGLISCH_GLEICH"
        [object]$MarkerOutdated = "VERALTET"
        [object]$MarkerDifferent = "UNTERSCHIEDLICH"
    
        [object]$FilePathRuleSets = "$PSScriptRoot\Regeln.ps1"
    
        [object]$FolderPathEnNew = "$PSScriptRoot\..\1 Englisch Neu"
        [object]$FolderPathEnOld = "$PSScriptRoot\..\2 Englisch Alt"
        [object]$FolderPathDe = "$PSScriptRoot\..\3 Deutsch Alt"
    
        [object]$FolderPathResult = "$PSScriptRoot\..\4 Deutsch Neu (Ergebnis)"
    
        [object]$Logger = @{
            FolderPath = "$PSScriptRoot\..\Logs"
            IncludeDateTimeStamp = $false
        }
    
        [object]$FilePathDeeplKey = "$PSScriptRoot\..\Schlüssel\Deepl.txt"
        [object]$DeeplUrl = "h"
    }
    
    class TestB : TestA 
    {
        $UseDeepl = $false
        $UseX
    }
    
    [TestB]::new()
    
    [TestA]::new()
}




















exit

# This could be used to override settings in the command via a simple hashtable (without need to change the actual config file)
# Load class A, B, C config
# Load (from args) the given config hashtable D
# Combine all in order to the config class
# Use that (fully typed) in the program
# Type is only needed if you want autocomplete

class TestA
{
    $DebugA
    $DebugB

    $MarkerA
    $MarkerB

    $LogA
    $LogB
}

class TestB : TestA 
{
    $DebugA = $true
    $DebugB = $true
}

$zz = @{ 

    LogA = $true
    LogB = $true
}

$z = @{    
    DebugA = $false
    LogA = $false
}

# Class and hashtable is combinable, the "base class" is used for combining
# We'll always use the last set value (that is not $null)
$x = 
[TestA]::new(),
[TestB]::new(),
$zz,
$z

# Use only hashtable, then we need Keys
$x.Keys | select -unique
$y = [TestA]::new()
foreach ($p in ( $x.Keys | select -Unique)) {
    $y."$($p)" = $($x."$($p)" | ? { $_ -ne $null } | select -Last 1)
}
$y

# Use class and hashtable works
$yy = [TestA]::new()
foreach ($p in ( $yy | gm -MemberType Property)) {
    $yy."$($p.Name)" = $($x."$($p.Name)" | ? { $_ -ne $null } | select -Last 1)
}
$yy

# Use only class works also
$yyy = [TestA]::new()
foreach ($p in ( $yyy | gm -MemberType Property)) {
    $yyy."$($p.Name)" = $($x."$($p.Name)" | ? { $_ -ne $null } | select -Last 1)
}
$yyy

