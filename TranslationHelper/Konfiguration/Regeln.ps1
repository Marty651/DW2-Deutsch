<#
    << Hier werden die Regelsets - Regeln per Datei/Dateigruppe (Governments.xml, ShipHulls*.xml) - angegeben. >> 
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

### [START] Alles ab hier ist nur ein Beispiel und wird so nicht tatsächlich verwendet! ###
$Nicht_Verwendetes_Beispiel = @(
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
)
### [ENDE] Alles bis hier ist nur ein Beispiel und wird so nicht tatsächlich verwendet! ###

# Hinweis: Der Name und die Gruppenaufteilung bezieht sich auf die bestehenden "Rules" Tabellen.

@(
    @{
        Name = "Basic-Versionen #1 Nur Name"
        Dateien = @(
            "ArmyTemplates.xml"
            "ComponentDefinitions.xml"
			"CreatureTypes.xml"
            "FleetTemplates.xml"
            "OrbTypes.xml"
            "PlanetaryFacilityDefinitions.xml"
	"PlanetaryFacilityDefinitions_Ancient_Guardian_Vaults.xml"
            "ResearchProjectDefinitions.xml"
            "ShipHulls.xml"
            "ShipHulls_*.xml"
            "SpaceItemDefinitions.xml"
            "TroopDefinitions.xml"
            "Artifacts_Dhayut.xml"
            "Artifacts_Ikkuro.xml"
        )
        Pfade = @(
            "/*/*/Name"
        )
    }
    @{
        Name = "Basic-Versionen #2 Name + Description"
        Dateien = @(
            "Artifacts.xml"
			"Artifacts_AncientGuardianVaults.xml"
            "ColonyEventDefinitions.xml"
            "Resources.xml"
        )
        Pfade = @(
            "/*/*/Name"
            "/*/*/Description"
        )
    }
    @{
        Name = "Basic-Versionen #3 Game Events"
        Dateien = @(
            "GameEvents.xml"
			"GameEvents_Ancient_Guardian_Vaults.xml"
        )
        Pfade = @(
            "/*/*/PlacementActions/GameEventAction/MessageTitle"
            "/*/*/PlacementActions/GameEventAction/Description"
            "/*/*/PlacementActions/GameEventAction/ChoiceButtonText"
            "/*/*/TriggerActions/GameEventAction/MessageTitle"
            "/*/*/TriggerActions/GameEventAction/Description"
            "/*/*/TriggerActions/GameEventAction/ChoiceButtonText"
        )
    }
    @{
        Name = "Basic-Versionen #4 Game Events (Governments)"
        Dateien = @(
            "GameEvents_Governments.xml"
        )
        Pfade = @(
            "/*/*/TriggerActions/GameEventAction/MessageTitle"
            "/*/*/TriggerActions/GameEventAction/Description"
        )
    }
    @{
        Name = "Basic-Versionen #5 Governments"
        Dateien = @(
            "Governments.xml"
        )
        Pfade = @(
            "/*/*/Name"
            "/*/*/Description"
            "/*/*/LeaderTitle"
            "/*/*/CabinetTitle"
            "/*/*/EmpireNameAdjectives/string"
            "/*/*/EmpireNameNouns/string"
        )
    }
    @{
        Name = "Basic-Versionen #6 Races"
        Dateien = @(
            "Races.xml"
        )
        Pfade = @(
            "/*/*/Description"
        )
    }
    @{
        Name = "Basic-Versionen #7 Tour Items"
        Dateien = @(
            "TourItems.xml"
        )
        Pfade = @(
            "/*/*/Steps/TourStep/StepTitle"
            "/*/*/Steps/TourStep/MarkupText"
        )
    }
    @{
        Name = "DLC-Versionen #1 Nur Name"
        Dateien = @(
            "Artifacts_Dhayut.xml"
            "Artifacts_Ikkuro.xml"
            "ComponentDefinitions_Dhayut.xml"
            "ComponentDefinitions_Ikkuro.xml"
            "PlanetaryFacilityDefinitions_Dhayut.xml"
            "PlanetaryFacilityDefinitions_Ikkuro.xml"
            "ResearchProjectDefinitions_Dhayut.xml"
            "ResearchProjectDefinitions_Ikkuro.xml"
            "ShipHulls_Dhayut.xml"
            "ShipHulls_Ikkuro.xml"
            "TroopDefinitions_Dhayut.xml"
            "TroopDefinitions_Ikkuro.xml"
        )
        Pfade = @(
            "/*/*/Name"
        )
    }
    @{
        Name = "DLC-Versionen #2 Name + Description"
        Dateien = @(
            "ColonyEventDefinitions_Dhayut.xml"
            "ColonyEventDefinitions_Ikkuro.xml"
        )
        Pfade = @(
            "/*/*/Name"
            "/*/*/Description"
        )
    }
    @{
        Name = "DLC-Versionen #3 Game Events"
        Dateien = @(
            "GameEvents_Dhayut.xml"
            "GameEvents_Ikkuro.xml"
			"GameEvents_Ikkuro_RaceEvents.xml"
        )
        Pfade = @(
            "/*/*/PlacementActions/GameEventAction/MessageTitle"
            "/*/*/PlacementActions/GameEventAction/Description"
            "/*/*/PlacementActions/GameEventAction/ChoiceButtonText"
            "/*/*/TriggerActions/GameEventAction/MessageTitle"
            "/*/*/TriggerActions/GameEventAction/Description"
            "/*/*/TriggerActions/GameEventAction/ChoiceButtonText"
        )
    }
    @{
        Name = "DLC-Versionen #4 Game Events (Governments)"
        Dateien = @(
            "GameEvents_HarmoniousUtopia_Governments.xml"
            "GameEvents_SurveillanceOligarchy_Governments.xml"
        )
        Pfade = @(
            "/*/*/TriggerActions/GameEventAction/MessageTitle"
            "/*/*/TriggerActions/GameEventAction/Description"
        )
    }
    @{
        Name = "DLC-Versionen #5 Governments"
        Dateien = @(
            "Governments_Dhayut.xml"
            "Governments_Ikkuro.xml"
        )
        Pfade = @(
            "/*/*/Name"
            "/*/*/Description"
            "/*/*/LeaderTitle"
            "/*/*/CabinetTitle"
            "/*/*/EmpireNameAdjectives/string"
            "/*/*/EmpireNameNouns/string"
        )
    }
    @{
        Name = "DLC-Versionen #6 Races"
        Dateien = @(
            "Races_Dhayut.xml"
            "Races_Ikkuro.xml"
        )
        Pfade = @(
            "/*/*/Description"
            "/*/*/FeatureExplanations/string"
        )
    }
)