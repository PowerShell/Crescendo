Describe "Unit tests for Microsoft.PowerShell.Crescendo" -tags CI {

    BeforeAll {
        $noun = "Crescendo"
        $verb = 'Get'
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
        It "correctly creates the proxy function code" -skip:${IsWindows} {
            $pc = New-CrescendoCommand -Verb $verb -Noun $noun
            $pc.OriginalName = "/bin/ls"
            $pc.Description = "this is a description"
            $pc.Usage = "this is usage" # this allows for creating a synopsis because of the default constructor for usage
            $s = $pc.ToString()
            $expectedResult = (Get-Content "${PSScriptRoot}/assets/ProxyContentTest1.txt") -join [environment]::newline
            $s | Should -Be $expectedResult
        }

        It "correctly creates the proxy function code with a parameter" -skip:${IsWindows} {
            $pc = New-CrescendoCommand -Verb $verb -Noun $noun
            $pc.OriginalName = "/bin/ls"
            $pc.Description = "this is a description"
            $pc.Usage = "this is usage" # this allows for creating a synopsis because of the default constructor for usage
            $pc.Parameters.Add((New-ParameterInfo -Name "pName" -OriginalName "--OriginalName"))
            $s = $pc.ToString()
            $expectedResult = (Get-Content "$PSScriptRoot/assets/ProxyContentTest2.txt") -join [environment]::newline
            $s | Should -Be $expectedResult
        }
    }
}
