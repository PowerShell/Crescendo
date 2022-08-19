# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Describe "Error Condition Tests" -Tag CI {
    Context "Output Handler Faults" {
        It "will report a syntax error" {
            $configuration = Import-CommandConfiguration -file $PSScriptRoot/assets/HandlerFault1.json -ErrorVariable handlerFault -ErrorAction SilentlyContinue
            $configuration | Should Not BeNullOrEmpty
            $handlerFault | Should Not BeNullOrEmpty
            $handlerFault.TargetObject.Count | Should Be 1
            $handlerFault.TargetObject[0].ErrorId | Should Be "MissingEndCurlyBrace"
        }
        It "will report multiple syntax errors" {
            $configuration = Import-CommandConfiguration -file $PSScriptRoot/assets/HandlerFault2.json -ErrorVariable handlerFault -ErrorAction SilentlyContinue
            $configuration | Should Not BeNullOrEmpty
            $handlerFault | Should Not BeNullOrEmpty
            $handlerFault.TargetObject.Count | Should Be 2
            $handlerFault.TargetObject[0].ErrorId | Should Be "ExpectedValueExpression"
            $handlerFault.TargetObject[1].ErrorId | Should Be "MissingEndCurlyBrace"
        }
        It "Will properly identify the parameter set" {
            $configuration = Import-CommandConfiguration -file $PSScriptRoot/assets/HandlerFault3.json -ErrorVariable handlerFault -ErrorAction SilentlyContinue
            $configuration | Should Not BeNullOrEmpty
            $handlerFault | Should Not BeNullOrEmpty
            $handlerFault.Exception.Message | Should Match "pset1"
        }
    }

    Context "Native output to stderr is redirected" {
        BeforeAll {
            if ( $IsWindows ) {
                return
            }
            $moduleName = [Guid]::NewGuid().ToString("n")
            Export-CrescendoModule -ConfigurationFile "${PSScriptRoot}/assets/ls.proxy.json" -ModuleName "${TESTDRIVE}/${ModuleName}"
            Import-Module "${TESTDRIVE}/${moduleName}.psd1"
            Invoke-filelistproxy2 -path "${TESTDRIVE}/ThisFileDoesNotExist" -ErrorAction SilentlyContinue -ErrorVariable crescendoError
            Remove-Module ${ModuleName}
        }

        It "The default output handler can emit an error" -skip:($IsWindows) {
            $crescendoError | Should -Not -BeNullOrEmpty
        }

        It "The default output handler can emit the proper number of errors" -skip:($IsWindows) {
            $crescendoError.Count | Should -Be 1
        }

        It "The default output handler can emit an ErrorRecord" -skip:($IsWindows) {
            $crescendoError[0] | Should -BeOfType [System.Management.Automation.ErrorRecord]
        }

        It "The default output handler will emit the proper error message" -skip:($IsWindows) {
            "$crescendoError" | Should -Match "ThisFileDoesNotExist"
        }
    }
}