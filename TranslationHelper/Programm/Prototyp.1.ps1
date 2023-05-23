# << Zweites Programm - Prüfung der richtigen Verwendung der GameEvent Namen. >>

# Check GameEvents
# First searches all GameEvent/Name elements and stores the values <- all possible GameEvent (reference / ID names).
# Then it searches for locations that could reference a game event and stores the found values.
# Then it compares the found values with the possible values and shows the differences (GameEvents that arer eferenced but do not exist).

$files = @(
    "$PSScriptRoot/../1.1.2.4/DW2/GameEvents*"
    "$PSScriptRoot/../1.1.2.4/DLC Ikkuro and Dhayut/GameEvents*"
);

$gameEvents = $files | Get-ChildItem | ForEach-Object { [xml](Get-Content $_.FullName -Encoding UTF8) };

$gameEventNames = $gameEvents | % { $_.SelectNodes("//GameEvent/Name").InnerText }

$gameEventTriggerActionsReferenceNames = @(
    $gameEvents | % { $_.SelectNodes("//GameEvent/TriggerActions/GameEventAction/GeneratedItemEventNames/string").InnerText }
    $gameEvents | % { $_.SelectNodes("//GameEvent/TriggerActions/GameEventAction/GeneratedItemEventName").InnerText }
    $gameEvents | % { $_.SelectNodes("//GameEvent/PlacementActions/GameEventAction/GeneratedItemEventNames/string").InnerText }
    $gameEvents | % { $_.SelectNodes("//GameEvent/PlacementActions/GameEventAction/GeneratedItemEventName").InnerText }
    $gameEvents | % { $_.SelectNodes("//GameEvent/PlacementActions/GameEventAction/GeneratedItemName").InnerText }
)

$gameEventTriggerActionsReferenceNames | ? { ($_ -notin $gameEventNames) -and ($_ -ne "") } | unique | ogv