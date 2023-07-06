Describe "Test the ExcludeAsArgument functionality" {
    BeforeAll {
        $originalPath = $env:PATH
        # add the current test path to the path so we can find the test executable
        $pSeparator = [io.path]::PathSeparator
        $env:PATH += "${pSeparator}${PSScriptRoot}"
        Export-CrescendoModule -ConfigurationFile "$PSScriptRoot/assets/ExcludeAsArg.json" -ModuleName "$TestDrive/ExcludeAsArgument"
        Import-Module "$TestDrive/ExcludeAsArgument"
    }

    AfterAll {
        $env:PATH = $originalPath
    }

    It "Should support the ExcludeAsArgument parameter" {
        $result = Invoke-Echo -Argument1 1,2,3,4,5 -filter "Argument 3"
        $result | Should -BeExactly "Argument 3 <3>"
    }
}
