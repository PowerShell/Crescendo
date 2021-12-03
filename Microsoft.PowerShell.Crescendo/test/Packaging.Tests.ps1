Describe "Packaging tests" {
    BeforeAll {
        $fileList = Get-ChildItem -File -Recurse "${PSScriptRoot}/.." | Where-Object { $_.Extension -eq ".json" -and (Select-String '"\$schema"' $_.FullName) }
        $testCases = $fileList |
            Foreach-Object {
                $json = Get-Content $_.fullname | ConvertFrom-Json
                @{ FullName = $_.FullName -Replace ".*/Microsoft.PowerShell.Crescendo/"; JSON = $json }
            }
        $SchemaUrl = 'https://aka.ms/PowerShell/Crescendo/Schemas/2021-11'
    }

    It "'<FullName>' references schema '$SchemaUrl'" -TestCases $testCases {
        param ([string]$FullName, [object]$JSON )
        $JSON.'$schema' | Should -Be $SchemaUrl
    }
}
