Describe "Unit tests for Microsoft.PowerShell.Crescendo" -tags CI {

    BeforeAll {
        $moduleName = "Microsoft.PowerShell.Crescendo"
        $moduleManifest = "${moduleName}.psd1"
        $noun = "Crescendo"
        $verb = 'Get'
        $modulePath = [System.Io.Path]::combine($PSScriptRoot,"..","src","Microsoft.PowerShell.Crescendo.psd1")
        $moduleManifestPath = (Resolve-Path $modulePath).Path
        import-module $moduleManifestPath
    }

    AfterAll {
        Remove-Module $moduleName
    }

    It "is possible to create a command object" {
        $pc = New-CrescendoCommand -Verb $verb -Noun $noun
        $pc.Verb | Should -BeExactly $verb
        $pc.Noun | Should -BeExactly $noun
    }

    It "is possible to create add a parameter to a command object" {
        $pc = New-CrescendoCommand -Verb $verb -Noun $noun
        $pc.Parameters.Add((New-ParameterInfo -Name "pName" -OriginalName "--OriginalName"))
        $pc.Parameters[0].Name | Should -BeExactly pName
        $pc.Parameters[0].OriginalName | Should -BeExactly '--OriginalName'
    }

    Context "Proxy function content" {
        It "correctly creates the proxy function code" -skip:$IsWindows {
            $pc = New-CrescendoCommand -Verb $verb -Noun $noun
            $pc.OriginalName = "/bin/ls"
            $s = $pc.ToString()
            $expectedResult = (Get-Content "${PSScriptRoot}/assets/ProxyContentTest1.txt") -join "`n"
            $s | Should -Be $expectedResult
        }

        It "correctly creates the proxy function code with a parameter" -skip:$IsWindows {
            $pc = New-CrescendoCommand -Verb $verb -Noun $noun
            $pc.OriginalName = "/bin/ls"
            $pc.Parameters.Add((New-ParameterInfo -Name "pName" -OriginalName "--OriginalName"))
            $s = $pc.ToString()
            $expectedResult = (Get-Content "$PSScriptRoot/assets/ProxyContentTest2.txt") -join "`n"
            $s | Should -Be $expectedResult
        }
    }
}
