<#
    << Hier werden die Regeln per Datei (Governments*, ShipHulls*) angegeben. >> 
    Diese Datei wird von PowerShell gestartet/ausgeführt und ausgelesen.
    Erwartete Rückgabe ist ein Array von Regelsets mit folgendem Aufbau:
        @{
            Name = "Name des Regelsets (nur für die Ausgabe / das Log)"
            Dateien = @("Datei1.xml", "Datei2.xml", "DateienMitWildcard_*.xml", ...)
            Pfade = @(
                "/XPath/zu/Element1/Welches/Geprüft/Oder/Übersetzt/Werden/Soll"
                "/XPath/zu/Element2/Welches/Geprüft/Oder/Übersetzt/Werden/Soll"
                ...
            )
        }
    Da PowerShell die Datei direkt ausführt ist auch alles möglich, was PowerShell bietet.

    XPath ist ein Standard, der von PowerShell (bzw. .NET) unterstützt wird zur Selektierung von Knoten/Elementen in XML-Dateien.
    https://www.w3schools.com/xml/xpath_syntax.asp
#>

@(
    @{
        # Es ist auch möglich, mehrere Regelsets für die gleichen Dateien zu definieren.
        Name = "Governments"
        Dateien = @(
            "Governments.xml"
        )
        Pfade = @(
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
        Name = "Ship Hulls"
        Dateien = @(
            "ShipHulls_Dhayut.xml"
            "ShipHulls_Ikkuro.xml"
        )
        # Diese Regel geht einfach ALLE Namen durch.
        Pfade = @(
            "/ArrayOfShipHull/ShipHull/Name" 
        )
    }
    @{
        Name = "Army Templates"
        Dateien = @(
            "ArmyTemplates*.xml"
        )
        Pfade = @(
            "/ArrayOfArmyTemplate/ArmyTemplate/Name"
        )
    }
    @{
        Name = "Artifacts"
        Dateien = @(
            "Artifacts*.xml"
        )
        Pfade = @(
            "/ArrayOfArtifact/Artifact/Name"
            "/ArrayOfArtifact/Artifact/Description"
        )
    }
    @{
        Name = "Colony Event Definitions"
        Dateien = @(
            "ColonyEventDefinitions*.xml"
        )
        Pfade = @(
            "/ArrayOfColonyEventDefinition/ColonyEventDefinition/Name"
            "/ArrayOfColonyEventDefinition/ColonyEventDefinition/Description"
        )
    }
    @{
        Name = "Component Definitions"
        Dateien = @(
            "ComponentDefinitions*.xml"
        )
        Pfade = @(
            "/ArrayOfComponentDefinition/ComponentDefinition/Name"
        )
    }
    @{
        Name = "Fleet Templates"
        Dateien = @(
            "FleetTemplates*.xml"
        )
        Pfade = @(
            "/ArrayOfFleetTemplate/FleetTemplate/Name"
        )
    }
    @{
        Name = "Game Events"
        Dateien = @(
            "GameEvents*.xml"
        )
        Pfade = @(
            "/ArrayOfGameEvent/GameEvent/PlacementActions/GameEventAction/MessageTitle"
            "/ArrayOfGameEvent/GameEvent/PlacementActions/GameEventAction/Description"
            "/ArrayOfGameEvent/GameEvent/PlacementActions/GameEventAction/ChoiceButtonText"
            "/ArrayOfGameEvent/GameEvent/TriggerActions/GameEventAction/MessageTitle"
            "/ArrayOfGameEvent/GameEvent/TriggerActions/GameEventAction/Description"
            "/ArrayOfGameEvent/GameEvent/TriggerActions/GameEventAction/ChoiceButtonText"
        )
    }
)