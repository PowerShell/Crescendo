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

    Context 'Supports NoClobberManifest' {
        BeforeAll {
            $ModuleName = [guid]::NewGuid().ToString("n")
            $manifestPath = "${TESTDRIVE}/${ModuleName}.psd1"
            # create an empty manifest
            $null = New-Item -ItemType File -Path "${TESTDRIVE}/${ModuleName}.psd1"
        }

        It "A zero length manifest should be present when NoClobberManifest is set" {
            $manifestPath | Should -Exist
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile "${PSScriptRoot}/assets/SimpleProxy.json" -Force -NoClobberManifest
            (Get-Item $manifestPath).Length | Should -Be 0
        }

        It "A nonzero length manifest should be present when NoClobberManifest is not set" {
            $manifestPath | Should -Exist
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile "${PSScriptRoot}/assets/SimpleProxy.json" -Force
            (Get-Item $manifestPath).Length | Should -BeGreaterThan 0
        }

        It "The time of generating the psd1 should be earlier than the psm1 (10 second test)" {
            $ModuleName = [guid]::NewGuid().ToString("n")
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile "${PSScriptRoot}/assets/SimpleProxy.json" -Force
            start-sleep -Seconds 5
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile "${PSScriptRoot}/assets/SimpleProxy.json" -Force -NoClobberManifest
            $moduleContent = Get-Content "${TESTDRIVE}/${ModuleName}.psm1"
            $psmTime = $moduleContent[3] -replace ".* at: " -as [datetime]
            $psdInfo = import-powershelldatafile "${TESTDRIVE}/$moduleName.psd1"
            $psdTime = $psdInfo.PrivateData.CrescendoGenerated -as [datetime]
            $psdTime | Should -BeLessThan $psmTime

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

        It "The psm1 file will contain the version of Crescendo that created it." {
            $ModuleName = [guid]::NewGuid()
            $configurationPath = "${PSScriptRoot}/assets/FullProxy.json"
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile $configurationPath
            $moduleContent = Get-Content "${TESTDRIVE}/${ModuleName}.psm1"
            $exportCmd = Get-Command Export-CrescendoModule
            $expectedModuleVersion = $exportCmd.Version
            $observedModuleVersion = $moduleContent[1] -replace ".* "
        }

        It "The psm1 file will contain the schema used when creating it." {
            $ModuleName = [guid]::NewGuid()
            $configurationPath = "${PSScriptRoot}/assets/FullProxy.json"
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile $configurationPath
            $moduleContent = Get-Content "${TESTDRIVE}/${ModuleName}.psm1"
            $expectedSchemaUrl = (Get-Content $configurationPath|ConvertFrom-Json).'$schema'
            $observedSchemaUrl = $moduleContent[2] -replace ".* "
            $observedSchemaUrl | Should -Be $expectedSchemaUrl
        }

        It "The time the module was created will be the same for both the psd1 and psm1" {
            $ModuleName = [guid]::NewGuid()
            $configurationPath = "${PSScriptRoot}/assets/FullProxy.json"
            Export-CrescendoModule -ModuleName "${TESTDRIVE}/${ModuleName}" -ConfigurationFile $configurationPath
            $moduleContent = Get-Content "${TESTDRIVE}/${ModuleName}.psm1"
            $psmTime = $moduleContent[3] -replace ".* at: " -as [datetime]
            $psdInfo = import-powershelldatafile "${TESTDRIVE}/$moduleName.psd1"
            $psdTime = $psdInfo.PrivateData.CrescendoGenerated -as [datetime]
            $psdTime | Should -Be $psmTime
        }

    }
}
