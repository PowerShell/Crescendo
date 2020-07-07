Describe "Unit tests for NativeCommandProxy" {
    BeforeAll {
        $moduleName = "Microsoft.PowerShell.NativeCommandProxy"
        $moduleManifest = "${moduleName}.psd1"
        $noun = [guid]::newguid().ToString("N")
        $verb = 'Get'
        $modulePath = [System.Io.Path]::combine($PSScriptRoot,"..","src","Microsoft.PowerShell.NativeCommandProxy.psd1")
        $moduleManifestPath = (Resolve-Path $modulePath).Path
        import-module $moduleManifestPath
        
    }
    AfterAll {
        Remove-Module $moduleName
    }
    It "is possible to create a command object" {
        $pc = New-ProxyCommand -Verb $verb -Noun $noun
        $pc.Verb | Should -BeExactly $verb
        $pc.Noun | Should -BeExactly $noun
    }
    It "is possible to create add a parameter to a command object" {
        $pc = New-ProxyCommand -Verb $verb -Noun $noun
        $pc.Parameters.Add((New-ParameterInfo -Name "pName" -OriginalName "--OriginalName"))
        $pc.Parameters[0].Name | Should -BeExactly pName
        $pc.Parameters[0].OriginalName | Should -BeExactly '--OriginalName'
    }
}
