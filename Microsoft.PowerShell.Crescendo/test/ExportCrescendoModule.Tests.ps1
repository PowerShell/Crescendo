Describe "The correct files are created when a module is created" {
    Context "proper configuration" {
        BeforeAll {
            $ModuleName = [guid]::NewGuid()
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile "${PSScriptRoot}/assets/FullProxy.json"
        }

        It "Should create the module manifest" {
            "${TESTDRIVE}/${ModuleName}.psd1" | Should -Exist
        }

        It "Should create the module code" {
            "${TESTDRIVE}/${ModuleName}.psm1" | Should -Exist
        }
    }

    Context "Configuration with fault" {
        BeforeAll {
            $ModuleName = [guid]::NewGuid()
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile "${PSScriptRoot}/assets/HandlerFault1.json" -ErrorAction SilentlyContinue
        }

        It "Should create the module manifest" {
            "${TESTDRIVE}/${ModuleName}.psd1" | Should -Exist
        }

        It "Should create the module code" {
            "${TESTDRIVE}/${ModuleName}.psm1" | Should -Exist
        }
    }

    Context "Supports -WhatIf" {
        It "Does not create a module file when WhatIf is used" {
            $ModuleName = "whatifmodule"
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile "${PSScriptRoot}/assets/FullProxy.json" -WhatIf
            Test-Path "${TESTDRIVE}/${ModuleName}*" | Should -Be $False
        }
    }

    Context "General Use" {
        It "Produces an error if the file exists" {
            $ModuleName = [guid]::NewGuid()
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile "${PSScriptRoot}/assets/FullProxy.json"
            # call it twice to produce the error
            { Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile "${PSScriptRoot}/assets/FullProxy.json" } | Should -Throw

        }

        It "Produces an error if the target platform is not allowed" {
            $ci =  New-CrescendoCommand -Verb Get -Noun Thing -OriginalName doesnotexist
            $ci.Platform = "incorrect"
            $mod = Get-Module Microsoft.PowerShell.Crescendo
            & $mod {
                $err = @()
                $ci = New-CrescendoCommand -verb get -noun thing
                $ci.platform = "zap"
                $result = Test-Configuration -Configuration $ci -err ([ref]$err)
                $result | Should -Be $false
                $err.Count | Should -Be 1
                $err[0].FullyQualifiedErrorId |  Should -Be "ParserError"
            }
        }

        It "Will produce an error if a script output handler cannot be found" {
            $cc = New-CrescendoCommand -verb get -noun thing -original notavailable
			$oh = new-outputhandler
			$oh.HandlerType = "Script"
			$oh.Handler = "doesnotexist"
            $oh.ParameterSetName = "Default"
			$cc.OutputHandlers += $oh
            $config = @{
                Commands = @($cc)
            }
            $tPath = "${TESTDRIVE}/badhandler"
            ConvertTo-Json -InputObject $config -Depth 10 | Out-File "${tPath}.json"
            Export-CrescendoModule -ConfigurationFile "${tPath}.json" -ModuleName "${tPath}" -ErrorVariable badHandler -ErrorAction SilentlyContinue
            $badHandler | Should -Not -BeNullOrEmpty
            $badHandler.FullyQualifiedErrorId | Should -Be "Microsoft.PowerShell.Commands.WriteErrorException,Export-CrescendoModule"
        }
    }
}