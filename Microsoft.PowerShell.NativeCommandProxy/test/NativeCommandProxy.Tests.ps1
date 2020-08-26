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

    Context "Proxy function content" {
        It "correctly creates the proxy function code" {
            $pc = New-ProxyCommand -Verb $verb -Noun $noun
            $pc.OriginalName = "/bin/ls"
            $s = $pc.ToString()
            $expectedResult = "Function ${verb}-${noun}" + @'

{
[CmdletBinding()]

param(    )

BEGIN {
    $__PARAMETERMAP = @{}
    $__outputHandlers = @{ Default = { $args[0] } }
}
PROCESS {
    $__commandArgs = @()
    if ($PSBoundParameters["Debug"]){wait-debugger}
    $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $PSBoundParameters[$_.Name]}).ForEach({$PSBoundParameters[$_.Name] = [switch]::new($false)})
    $__boundparms = $PSBoundParameters
    foreach ($paramName in $PSBoundParameters.Keys|Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {
        $value = $PSBoundParameters[$paramName]
        $param = $__PARAMETERMAP[$paramName]
        if ($param) {
            if ( $value -is [switch] ) { $__commandArgs += $value.IsPresent ? $param.OriginalName : $param.DefaultMissingValue }
            elseif ( $param.NoGap ) { $__commandArgs += "{0}""{1}""" -f $param.OriginalName, $value }
            else { $__commandArgs += $param.OriginalName; $__commandArgs += $value |Foreach-Object {$_}}
        }
    }
    $__commandArgs = $__commandArgs|Where-Object {$_}
    if ($PSBoundParameters["Debug"]){wait-debugger}
    if ( $PSBoundParameters["Verbose"]) {
         Write-Verbose -Verbose -Message /bin/ls
         $__commandArgs | Write-Verbose -Verbose
    }
    if ( $PSCmdlet.ShouldProcess("/bin/ls")) {
        $result = & "/bin/ls" $__commandArgs
    $__handler = $__outputHandlers[$PSCmdlet.ParameterSetName]
    if (! $__handler ) {
        $__handler = $__outputHandlers["Default"]
    }
    & $__handler $result
    }
  }

<#
.SYNOPSIS


.DESCRIPTION See help for /bin/ls

#>
}

'@
            $s | Should -Be $expectedResult
        }

        It "correctly creates the proxy function code with a parameter" {
            $pc = New-ProxyCommand -Verb $verb -Noun $noun
            $pc.OriginalName = "/bin/ls"
            $pc.Parameters.Add((New-ParameterInfo -Name "pName" -OriginalName "--OriginalName"))
            $s = $pc.ToString()
            $expectedResult = "Function ${verb}-${noun}" + @'

{
[CmdletBinding()]

param(
[Parameter()]
[object]$pName
    )

BEGIN {
    $__PARAMETERMAP = @{
        pName = @{ OriginalName = '--OriginalName'; OriginalPosition = '0'; Position = '2147483647'; ParameterType = [object]; NoGap = $False }
    }

    $__outputHandlers = @{ Default = { $args[0] } }
}
PROCESS {
    $__commandArgs = @()
    if ($PSBoundParameters["Debug"]){wait-debugger}
    $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $PSBoundParameters[$_.Name]}).ForEach({$PSBoundParameters[$_.Name] = [switch]::new($false)})
    $__boundparms = $PSBoundParameters
    foreach ($paramName in $PSBoundParameters.Keys|Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {
        $value = $PSBoundParameters[$paramName]
        $param = $__PARAMETERMAP[$paramName]
        if ($param) {
            if ( $value -is [switch] ) { $__commandArgs += $value.IsPresent ? $param.OriginalName : $param.DefaultMissingValue }
            elseif ( $param.NoGap ) { $__commandArgs += "{0}""{1}""" -f $param.OriginalName, $value }
            else { $__commandArgs += $param.OriginalName; $__commandArgs += $value |Foreach-Object {$_}}
        }
    }
    $__commandArgs = $__commandArgs|Where-Object {$_}
    if ($PSBoundParameters["Debug"]){wait-debugger}
    if ( $PSBoundParameters["Verbose"]) {
         Write-Verbose -Verbose -Message /bin/ls
         $__commandArgs | Write-Verbose -Verbose
    }
    if ( $PSCmdlet.ShouldProcess("/bin/ls")) {
        $result = & "/bin/ls" $__commandArgs
    $__handler = $__outputHandlers[$PSCmdlet.ParameterSetName]
    if (! $__handler ) {
        $__handler = $__outputHandlers["Default"]
    }
    & $__handler $result
    }
  }

<#
.SYNOPSIS


.DESCRIPTION See help for /bin/ls

.PARAMETER pName




#>
}

'@
            $s | Should -Be $expectedResult
        }
    }
}
