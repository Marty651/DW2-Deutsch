
@(
    @{
        Name = "#2 Name + Description"
        Dateien = @(
            "Artifacts.xml"
	        "Artifacts_*.xml"
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
	        "GameEvents_Ancient_Guardian_Vaults.xml"
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
)