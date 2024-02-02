<#
    << Hier werden die Regelsets - Regeln per Datei/Dateigruppe (Governments.xml, ShipHulls*.xml) - angegeben. >> 
    Diese Datei wird von PowerShell gestartet/ausgeführt und ausgelesen.
    Erwartete Rückgabe ist ein Array von Regelsets mit folgendem Aufbau:
        @{
            Name = "Name des Regelsets (nur für die Ausgabe / das Log)"
            Dateien = @("Datei1.xml", "Datei2.xml", "DateienMitWildcard_*.xml", ...)
            Regeln = @(
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
        Regeln = @(
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
        Regeln = @(
            "/ArrayOfShipHull/ShipHull/Name" 
        )
    }
)
### [ENDE] Alles bis hier ist nur ein Beispiel und wird so nicht tatsächlich verwendet! ###

# Hinweis: Der Name und die Gruppenaufteilung bezieht sich auf die bestehenden "Rules" Tabellen.

@(
    @{
        Name = "#1 Nur Name"
        Dateien = @(
            "ArmyTemplates.xml"
            "ComponentDefinitions.xml"
	    "ComponentDefinitions_*.xml"
	    "CreatureTypes.xml"
            "FleetTemplates.xml"
            "OrbTypes.xml"
            "PlanetaryFacilityDefinitions.xml"
	    "PlanetaryFacilityDefinitions_*.xml"
            "ShipHulls.xml"
            "ShipHulls_*.xml"
            "SpaceItemDefinitions.xml"
            "TroopDefinitions.xml"
	    "TroopDefinitions_*.xml"
        )
        Regeln = @(
            "/*/*/Name"
        )
    }
    @{
        Name = "#2 Name + Description"
        Dateien = @(
            "Artifacts.xml"
	    "Artifacts_*.xml"
            "ColonyEventDefinitions.xml"
	    "ColonyEventDefinitions_*.xml"
            "Resources.xml"
            "ResearchProjectDefinitions.xml"
	    "ResearchProjectDefinitions_*.xml"
        )
        Regeln = @(
            "/*/*/Name"
            "/*/*/Description"
            "/*/*/DiplomacyFactors/EmpireIncidentFactor/Description"			
        )
    }
    @{
        Name = "Basic-Versionen #3 Game Events"
        Dateien = @(
            "GameEvents.xml"
	    "GameEvents_Ancient _Guardian_Vaults.xml"
        )
        Regeln = @(
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
        Regeln = @(
            "/*/*/TriggerActions/GameEventAction/MessageTitle"
            "/*/*/TriggerActions/GameEventAction/Description"
        )
    }
    @{
        Name = "#5 Governments"
        Dateien = @(
            "Governments.xml"
	    "Governments_*.xml"
        )
        Regeln = @(
            "/*/*/Name"
            "/*/*/Description"
            "/*/*/LeaderTitle"
            "/*/*/CabinetTitle"
            "/*/*/EmpireNameAdjectives/string"
            "/*/*/EmpireNameNouns/string"
        )
    }
    @{
        Name = "#6 Races"
        Dateien = @(
            "Races.xml"
	    "Races_*.xml"
        )
        Regeln = @(
            "/*/*/Description"
        )
    }
    @{
        Name = "Basic-Versionen #7 Tour Items"
        Dateien = @(
            "TourItems.xml"
        )
        Regeln = @(
            "/*/*/Steps/TourStep/StepTitle"
            "/*/*/Steps/TourStep/MarkupText"
        )
    }
    @{
        Name = "DLC-Versionen #1 Game Events"
        Dateien = @(
            "GameEvents_Dhayut.xml"
            "GameEvents_Ikkuro.xml"
            "GameEvents_Gizurean.xml"
            "GameEvents_Quameno.xml"
        )
        Regeln = @(
            "/*/*/PlacementActions/GameEventAction/MessageTitle"
            "/*/*/PlacementActions/GameEventAction/Description"
            "/*/*/PlacementActions/GameEventAction/ChoiceButtonText"
            "/*/*/TriggerActions/GameEventAction/MessageTitle"
            "/*/*/TriggerActions/GameEventAction/Description"
            "/*/*/TriggerActions/GameEventAction/ChoiceButtonText"
        )
    }
    @{
        Name = "DLC-Versionen #2 Game Events (Governments)"
        Dateien = @(
            "GameEvents_HarmoniousUtopia_Government.xml"
            "GameEvents_SurveillanceOligarchy_Government.xml"
	    "GameEvents_Cell_Hegemony_Government.xml"
            "GameEvents_Geniocracy_Government.xml"
        )
        Regeln = @(
            "/*/*/TriggerActions/GameEventAction/MessageTitle"
            "/*/*/TriggerActions/GameEventAction/Description"
        )
    }
)
