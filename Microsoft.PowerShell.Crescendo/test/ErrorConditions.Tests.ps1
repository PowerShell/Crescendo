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
}