Describe "Create proxy from Schema" {
    BeforeAll {
        $schemas = Get-ChildItem "${PSScriptRoot}/../Samples" -Filter *.json
        $testCases = $schemas | ForEach-Object { @{ Path = $_.FullName; Name = $_.BaseName } }
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
}