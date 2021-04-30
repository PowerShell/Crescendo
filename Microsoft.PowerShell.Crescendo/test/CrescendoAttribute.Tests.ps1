Describe "Attribute Tests" {
    BeforeAll {
        # Create a crescendo module
        $ModuleName = "tModule"
        $ModulePath = Join-Path -Path $TESTDRIVE -ChildPath $ModuleName
        $SamplePath = Join-Path -Path $PSScriptRoot -ChildPath .. -AdditionalChildPath Samples
        $SampleDir = (Resolve-Path $SamplePath).Path
        Export-CrescendoModule -ModuleName "${ModulePath}" -Config "${SampleDir}/*.json"
        $ModuleInfo = Import-Module "${ModulePath}.psd1" -Force -PassThru
        $mFunctions = Get-Command -Module tModule | Where-Object { $_.CommandType -eq "Function" }
        $configs = (Get-ChildItem "${SampleDir}/*.json").Foreach({Get-Content $_ | ConvertFrom-Json})
        $functionTestCases = $mFunctions.ForEach({@{ Name = $_.Name; Function = $_ }})
        $elevationTestCases = $mFunctions.Foreach({@{ Name = $_.Name; Function = $_; Configuration = $configs }})
    }

    AfterAll {
        Remove-Module $ModuleName
    }

    Context "Command Parameter can accept two different types of objects" {

        It "can accept a string for a function" {
            function global:get-test1 { }
            $result = Test-IsCrescendoCommand -Command get-test1
            Remove-Item function:get-test1
            $result | Should -Not -BeNullOrEmpty
            $result.IsCrescendoCommand | Should -Be $false
        }

        It "can accept a FunctionInfo for a function" {
            function get-test1 { }
            $result = Test-IsCrescendoCommand -Command (Get-Command -Name get-test1)
            $result | Should -Not -BeNullOrEmpty
            $result.IsCrescendoCommand | Should -Be $false
        }

        It "can accept a piped string for a function" {
            function global:get-test1 { }
            $result = "get-test1" | Test-IsCrescendoCommand
            Remove-Item function:get-test1
            $result | Should -Not -BeNullOrEmpty
            $result.IsCrescendoCommand | Should -Be $false
        }

        It "can accept a piped FunctionInfo for a function" {
            function get-test1 { }
            $result = Get-Command -Name get-test1 | Test-IsCrescendoCommand
            $result | Should -Not -BeNullOrEmpty
            $result.IsCrescendoCommand | Should -Be $false
        }

        It "can accept a collection" {
            function global:get-test1 { }
            function get-test2 { }
            $result = Test-IsCrescendoCommand -Command "get-test1",(Get-Command -name get-test2)
            remove-item function:get-test1
            $result.Count | Should -Be 2
            $result[0].IsCrescendoCommand | Should -Be $false
            $result[1].IsCrescendoCommand | Should -Be $false
        }

    }

    Context "Basic Functionality" {
        It "Identifies the function '<Name>' as being created by Crescendo" -TestCases $functionTestCases {
            param ( [string]$Name, [System.Management.Automation.FunctionInfo]$Function)
            $result = $Function | Test-IsCrescendoCommand 
            $result.IsCrescendoCommand | Should -Be $true
        }

        It "Properly identifies whether the function '<Name>' will elevate" -TestCases $elevationTestCases {
            param ( [string]$Name, [System.Management.Automation.FunctionInfo]$Function, [pscustomobject[]]$Configuration)
            $config = $Configuration.Where({$cmdletName = "{0}-{1}" -f $_.Verb,$_.Noun; $cmdletName -eq $Name})
            $IsElevated = $config.Elevation -ne $null ? $true : $false
            $observed = $Function | Test-IsCrescendoCommand
            $observed.RequiresElevation | Should -Be $IsElevated
        }
    }

    Context "Test-IsCrescendoCommand" {
        It "Will not find crescendo commands if the attribute is not present" {
            function get-localtest { }
            $observed = Get-Command -Name get-localtest | Test-IsCrescendoCommand
            $observed.Module | Should -BeNullOrEmpty
            $observed.Source | Should -BeNullOrEmpty
            $observed.IsCrescendoCommand | Should -Be $false
            $observed.RequiresElevation | Should -Be $false
        }
    }

    Context "Error Conditions" {
        BeforeAll {
            $cmdName = "Get-Command" # a binary cmdlet that is guaranteed to be present
            $result = Get-Command -Name $cmdName | Test-IsCrescendoCommand -ErrorAction SilentlyContinue -ErrorVariable badfunction
        }
        It "Will properly error when testing a non-function" {
            #$cmdName = "Get-Command" # a binary cmdlet that is guaranteed to be present
            #$result = Get-Command -Name $cmdName | Test-IsCrescendoCommand -ErrorAction SilentlyContinue -ErrorVariable badfunction
            $result | Should -BeNullOrEmpty
            $badfunction.FullyQualifiedErrorId | Should -Be "Microsoft.PowerShell.Commands.WriteErrorException,Test-IsCrescendoCommand"
        }

        It "Will properly identify the target object" {
            $badfunction.TargetObject | Should -Be $cmdName
        }
    }
}