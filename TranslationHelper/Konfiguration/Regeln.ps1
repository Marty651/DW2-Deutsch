<#
    << Hier werden die Regeln per Datei (Governments*, ShipHulls*) angegeben. >> 
    Diese Datei wird von PowerShell gestartet/ausgeführt und ausgelesen.
    Erwartete Rückgabe ist ein Array von Regelsets mit folgendem Aufbau:
        @{
            Name = "Name des Regelsets (nur für die Ausgabe / das Log)"
            Files = @("Datei1.xml", "Datei2.xml", "DateienMitWildcard_*.xml", ...)
            Rules = @(
                "/XPath/zu/Element1"
                "/XPath/zu/Element2"
                ...
            )
        }
    Da PowerShell die Datei direkt ausführt ist auch alles möglich, was PowerShell bietet.
#>

@(
    @{
        # Es ist auch möglich, mehrere Regelsets für die gleichen Dateien zu definieren.
        Name = "Governments"
        Files = @("Governments.xml")
        Rules = @(
            # Diese Regeln verarbeitet Governments mit IDs von 0-7 und prüft unterschiedliche Eigenschaften.
            0..7 | % {
                "/ArrayOfGovernment/Government[GovernmentId='$($_)']/Name"
                "/ArrayOfGovernment/Government[GovernmentId='$($_)']/Description"
                "/ArrayOfGovernment/Government[GovernmentId='$($_)']/LeaderTitle"
                "/ArrayOfGovernment/Government[GovernmentId='$($_)']/EmpireNameAdjectives/string"
                "/ArrayOfGovernment/Government[GovernmentId='$($_)']/EmpireNameNouns/string"
            }
            # Diese extra Regeln für IDs 8-10 prüfen bestimmte Eigenschaften nicht, weil diese nicht enthalten sind.
            8..10 | % {
                "/ArrayOfGovernment/Government[GovernmentId='$($_)']/Name"
                "/ArrayOfGovernment/Government[GovernmentId='$($_)']/Description"
                "/ArrayOfGovernment/Government[GovernmentId='$($_)']/LeaderTitle"
                "/ArrayOfGovernment/Government[GovernmentId='$($_)']/StartingGameEventNames/string"
            }
        )
    }
    @{
        Name = "ShipHulls"
        Files = @(
            "ShipHulls_Dhayut.xml"
            "ShipHulls_Ikkuro.xml"
        )
        # Diese Regel geht einfach ALLE Namen durch.
        Rules = @(
            "/ArrayOfShipHull/ShipHull/Name" 
        )   
    }
)