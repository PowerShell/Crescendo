Describe "Create proxy from Schema" -tags CI {
    BeforeAll {
        $proxies = Get-ChildItem "${PSScriptRoot}/../Samples" -Filter *.json
        $testCases = $proxies | ForEach-Object { @{ Path = $_.FullName; Name = $_.BaseName } }
    }

    It "Can create a proxy from sample '<name>'" -TestCases $testCases {
        param ( $Path, $Name )
        $proxy = Import-CommandConfiguration $Path
        $proxy | Should -Not -BeNullOrEmpty
        $proxy.Verb | Should -Not -BeNullOrEmpty
        $proxy.Noun| Should -Not -BeNullOrEmpty
        $proxy.OriginalName | Should -Not -BeNullOrEmpty
        (Get-Verb $proxy.Verb).Verb | Should -Be $proxy.Verb
    }

    Context "Create a proxy module from a collection of json files" {
        BeforeAll {
            $modulePath = "${TestDrive}/ProxyModule.psm1"
            Export-CrescendoModule -ModuleName $modulePath -ConfigurationFile $proxies
            $Parser = [System.Management.Automation.Language.Parser]
            $tokens = $errors = $null
            $ast = $Parser::ParseFile($modulePath, [ref]$tokens, [ref]$errors)
            $functionNames = $proxies.ForEach({ get-content $_ | convertfrom-json }).ForEach({ "{0}-{1}" -f $_.Verb,$_.Noun})
        }

        It "Can created a parsable module" {
            $errors | Should -BeNullOrEmpty
        }

        It "Created the correct number of proxies" {
            $astFunctionCount = $ast.findall({$args[0] -is [system.management.automation.language.functiondefinitionast]},$true).Count
            $astFunctionCount | Should -Be $proxies.Count
        }

        It "Created a module with all the supplied proxies" {
            $astFunctions = $ast.findall({$args[0] -is [system.management.automation.language.functiondefinitionast]},$true).Name
            $astFunctions | Should -Be $functionNames
        }

        It "Created the correct Export-ModuleMember line" {
            $exportAst = $ast.FindAll({$args[0] -is [System.management.automation.language.commandast] -and $args[0].GetCommandName() -eq "Export-ModuleMember"},$true)
            $observed = $exportAst.CommandElements.Elements.Value
            $observed | Should -Be $functionNames
        }
    }
    Context "Proxies are parsable on Windows PowerShell" {
        BeforeAll {
            $modulePath = "${TestDrive}/ProxyModule.psm1"
            Export-CrescendoModule -ModuleName $modulePath -ConfigurationFile $proxies
        }

        It "PowerShell 5 can parse the module" -skip:$(!$IsWindows) {
            $result = powershell.exe -c '
            $t = $e = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile(''$modulePath'',[ref]$t,[ref]$e)
            $e.Count'
            $result | Should -Be 0
        }
    }
}
