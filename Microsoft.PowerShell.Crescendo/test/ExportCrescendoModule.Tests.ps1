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

}