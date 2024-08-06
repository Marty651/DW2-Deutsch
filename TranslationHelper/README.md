
## Debug
- From main repo workspace folder run PowerShell: `.\TranslationHelper\Programm\Start.ps1 -Mode 3-Main`. Mode can be any of the existing ones. 
- You can use `-Debug` flag to run in debug mode with more verbose output.

## Tests 
- Install Pester: https://pester.dev/docs/quick-start
- From main repo workspace folder run PowerShell: `Invoke-Pester -Output Detailed .\TranslationHelper\Tests`
- In VSCode, Pester tests can be started directly from above the `Describe`