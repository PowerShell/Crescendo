Describe "Crescendo supports transforming the parameter argument values" {
    BeforeAll {
        $configPath = (Join-Path -Path $PSScriptRoot -ChildPath assets -AdditionalChildPath ArgumentTransform1.json)
        $modulePath = "${TESTDRIVE}/TransformModule"
        Export-CrescendoModule -ConfigurationFile $configPath -ModuleName $modulePath
        Import-Module "${modulePath}.psd1"
        $originalPath = $env:PATH
        # add the current test path to the path so we can find the test executable
        $env:PATH += "$([io.path]::PathSeparator)${PSScriptRoot}"
    }

    AfterAll {
        $env:PATH = $originalPath
    }

    It "Should transform a simple argument value (mult2)" {
        $result = Invoke-Echo -mult2 5
        $result.Count | Should -Be 2
        $result[0] | Should Be "Argument 1 <--p3>"
        $result[1] | Should Be "Argument 2 <10>"
    }

    It "Should transform a simple argument value (join)" {
        $result = Invoke-Echo -join a,b,c
        $result.Count | Should -Be 2
        $result[0] | Should Be "Argument 1 <--p2>"
        $result[1] | Should Be "Argument 2 <a,b,c>"
    }

    It "Should transform a hashtable argument (hasht)" {
        $result = Invoke-Echo -hasht @{a=1;b=2;c=3}
        $result.Count | Should -Be 2
        $result[0] | Should Be "Argument 1 <--p1>"
        # we can't be guaranteed of the order of the hashtable keys
        # so we have to do it ourselves
        $observedResult = $result[1]
        $observedResult -match "(Argument 2 <)(.*)(>)" | Should -Be $true
        $kvps = $matches[2].Split(",") | Sort-Object
        $reconstructedResult = $matches[1] + ($kvps -join ",") + $matches[3]
        $reconstructedResult | Should Be "Argument 2 <a=1,b=2,c=3>"
    }

    It "Should transform an array argument value into multiple argument (multmult1)" {
        $result = Invoke-Echo -multmult1 (3..6)
        $result.Count | Should -Be 5
        $result[0] | Should Be "Argument 1 <--p4>"
        $result[1] | Should Be "Argument 2 <6>"
        $result[2] | Should Be "Argument 3 <8>"
        $result[3] | Should Be "Argument 4 <10>"
        $result[4] | Should Be "Argument 5 <12>"
    }

    It "Should transform an array argument value into single argument (multmult2)" {
        $result = Invoke-Echo -multmult2 (3..6)
        $result.Count | Should -Be 2
        $result[0] | Should Be "Argument 1 <--p5>"
        $result[1] | Should Be "Argument 2 <6,8,10,12>"
    }
        


}