using namespace System.Management.Automation.Language

Describe "Crescendo supports transforming the parameter argument values" {
    BeforeAll {
        $originalPath = $env:PATH
        # add the current test path to the path so we can find the test executable
        # add testdrive to the path so we can find the script
        $pSeparator = [io.path]::PathSeparator
        $env:PATH += "${pSeparator}${PSScriptRoot}${pSeparator}${TESTDRIVE}"
        'Write-Object transformscript' > "${TESTDRIVE}/transformScript.ps1"
        $null = New-Item -ItemType Directory "${TESTDRIVE}/modules"

        $configPath1 = (Join-Path -Path $PSScriptRoot -ChildPath assets -AdditionalChildPath ArgumentTransform1.json)
        $modulePath1 = "${TESTDRIVE}/modules/TransformModule1"
        Export-CrescendoModule -ConfigurationFile $configPath1 -ModuleName $modulePath1
        Import-Module "${modulePath1}.psd1"

        # because we need functions available,  we should do this in module scope
        InModuleScope Microsoft.PowerShell.Crescendo {
            $modulePath2 = "${TESTDRIVE}/modules/TransformModule2"
            $configPath2 = (Join-Path -Path $PSScriptRoot -ChildPath assets -AdditionalChildPath ArgumentTransform2.json)
            function double { param([int[]]$v) $v.Foreach({2 * $_}) }
            function myfunction { write-output myfunction }
            Export-CrescendoModule -ConfigurationFile $configPath2 -ModuleName $modulePath2
        }
        # we need to import the module in the test scope
        Import-Module "${TESTDRIVE}/modules/TransformModule2.psd1"
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

    It "Should transform a hashtable argument (hasht1)" {
        $result = Invoke-Echo -hasht1 @{a=1;b=2;c=3}
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

    It "Should transform an ordered dictionary argument (hasht2)" {
        $result = Invoke-Echo -hasht2 ([ordered]@{a=1;b=2;c=3})
        $result.Count | Should -Be 2
        $result[0] | Should Be "Argument 1 <--p1ordered>"
        $result[1] | Should Be "Argument 2 <a=1,b=2,c=3>"
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

    Context "Argument transform content tests" {
        BeforeAll {
            $t = $e = $null
            $AST = [Parser]::ParseFile("${TESTDRIVE}/modules/TransformModule2.psm1",[ref]$t,[ref]$e)
            $tCases = @{ Name = "double" },@{ Name = "myfunction" }
        }
        
        It "The transform module should have no syntax errors" {
            @($e).Count | Should -Be 0
        }

        It "Should only contain a single instance of the transform function '<Name>'" -TestCases $tCases {
            param ($Name)
            $fda = $Ast.FindAll({$args[0] -is [FunctionDefinitionAst] -and $args[0].Name -eq $Name}, $true)
            @($fda).Count | Should -Be 1
        }

        It "Should contain the transform script 'transformScript.ps1'" {
            $m = Get-Module TransformModule2
            $transformScriptPath = Join-Path -Path $m.ModuleBase -ChildPath transformScript.ps1
            $transformScriptPath | Should -Exist
        }
    }


}