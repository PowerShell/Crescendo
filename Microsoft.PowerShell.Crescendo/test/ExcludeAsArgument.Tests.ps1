Describe "Test the ExcludeAsArgument functionality" {
    BeforeAll {
        Export-CrescendoModule -ConfigurationFile "$PSScriptRoot/assets/ExcludeAsArg.json" -ModuleName "$TestDrive/ExcludeAsArgument"
        Import-Module "$TestDrive/ExcludeAsArgument"
    }

    It "Should support the ExcludeAsArgument parameter" {
        $result = Invoke-Echo -Argument1 1,2,3,4,5 -filter "Argument 3"
        $result | Should -BeExactly "Argument 3 <3>"
    }
}