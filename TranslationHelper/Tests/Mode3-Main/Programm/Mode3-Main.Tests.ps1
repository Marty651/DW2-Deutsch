BeforeAll {
    $Config = . $PSScriptRoot\..\Konfiguration\Programm.ps1
    $Config.ShowGreen = $false

    function Start-Test() {
        & $PSScriptRoot\..\..\..\Programm\Start.ps1 -Mode 3-MainNew -TestConfig $Config
    }
}
s
Describe 'After Mode 3 was executed' {

    BeforeAll {
        $global:ErrorActionPreference = "Stop"
        $global:DebugPreference = "SilentlyContinue"
        $global:VerbosePreference = "Ignore"

        Start-Test
    }

    It 'Reference result 1 is matched' {
        $result = Get-Content "$PSScriptRoot\..\4 Deutsch Neu (Ergebnis)\Artifacts_Dhayut.xml"
        $reference = Get-Content "$PSScriptRoot\..\5 Deutsch Neu (Referenz)\Artifacts_Dhayut.xml"

        $result | Should -Be $reference
    }

    It 'Reference result 2 is matched' {
        $result = Get-Content "$PSScriptRoot\..\4 Deutsch Neu (Ergebnis)\GameEvents_Ancient_Guardian_Vaults.xml"
        $reference = Get-Content "$PSScriptRoot\..\5 Deutsch Neu (Referenz)\GameEvents_Ancient_Guardian_Vaults.xml"

        $result | Should -Be $reference
    }
}