
## Debug
- From main repo workspace folder run PowerShell: `$DebugPreference = "Continue"; $VerbosePreference = "Continue"; .\TranslationHelper\Programm\Start.ps1 -Mode 3-Main`. Mode can be any of the existing ones.

## Tests 
- Install Pester: https://pester.dev/docs/quick-start
- From main repo workspace folder run PowerShell: `Invoke-Pester -Output Detailed \TranslationHelper\Tests