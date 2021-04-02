Describe "Create proxy from Schema" -tags CI {
    BeforeAll {
        $proxies = Get-ChildItem "${PSScriptRoot}/../Samples" -Filter *.json
        $testCases = @()
        foreach ( $proxy in $proxies ) {
            $platforms = (Get-Content $proxy.FullName | ConvertFrom-Json ).Platform
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
            $functionNames = $proxies.ForEach({ get-content $_ | convertfrom-json }).ForEach({ "{0}-{1}" -f $_.Verb,$_.Noun})
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
    Context "Proxies are parsable on Windows PowerShell" {
        BeforeAll {
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
