Describe "Create proxy from Schema" -tags CI {
    BeforeAll {
        $proxies = Get-ChildItem "${PSScriptRoot}/../Samples" -Filter *.json
        $testCases = @()
        foreach ( $proxy in $proxies ) {
            $platforms = (Get-Content $proxy.FullName | ConvertFrom-Json | ForEach-Object {$_.Commands} ).Platform
            if ( $platforms -eq $null ) {
                $platforms = "Windows","Linux","MacOS"
            }
            $testCases += @{ Path = $proxy.FullName; Name = $proxy.BaseName; Platform = $platforms }
        }
    }

    It "Can create a proxy from sample '<name>'" -TestCases $testCases {
        param ( $Path, $Name, $Platform )
        $proxy = Import-CommandConfiguration $Path
        $proxy | Should -Not -BeNullOrEmpty
        $proxy.Verb | Should -Not -BeNullOrEmpty
        $proxy.Noun| Should -Not -BeNullOrEmpty
        $proxy.Platform | Should -Be $Platform
        $proxy.OriginalName | Should -Not -BeNullOrEmpty
        (Get-Verb $proxy.Verb).Verb | Should -Be $proxy.Verb
    }

    Context "Create a proxy module from a collection of json files" {
        BeforeAll {
            $modulePath = "${TestDrive}/ProxyModule"
            Export-CrescendoModule -ModuleName $modulePath -ConfigurationFile $proxies
            $Parser = [System.Management.Automation.Language.Parser]
            $tokens = $errors = $null
            $ast = $Parser::ParseFile("${modulePath}.psm1", [ref]$tokens, [ref]$errors)
            $functionNames = $proxies.ForEach({ get-content $_ | convertfrom-json }).Foreach({$_.Commands}).ForEach({ "{0}-{1}" -f $_.Verb,$_.Noun})
        }

        It "Can create a parsable module" {
            $errors | Should -BeNullOrEmpty
        }

        It "Created the correct number of proxies" {
            $exportedFunctionCount = (Get-Module -ListAvailable "${modulePath}.psd1").ExportedFunctions.Count
            $exportedFunctionCount | Should -Be $proxies.Count
        }

        It "Created a module with all the supplied proxies" {
            $exportedFunctions = (Get-Module -ListAvailable "${modulePath}.psd1").ExportedFunctions.Keys
            $exportedFunctions | Should -Be $functionNames
        }

    }
    Context "Handling multiple configurations in a single file" {
        BeforeAll {
            $modulePath = "${TestDrive}/MultiModule"
            $configPath = Join-Path -Path $PSScriptRoot -ChildPath assets -AdditionalChildPath MultiConfig.crescendo.json
            $functionNames = (get-content $configPath | convertfrom-json).Foreach({$_.Commands}).ForEach({ "{0}-{1}" -f $_.Verb,$_.Noun})
            Export-CrescendoModule -ModuleName $modulePath -ConfigurationFile $configPath
            $Parser = [System.Management.Automation.Language.Parser]
            $tokens = $perrors = $null
            $ast = $Parser::ParseFile("${modulePath}.psm1", [ref]$tokens, [ref]$perrors)
            # exclude the two helper functions for managing errors
            $funcs = $ast.findall({
                $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] -and
                $args[0].Parent -isnot [System.Management.Automation.Language.FunctionMemberAst] -and
                $args[0].Name -notmatch "Push-CrescendoNativeError|Pop-CrescendoNativeError"
                },$false)
        }

        It "Creates a proper module" {
            $perrors | Should -BeNullOrEmpty
        }

        It "Creates the right number of functions" {
            $funcs.count | Should -Be $functionNames.Count
        }

        It "Creates the right functions" {
            $funcs.Name | Should -Be $functionNames
        }
        It "Creates the right number of aliases (6)" {
            $expected = @(
                "Set-Alias -Name 'cf1gt1a' -Value 'Get-Thing1'"
                "Set-Alias -Name 'cf1gt1b' -Value 'Get-Thing1'"
                "Set-Alias -Name 'cf2gt2a' -Value 'Get-Thing2'"
                "Set-Alias -Name 'cf2gt2b' -Value 'Get-Thing2'"
                "Set-Alias -Name 'cf3gt3a' -Value 'Get-Thing3'"
                "Set-Alias -Name 'cf3gt3b' -Value 'Get-Thing3'"
            )
            $observed =  $ast.findall({$args[0] -is [System.Management.Automation.Language.CommandAst]},$false).extent.text
            $observed | Should -Be $expected
        }
    }

    Context "Proxies are parsable on Windows PowerShell" {
        BeforeAll {
            if (! $IsWindows) {
                return
            }
            $modulePath = "${TestDrive}/ProxyModule.psm1"
            Export-CrescendoModule -ModuleName $modulePath -ConfigurationFile $proxies
        }

        It "PowerShell 5 can parse the module" -skip:$(!$IsWindows) {
            $str = '$t = $e = $null
            $ast = [System.Management.Automation.Language.Parser]::ParseFile(''' + $modulePath + ''',[ref]$t,[ref]$e)
            $e'
            $result = powershell.exe -c $str
            $result | Should -BeNullOrEmpty
        }
    }
}
