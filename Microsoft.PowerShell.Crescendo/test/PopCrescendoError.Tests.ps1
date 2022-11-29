Describe "Pop-CrescendoError tests" {
    BeforeAll {
        $configPath = Join-Path $PSScriptRoot "assets" "ls.poperror.proxy.json"
        Push-Location ${TESTDRIVE}
        Export-CrescendoModule -ConfigurationFile $configPath -ModuleName "PopError"
        Pop-Location
        Import-Module -Pass "${TESTDRIVE}\PopError.psd1" -ErrorAction Ignore
    }

    It "Should not create an Error record if Pop-CrescendoError is not used with -EmitAsError" {
        $error.Clear()
        $result = invoke-filelistproxy3 -Path ThisPathDoesNotExist
        $error.Count | Should -Be 0
        $result | Should -Match "ERROR.*ThisPathDoesNotExist"
    }

    It "Should create an Error record if Pop-CrescendoError is used with -EmitAsError" {
        $error.Clear()
        $result = invoke-filelistproxy4 -Path ThisPathDoesNotExist -ErrorAction SilentlyContinue
        $error.Count | Should -Be 1
        $error[0].Exception.Message | Should -Match "ThisPathDoesNotExist"
        $result | Should -BeNullOrEmpty
    }

    It "Should respect ErrorVariable parameter" {
        $result = invoke-filelistproxy4 -Path ThisPathDoesNotExist -ErrorVariable err -ErrorAction SilentlyContinue
        $result | Should -BeNullOrEmpty
        $err.Count | Should -Be 1
        $err[0].Exception.Message | Should -Match "ThisPathDoesNotExist"
    }

    It "Should not export the pop helper function" {
        Get-Command -Module PopError | Where-Object Name -eq "Pop-CrescendoError" | Should -BeNullOrEmpty
    }

    It "Should not export the push helper function" {
        Get-Command -Module PopError | Where-Object Name -eq "Push" | Should -BeNullOrEmpty
    }

}