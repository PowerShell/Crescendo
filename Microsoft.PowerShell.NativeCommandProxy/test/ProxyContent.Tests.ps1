Describe "The help content for the proxy function is correct" {
    BeforeAll {
        invoke-expression (Import-CommandConfiguration assets/FullProxy.json).ToString()
        $commandInfo = Get-Command invoke-thing
        $helpInfo = Get-Help -Full Invoke-Thing
        $proxyData = Get-Content "${PSScriptRoot}/assets/FullProxy.json" | ConvertFrom-Json        
    }
    AfterAll {
        remove-item function:"invoke-thing"
    }
    
    Context "The help content is correct" {
        It "The name is correct" {
            $name = @($proxyData.Verb;$proxyData.Noun) -join "-"
            $helpInfo.Name | Should -BeExactly $name
        }
        It "The syntax statement is correct" {
            [string]$syntax = (Get-Command Invoke-Thing -Syntax).Trim()
            [string]$helpSyntax = ($helpInfo.Syntax | out-string).trim()
            $helpSyntax | Should -Be $syntax
        }
        It "The description is correct" {
            $helpInfo.description.Text | Should -BeExactly $proxyData.description
        }
        It "The synopsis is correct" {
            $helpInfo.synopsis | Should -BeExactly $proxyData.Usage.Synopsis
        }
        It "The help links are correct" {
            $helpLinks = ($helpInfo.RelatedLinks|out-string).trim()
            $expectedLinks = ($proxyData.HelpLinks|out-string).trim()
            $helpLinks | Should -Be $expectedLinks
        }
        It "The parameter count is correct" {
            $helpParameterCount = $helpInfo.Parameters.Parameter.count
            $expectedCount = $proxyData.Parameters.Count
            $helpParameterCount | Should -Be $expectedCount
        }
    }

    Context "The command info data" {
        BeforeAll {
            $testCases = @(
                @{ Name = "Name"; value = $commandInfo.Name; expectedValue = "Invoke-Thing" }   
                @{ Name = "Verb"; value = $commandInfo.Verb; expectedValue = $proxyData.Verb }
                @{ Name = "Noun"; value = $commandInfo.Noun; expectedValue = $proxyData.Noun }
                @{ Name = "Parameter1Name"; value = $commandinfo.parameters['Parameter1'].Name; expectedValue = $proxyData.Parameters[0].Name }
                @{ Name = "Parameter1Alias"; value = $commandinfo.parameters['Parameter1'].Aliases; expectedValue = $proxyData.Parameters[0].aliases }
                @{ Name = "Parameter1IsMandatory"; value = $commandinfo.parameters['Parameter1'].Attributes.Mandatory; expectedValue = $proxyData.Parameters[0].Mandatory }
                @{ Name = "Parameter1ValidValues"; value = $commandinfo.parameters['Parameter1'].Attributes.ValidValues; expectedValue = @("one","two") }
                @{ Name = "Parameter1ValidLength"; value = $commandInfo.parameters['Parameter1'].attributes[2].Foreach({$_.MinLength;$_.MaxLength}); expectedValue = @(1,10) }
                @{ Name = "Parameter1SetName"; value = $commandinfo.parameters['Parameter1'].Attributes[0].parametersetname; expectedValue = $proxyData.parameters[0].ParameterSetName }
                @{ Name = "Parameter2SetName"; value = $commandinfo.parameters['Parameter2'].Attributes[0].parametersetname; expectedValue = $proxyData.parameters[1].ParameterSetName }
                @{ Name = "Parameter2Name"; value = $commandinfo.parameters['Parameter2'].Name; expectedValue = $proxyData.Parameters[1].Name }
                @{ Name = "Parameter2Alias"; value = $commandinfo.parameters['Parameter2'].Aliases; expectedValue = $proxyData.Parameters[1].aliases }
                @{ Name = "Parameter2IsMandatory"; value = $commandinfo.parameters['Parameter2'].Attributes.Mandatory; expectedValue = $proxyData.Parameters[1].Mandatory }
            )

        }
        It "Property '<Name>' should be '<expectedValue>'" -TestCases $testCases {
            param ( [string]$name, [string]$value, [string]$expectedValue )
            $value | Should -Be $expectedValue
        }

    }
}