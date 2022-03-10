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

    It "should have the proper platform information" {
        $pc = New-CrescendoCommand -Verb $verb -Noun $noun
        $pc.Platform | Should -BeExactly "Windows","Linux","MacOS"
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

    Context "Schema tests" {
        BeforeAll {
            $crescendoSchema = Export-Schema
        }
        It "Export-Schema emits a proper schema" {
            $crescendoSchema | Should -BeOfType "Newtonsoft.Json.Schema.JsonSchema"            
        }

        It "Schema contains the '<Name>' property with proper type" -TestCases @(
            @{ Name = 'Verb';                     ExpectedType = 'String, Null'  }
            @{ Name = 'Noun';                     ExpectedType = 'String, Null'  }
            @{ Name = 'OriginalName';             ExpectedType = 'String, Null'  }
            @{ Name = 'OriginalCommandElements';  ExpectedType = 'Array, Null'   }
            @{ Name = 'Platform';                 ExpectedType = 'Array, Null'   }
            @{ Name = 'Elevation';                ExpectedType = 'Object, Null'  }
            @{ Name = 'Aliases';                  ExpectedType = 'Array, Null'   }
            @{ Name = 'DefaultParameterSetName';  ExpectedType = 'String, Null'  }
            @{ Name = 'SupportsShouldProcess';    ExpectedType = 'Boolean' }
            @{ Name = 'ConfirmImpact';            ExpectedType = 'String, Null'  }
            @{ Name = 'SupportsTransactions';     ExpectedType = 'Boolean' }
            @{ Name = 'NoInvocation';             ExpectedType = 'Boolean' }
            @{ Name = 'Description';              ExpectedType = 'String, Null'  }
            @{ Name = 'Usage';                    ExpectedType = 'Object, Null'  }
            @{ Name = 'Parameters';               ExpectedType = 'Array, Null'   }
            @{ Name = 'Examples';                 ExpectedType = 'Array, Null'   }
            @{ Name = 'OriginalText';             ExpectedType = 'String, Null'  }
            @{ Name = 'HelpLinks';                ExpectedType = 'Array, Null'   }
            @{ Name = 'OutputHandlers';           ExpectedType = 'Array, Null'   }
        ) {
            param ( $Name, $ExpectedType )
            $observedType = $crescendoSchema.Properties[$Name].Type
            $observedType | Should -Be $ExpectedType
        }
    }
}
