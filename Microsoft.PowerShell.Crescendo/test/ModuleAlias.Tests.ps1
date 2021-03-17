Describe "Aliases are created and work correctly" -Tag CI {
    BeforeAll {
        $modName = [guid]::NewGuid()
        Export-CrescendoModule -ModuleName "${TESTDRIVE}/${modName}" -ConfigurationFile "${PSScriptRoot}/assets/Alias.Proxy.json"
        $aliasModule = Import-Module -Name "${TESTDRIVE}/${modName}.psm1" -PassThru
    }
    AfterAll {
        Remove-Module ${aliasModule}
    }

    It "Will create the proper count of aliases" {
        $aliasModule.ExportedAliases.Count | Should -Be 2
    }

    It "Will create the proper aliases" {
        $observedAliases = $aliasModule.ExportedAliases.Keys| Sort-Object
        $observedAliases | Should -Be @("Get-DD","Get-DD2")
    }

    It "The aliases will point to the correct function" {
        $aliasModule.ExportedAliases['Get-DD'].ResolvedCommand.Name | Should -Be "Invoke-GetDate"
        $aliasModule.ExportedAliases['Get-DD2'].ResolvedCommand.Name | Should -Be "Invoke-GetDate"
    }

}