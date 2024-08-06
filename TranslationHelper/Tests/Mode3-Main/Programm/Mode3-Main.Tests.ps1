BeforeAll {
    $Config = . $PSScriptRoot\..\Konfiguration\Programm.ps1

    function Start-Test() {
        & $PSScriptRoot\..\..\..\Programm\Start.ps1 -Mode 3-Main -TestConfig $Config -Debug
    }
}

Describe 'Mode 3' {
    It 'Works' {
        Start-Test

        $result = Get-Content "$PSScriptRoot\..\4 Deutsch Neu (Ergebnis)\Artifacts_Dhayut.xml"
        $reference = Get-Content "$PSScriptRoot\..\5 Deutsch Neu (Referenz)\Artifacts_Dhayut.xml"

        $result | Should -Be $reference
    }
}