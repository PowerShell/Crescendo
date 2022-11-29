Describe "Packaging tests" {
    Context "Schema Tests" {
        BeforeAll {
            $schemaBase = "https://aka.ms/PowerShell/Crescendo/Schemas"
            $fileList = Get-ChildItem -File -Recurse "${PSScriptRoot}/.." | Where-Object { $_.Extension -eq ".json" -and (Select-String '"\$schema"' $_.FullName) }
            $testCases = $fileList |
                Foreach-Object {
                    $json = Get-Content $_.fullname | ConvertFrom-Json
                    @{
                        FullName = $_.FullName -Replace ".*/Microsoft.PowerShell.Crescendo/"
                        JSON = $json
                        SchemaUrl = $_.FullName -match "ArgumentTransform|ls.poperror" ? "${schemaBase}/2022-06" : "${schemaBase}/2021-11" 
                    }
                }
            $schemas = @{ SchemaUrl = 'https://aka.ms/PowerShell/Crescendo/Schemas/2021-11' },
                @{ SchemaUrl = 'https://aka.ms/PowerShell/Crescendo/Schemas/2022-06'}
        }

        It "'<FullName>' references schema '<SchemaUrl>" -TestCases $testCases {
            param ([string]$FullName, [object]$JSON, [string]$SchemaUrl )
            $JSON.'$schema' | Should -Be $SchemaUrl
        }

        It "<SchemaUrl>' is active" -TestCases @($schemas) {
            param ( $SchemaUrl )
            $schema = Invoke-RestMethod $SchemaUrl
            $schema.title | Should -Be "JSON schema for PowerShell Crescendo files"
        }
    }

    Context "Module Manifest" {
        BeforeAll {
            $ModuleInfo = Get-Module Microsoft.PowerShell.Crescendo
        }

        It "The module manifest includes the correct ProjectUri" {
            $ModuleInfo.PrivateData.PSData.ProjectUri | Should -Be "https://github.com/PowerShell/Crescendo"
        }

        It "The module manifest includes the correct LicenseUri" {
            $ModuleInfo.PrivateData.PSData.LicenseUri | Should -Be "https://github.com/PowerShell/Crescendo/blob/master/LICENSE"
        }

        It "The module should not require license acceptance" {
            $ModuleInfo.PrivateData.PSData.RequireLicenseAcceptance | Should -Be $false
        }

        It "The module manifest includes the correct Tags" {
            $ModuleInfo.PrivateData.PSData.Tags | Should -Be @('Crescendo','Software Generation')
        }
    }

}

