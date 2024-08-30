# TODO: Neue Version
@(
    @{
        Name = "Name + Description"
        Dateien = @(
            "Artifacts.xml"
	        "Artifacts_*.xml"
            #"ColonyEventDefinitions.xml"
	        #"ColonyEventDefinitions_*.xml"
            #"Resources.xml"
            #"ResearchProjectDefinitions.xml"
	        #"ResearchProjectDefinitions_*.xml"
        )
        IdRegel = "/*/*/ArtifactId"
        Regeln = @(
            "Name"
            "Description"
            # "DiplomacyFactors/EmpireIncidentFactor/Description"
        )
    }
    @{
        Name = "Game Events"
        Dateien = @(
            "GameEvents.xml"
            "GameEvents_Beta.xml"
	        "GameEvents_Ancient_Guardian_Vaults.xml"
        )
        IdRegel = "/*/*/Name"
        Regeln = @(
            "PlacementActions/GameEventAction/MessageTitle"
            "PlacementActions/GameEventAction/Description"
            "PlacementActions/GameEventAction/ChoiceButtonText"
            "TriggerActions/GameEventAction/MessageTitle"
            "TriggerActions/GameEventAction/Description"
            "TriggerActions/GameEventAction/ChoiceButtonText"
        )
    }
)