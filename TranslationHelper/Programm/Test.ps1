<#
    Diese Datei enthält Entwicklungstests für die TranslationHelper-Programm-Module und generelle PowerShell-Tests.
    Bitte einfach ignorieren.
#>

. {
    <#

        Test: Neuer XML-Parser mit Zeilennummern und XPath-Entity-Selektor
        - XmlDocument kann keine Zeilennummern anzeigen.
        - XDocument/XElement/XContainer (System.Xml.Linq) kann Zeilennummern anzeigen.
        - Zudem hat der Algorithmus ein Problem mit Strukturänderungen (z.B. Elemente fehlen).
        - Geplante Lösung: XPath-Selektor für Entity-Selektion (z.B. /*/*/Id) und dann Attribut-Selektion (z.B. /*/*/[Id='1']/Name)

        Referenzen:
        - XPath-Beispiele: https://learn.microsoft.com/de-de/previous-versions/dotnet/netframework-4.0/ms256086(v=vs.100)
        - [System.Xml.XPath]::XPathSelectElement: https://learn.microsoft.com/de-de/dotnet/api/system.xml.xpath.extensions.xpathselectelement?view=net-8.0
        - https://stackoverflow.com/questions/6209841/how-to-use-xpath-with-xdocument
        - http://www.java2s.com/example/csharp-book/cast-xelement-to-string.html
        - https://stackoverflow.com/questions/1542073/xdocument-or-xmldocument
        - https://learn.microsoft.com/en-us/dotnet/api/system.xml.linq.xdocument.load?view=net-8.0#system-xml-linq-xdocument-load(system-string-system-xml-linq-loadoptions)

        Anmerkungen:
        - XPathNavigator kann nicht verwendet werden, da dieser nicht mit XDocument zusammen arbeitet (älter).
        - XDocument wird empfohlen, genau aus den oben genannten Gründen.
        - XPathSelectElement/Elements ist eine Extension Method und muss daher statisch aufgerufen werden.
        - Um an das XML zu kommen, kann man einfach das Xx nach [string] casten.
        - Reading InnerXml: $reader = $xElement.CreateReader(); $reader.MoveToContent(); $reader.ReadInnerXml()
    #>

    function Load($Path) {
        $xmlLoadOptions = [System.Xml.Linq.LoadOptions]::PreserveWhitespace -bor [System.Xml.Linq.LoadOptions]::SetLineInfo
        $xml = [System.Xml.Linq.XDocument]::Load($Path, $xmlLoadOptions)
        return $xml
    }

    $xmlEnNew = Load -Path "$PSScriptRoot\..\1 Englisch Neu\Artifacts_Dhayut.xml"
    $xmlEnOld = Load -Path "$PSScriptRoot\..\2 Englisch Alt\Artifacts_Dhayut.xml"
    $xmlDe = Load -Path "$PSScriptRoot\..\3 Deutsch Alt\Artifacts_Dhayut.xml"

    [System.Xml.XPath.Extensions]::XPathSelectElements($xmlEnNew.Root, "/*/*/ArtifactId").Value
    [System.Xml.XPath.Extensions]::XPathSelectElement($XmlEnOld, "/*/*[ArtifactId='38']/Name").Value #.LineNumber
    [System.Xml.XPath.Extensions]::XPathSelectElement($xmlDe, "/*/*[ArtifactId='38']/Name").Value #.LineNumber

    # [string]$xmlEnNew.Element("ArrayOfArtifact").Elements("Artifact")
    # $xmlEnNew.Element("ArrayOfArtifact").Elements("Artifact")[0].LineNumber
    # $xmlEnNew.Element("ArrayOfArtifact").Elements("Artifact").Count
    # [string]$xmlEnNew.Element("ArrayOfArtifact").Elements("Artifact")[2]

    # $xmlEnNew | Get-Member -Type Method
    # [System.Xml.XPath.Extensions] | gm -Static -Type Method

    exit
}


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

