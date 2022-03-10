# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License
# this contains code common for all generators
# OM VERSION 1.2
# =========================================================================
using namespace System.Collections.Generic
class UsageInfo { # used for .SYNOPSIS of the comment-based help
    [string]$Synopsis
    [bool]$SupportsFlags
    [bool]$HasOptions
    hidden [string[]]$OriginalText

    UsageInfo() { }
    UsageInfo([string] $synopsis)
    {
        $this.Synopsis = $synopsis
    }

    [string]ToString() #  this is to be replaced with actual generation code
    {
        return ((".SYNOPSIS",$this.synopsis) -join "`n")
    }
}

class ExampleInfo { # used for .EXAMPLE of the comment-based help
    [string]$Command # ps-command
    [string]$OriginalCommand # original native tool command
    [string]$Description

    ExampleInfo() { }

    ExampleInfo([string]$Command, [string]$OriginalCommand, [string]$Description)
    {
        $this.Command = $Command
        $this.OriginalCommand = $OriginalCommand
        $this.Description = $description
    }

    [string]ToString() #  this is to be replaced with actual generation code
    {
        $sb = [text.stringbuilder]::new()
        $sb.AppendLine(".EXAMPLE")
        $sb.AppendLine("PS> " + $this.Command)
        $sb.AppendLine("")
        $sb.AppendLine($this.Description)
        if ($this.OriginalCommand) {
            $sb.AppendLine("Original Command: " + $this.OriginalCommand)
        }
        return $sb.ToString()
    }
}


class ParameterInfo {
    [string]$Name # PS-function name
    [string]$OriginalName # original native parameter name

    [string]$OriginalText
    [string]$Description
    [string]$DefaultValue
    # some parameters are -param or +param which can be represented with a switch parameter
    # so we need way to provide for this
    [string]$DefaultMissingValue
    # this is in case that the parameters apply before the OriginalCommandElements
    [bool]$ApplyToExecutable
    [string]$ParameterType = 'object' # PS type

    [string[]]$AdditionalParameterAttributes

    [bool] $Mandatory
    [string[]] $ParameterSetName
    [string[]] $Aliases
    [int] $Position = [int]::MaxValue
    [int] $OriginalPosition
    [bool] $ValueFromPipeline
    [bool] $ValueFromPipelineByPropertyName
    [bool] $ValueFromRemainingArguments
    [bool] $NoGap # this means that we need to construct the parameter as "foo=bar"

    ParameterInfo() {
        $this.Position = [int]::MaxValue
    }
    ParameterInfo ([string]$Name, [string]$OriginalName)
    {
        $this.Name = $Name
        $this.OriginalName = $OriginalName
        $this.Position = [int]::MaxValue
    }

    [string]ToString() #  this is to be replaced with actual generation code
    {
        if ($this.Name -eq [string]::Empty) {
            return $null
        }
        $sb = [System.Text.StringBuilder]::new()
        if ( $this.AdditionalParameterAttributes )
        {
            foreach($s in $this.AdditionalParameterAttributes) {
                $sb.AppendLine($s)
            }
        }

        if ( $this.Aliases ) {
            $paramAliases = $this.Aliases -join "','"
            $sb.AppendLine("[Alias('" + $paramAliases + "')]")
        }

        # TODO: This logic does not handle parameters in multiple sets correctly

        $elements = @()
        if ( $this.ParameterSetName.Count -eq 0) {
            $sb.Append('[Parameter(')
            if ( $this.Position -ne [int]::MaxValue ) { $elements += "Position=" + $this.Position }
            if ( $this.ValueFromPipeline ) { $elements += 'ValueFromPipeline=$true' }
            if ( $this.ValueFromPipelineByPropertyName ) { $elements += 'ValueFromPipelineByPropertyName=$true' }
            if ( $this.Mandatory ) { $elements += 'Mandatory=$true' }
            if ( $this.ValueFromRemainingArguments ) { $elements += 'ValueFromRemainingArguments=$true' }
            if ($elements.Count -gt 0) { $sb.Append(($elements -join ",")) }
            $sb.AppendLine(')]')
        }
        else {
            foreach($parameterSetName in $this.ParameterSetName) {
                $sb.Append('[Parameter(')
                if ( $this.Position -ne [int]::MaxValue ) { $elements += "Position=" + $this.Position }
                if ( $this.ValueFromPipeline ) { $elements += 'ValueFromPipeline=$true' }
                if ( $this.ValueFromPipelineByPropertyName ) { $elements += 'ValueFromPipelineByPropertyName=$true' }
                if ( $this.ValueFromRemainingArguments ) { $elements += 'ValueFromRemainingArguments=$true' }
                if ( $this.Mandatory ) { $elements += 'Mandatory=$true' }
                $elements += "ParameterSetName='{0}'" -f $parameterSetName
                if ($elements.Count -gt 0) { $sb.Append(($elements -join ",")) }
                $sb.AppendLine(')]')
                $elements = @()
            }
        }

        #if ( $this.ParameterSetName.Count -gt 1) {
        #    $this.ParameterSetName.ForEach({$sb.AppendLine(('[Parameter(ParameterSetName="{0}")]' -f $_))})
        #}
        # we need a way to find those parameters which have default values
        # because they need to be added to the command arguments. We can
        # search through the parameters for this attribute.
        # We may need to handle collections as well.
        if ( $null -ne $this.DefaultValue ) {
                $sb.AppendLine(('[PSDefaultValue(Value="{0}")]' -f $this.DefaultValue))
        }
        $sb.Append(('[{0}]${1}' -f $this.ParameterType, $this.Name))
        if ( $this.DefaultValue ) {
            $sb.Append(' = "' + $this.DefaultValue + '"')
        }

        return $sb.ToString()
    }

    [string]GetParameterHelp()
    {
        $parameterSb = [System.Text.StringBuilder]::new()
        $null = $parameterSb.Append(".PARAMETER ")
        $null = $parameterSb.AppendLine($this.Name)
        $null = $parameterSb.AppendLine($this.Description)
        $null = $parameterSb.AppendLine()
        return $parameterSb.ToString()
    }
}

class OutputHandler {
    [string]$ParameterSetName
    [string]$Handler # This is a scriptblock which does the conversion to an object
    [string]$HandlerType # Inline, Function, or Script
    [bool]$StreamOutput # this indicates whether the output should be streamed to the handler
    OutputHandler() {
        $this.HandlerType = "Inline" # default is an inline script
    }
    [string]ToString() {
        $s = '        '
        if ($this.HandlerType -eq "Inline") {
            $s += '{0} = @{{ StreamOutput = ${1}; Handler = {{ {2} }} }}' -f $this.ParameterSetName, $this.StreamOutput, $this.Handler
        }
        elseif ($this.HandlerType -eq "Script") {
            $s += '{0} = @{{ StreamOutput = ${1}; Handler = "${{PSScriptRoot}}/{2}" }}' -f $this.ParameterSetName, $this.StreamOutput, $this.Handler
        }
        else { # function
            $s += '{0} = @{{ StreamOutput = ${1}; Handler = ''{2}'' }}' -f $this.ParameterSetName, $this.StreamOutput, $this.Handler
        }
        return $s
    }
}

class Elevation {
    [string]$Command
    [List[ParameterInfo]]$Arguments
}

class Command {
    [string]$Verb # PS-function name verb
    [string]$Noun # PS-function name noun


    [string]$OriginalName # e.g. "cubectl get user" -> "cubectl"
    [string[]]$OriginalCommandElements # e.g. "cubectl get user" -> "get", "user"
    [string[]]$Platform # can be any (or all) of "Windows","Linux","MacOS"

    [Elevation]$Elevation

    [string[]] $Aliases
    [string] $DefaultParameterSetName
    [bool] $SupportsShouldProcess
    [string] $ConfirmImpact
    [bool] $SupportsTransactions
    [bool] $NoInvocation # certain scenarios want to use the generated code as a front end. When true, the generated code will return the arguments only.

    [string]$Description
    [UsageInfo]$Usage
    [List[ParameterInfo]]$Parameters
    [List[ExampleInfo]]$Examples
    [string]$OriginalText
    [string[]]$HelpLinks

    [OutputHandler[]]$OutputHandlers

    Command() {
        $this.Platform = "Windows","Linux","MacOS"
    }
    Command([string]$Verb, [string]$Noun)
    {
        $this.Verb = $Verb
        $this.Noun = $Noun
        $this.Parameters = [List[ParameterInfo]]::new()
        $this.Examples = [List[ExampleInfo]]::new()
        $this.Platform = "Windows","Linux","MacOS"
    }

    [string]GetDescription() {
        if ( $this.Description ) {
            return (".DESCRIPTION",$this.Description -join "`n")
        }
        else {
            return (".DESCRIPTION",("See help for {0}" -f $this.OriginalName))
        }
    }

    [string]GetSynopsis() {
        if ( $this.Description ) {
            return ([string]$this.Usage)
        }
        else { # try running the command with -?
            if ( Get-Command $this.OriginalName -ErrorAction ignore ) {
                try {
                    $origOutput = & $this.OriginalName -? 2>&1
                    $nativeHelpText = $origOutput -join "`n"
                }
                catch {
                    $nativeHelpText = "error running " + $this.OriginalName + " -?."
                }
            }
            else {
                $nativeHelpText = "Could not find " + $this.OriginalName + " to generate help."

            }
            return (".SYNOPSIS",$nativeHelpText) -join "`n"
        }
    }

    [string]GetFunctionHandlers()
    {
        #
        $functionSB = [System.Text.StringBuilder]::new()
        if ( $this.OutputHandlers ) {
            foreach ($handler in $this.OutputHandlers ) {
                if ( $handler.HandlerType -eq "Function" ) {
                    $handlerName = $handler.Handler
                    $functionHandler = Get-Content function:$handlerName -ErrorAction Ignore
                    if ( $null -eq $functionHandler ) {
                        throw "Cannot find function '$handlerName'."
                    }
                    $functionSB.AppendLine($functionHandler.Ast.Extent.Text)
                }
            }
        }
        return $functionSB.ToString()
    }

    [string]ToString()
    {
        return $this.ToString($false)
    }

    [string]GetBeginBlock()
    {
        $sb = [System.Text.StringBuilder]::new()
        $sb.AppendLine("BEGIN {")
        # get the parameter map, this may be null if there are no parameters
        $parameterMap = $this.GetParameterMap()
        if ( $parameterMap ) {
            $sb.AppendLine($parameterMap)
        }
        # Provide for the scriptblocks which handle the output
        if ( $this.OutputHandlers ) {
            $sb.AppendLine('    $__outputHandlers = @{')
            foreach($handler in $this.OutputHandlers) {
                $sb.AppendLine($handler.ToString())
            }
            $sb.AppendLine('    }')
        }
        else {
            $sb.AppendLine('    $__outputHandlers = @{ Default = @{ StreamOutput = $true; Handler = { $input } } }')
        }
        $sb.AppendLine("}") # END BEGIN
        return $sb.ToString()
    }

    [string]GetProcessBlock()
    {
        # construct the command invocation
        # this must exist and should never be null
        # otherwise we won't actually be invoking anything
        $sb = [System.Text.StringBuilder]::new()
        $sb.AppendLine("PROCESS {")
        $sb.AppendLine('    $__boundParameters = $PSBoundParameters')
        # now add those parameters which have default values excluding the ubiquitous parameters
        $sb.AppendLine('    $__defaultValueParameters = $PSCmdlet.MyInvocation.MyCommand.Parameters.Values.Where({$_.Attributes.Where({$_.TypeId.Name -eq "PSDefaultValueAttribute"})}).Name')
        $sb.AppendLine('    $__defaultValueParameters.Where({ !$__boundParameters["$_"] }).ForEach({$__boundParameters["$_"] = get-variable -value $_})')
        $sb.AppendLine('    $__commandArgs = @()')
        $sb.AppendLine('    $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $__boundParameters[$_.Name]}).ForEach({$__boundParameters[$_.Name] = [switch]::new($false)})')
        $sb.AppendLine('    if ($__boundParameters["Debug"]){wait-debugger}')
        if ($this.Parameters.Where({$_.ApplyToExecutable})) {
            $sb.AppendLine('    # look for those parameter values which apply to the executable and must be before the original command elements')
            $sb.AppendLine('    foreach ($paramName in $__boundParameters.Keys|Where-Object {$__PARAMETERMAP[$_].ApplyToExecutable}) {') # take those parameters which apply to the executable
            $sb.AppendLine('        $value = $__boundParameters[$paramName]')
            $sb.AppendLine('        $param = $__PARAMETERMAP[$paramName]')
            $sb.AppendLine('        if ($param) {')
            $sb.AppendLine('            if ( $value -is [switch] ) { $__commandArgs += if ( $value.IsPresent ) { $param.OriginalName } else { $param.DefaultMissingValue } }')
            $sb.AppendLine('            elseif ( $param.NoGap ) { $__commandArgs += "{0}{1}" -f $param.OriginalName, $value }')
            $sb.AppendLine('            else { $__commandArgs += $param.OriginalName; $__commandArgs += $value |Foreach-Object {$_}}')
            $sb.AppendLine('        }')
            $sb.AppendLine('    }')
        }
        # now the original command elements may be added
        if ($this.OriginalCommandElements.Count -ne 0) {
            foreach($element in $this.OriginalCommandElements) {
                # we use single quotes here to reduce injection attacks
                $sb.AppendLine(('    $__commandArgs += ''{0}''' -f $element))
            }
        }
        $sb.AppendLine($this.GetInvocationCommand())

        # add the help
        $help = $this.GetCommandHelp()
        if ($help) {
            $sb.AppendLine($help)
        }
        # finish the block
        $sb.AppendLine("}")
        return $sb.ToString()
    }

    # emit the function, if EmitAttribute is true, the Crescendo attribute will be included
    [string]ToString([bool]$EmitAttribute)
    {
        $sb = [System.Text.StringBuilder]::new()
        # emit any output handlers which are functions,
        # they're available only in the exported module.
        $sb.AppendLine($this.GetFunctionHandlers())

        $sb.AppendLine()
        # get the command declaration
        $sb.AppendLine($this.GetCommandDeclaration($EmitAttribute))
        # We will always provide a parameter block, even if it's empty
        $sb.AppendLine($this.GetParameters())

        # get the begin block
        $sb.AppendLine($this.GetBeginBlock())

        # get the process block
        $sb.AppendLine($this.GetProcessBlock())

        # return $this.Verb + "-" + $this.Noun
        return $sb.ToString()
    }

    [string]GetParameterMap() {
        $sb = [System.Text.StringBuilder]::new()
        if ( $this.Parameters.Count -eq 0 ) {
            return '    $__PARAMETERMAP = @{}'
        }
        $sb.AppendLine('    $__PARAMETERMAP = @{')
        foreach($parameter in $this.Parameters) {
            $sb.AppendLine(('         {0} = @{{' -f $parameter.Name))
            $sb.AppendLine(('               OriginalName = ''{0}''' -f $parameter.OriginalName))
            $sb.AppendLine(('               OriginalPosition = ''{0}''' -f $parameter.OriginalPosition))
            $sb.AppendLine(('               Position = ''{0}''' -f $parameter.Position))
            $sb.AppendLine(('               ParameterType = ''{0}''' -f $parameter.ParameterType))
            $sb.AppendLine(('               ApplyToExecutable = ${0}' -f $parameter.ApplyToExecutable))
            $sb.AppendLine(('               NoGap = ${0}' -f $parameter.NoGap))
            if($parameter.DefaultMissingValue) {
                $sb.AppendLine(('               DefaultMissingValue = ''{0}''' -f $parameter.DefaultMissingValue))
            }
            $sb.AppendLine('               }')
        }
        # end parameter map
        $sb.AppendLine("    }")
        return $sb.ToString()
    }

    [string]GetCommandHelp() {
        $helpSb = [System.Text.StringBuilder]::new()
        $helpSb.AppendLine("<#")
        $helpSb.AppendLine($this.GetSynopsis())
        $helpSb.AppendLine()
        $helpSb.AppendLine($this.GetDescription())
        $helpSb.AppendLine()
        if ( $this.Parameters.Count -gt 0 ) {
            foreach ( $parameter in $this.Parameters) {
                $helpSb.AppendLine($parameter.GetParameterHelp())
            }
            $helpSb.AppendLine();
        }
        if ( $this.Examples.Count -gt 0 ) {
            foreach ( $example in $this.Examples ) {
                $helpSb.AppendLine($example.ToString())
                $helpSb.AppendLine()
            }
        }
        if ( $this.HelpLinks.Count -gt 0 ) {
            $helpSB.AppendLine(".LINK");
            foreach ( $link in $this.HelpLinks ) {
                $helpSB.AppendLine($link.ToString())
            }
            $helpSb.AppendLine()
        }
        $helpSb.Append("#>")
        return $helpSb.ToString()
    }

    # this is where the logic of actually calling the command is created
    [string]GetInvocationCommand() {
        $sb = [System.Text.StringBuilder]::new()
        $sb.AppendLine('    foreach ($paramName in $__boundParameters.Keys|')
        $sb.AppendLine('            Where-Object {!$__PARAMETERMAP[$_].ApplyToExecutable}|') # skip those parameters which apply to the executable
        $sb.AppendLine('            Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {')
        $sb.AppendLine('        $value = $__boundParameters[$paramName]')
        $sb.AppendLine('        $param = $__PARAMETERMAP[$paramName]')
        $sb.AppendLine('        if ($param) {')
        $sb.AppendLine('            if ($value -is [switch]) {')
        $sb.AppendLine('                 if ($value.IsPresent) {')
        $sb.AppendLine('                     if ($param.OriginalName) { $__commandArgs += $param.OriginalName }')
        $sb.AppendLine('                 }')
        $sb.AppendLine('                 elseif ($param.DefaultMissingValue) { $__commandArgs += $param.DefaultMissingValue }')
        $sb.AppendLine('            }')
        $sb.AppendLine('            elseif ( $param.NoGap ) {')
        $sb.AppendLine('                $pFmt = "{0}{1}"')
        $sb.AppendLine('                if($value -match "\s") { $pFmt = "{0}""{1}""" }')
        $sb.AppendLine('                $__commandArgs += $pFmt -f $param.OriginalName, $value')
        $sb.AppendLine('            }')
        $sb.AppendLine('            else {')
        $sb.AppendLine('                if($param.OriginalName) { $__commandArgs += $param.OriginalName }')
        $sb.AppendLine('                $__commandArgs += $value | Foreach-Object {$_}')
        $sb.AppendLine('            }')
        $sb.AppendLine('        }')
        $sb.AppendLine('    }')
        $sb.AppendLine('    $__commandArgs = $__commandArgs | Where-Object {$_ -ne $null}') # strip only nulls
        if ( $this.NoInvocation ) {
        $sb.AppendLine('    return $__commandArgs')
        }
        else {
        $sb.AppendLine('    if ($__boundParameters["Debug"]){wait-debugger}')
        $sb.AppendLine('    if ( $__boundParameters["Verbose"]) {')
        $sb.AppendLine('         Write-Verbose -Verbose -Message ' + $this.OriginalName)
        $sb.AppendLine('         $__commandArgs | Write-Verbose -Verbose')
        $sb.AppendLine('    }')
        $sb.AppendLine('    $__handlerInfo = $__outputHandlers[$PSCmdlet.ParameterSetName]')
        $sb.AppendLine('    if (! $__handlerInfo ) {')
        $sb.AppendLine('        $__handlerInfo = $__outputHandlers["Default"] # Guaranteed to be present')
        $sb.AppendLine('    }')
        $sb.AppendLine('    $__handler = $__handlerInfo.Handler')
        $sb.AppendLine('    if ( $PSCmdlet.ShouldProcess("' + $this.OriginalName + ' $__commandArgs")) {')
        $sb.AppendLine('    # check for the application and throw if it cannot be found')
        $sb.AppendLine('        if ( -not (Get-Command -ErrorAction Ignore "' + $this.OriginalName + '")) {')
        $sb.AppendLine('          throw "Cannot find executable ''' + $this.OriginalName + '''"')
        $sb.AppendLine('        }')
        $sb.AppendLine('        if ( $__handlerInfo.StreamOutput ) {')
        if ( $this.Elevation.Command ) {
            $__elevationArgs = $($this.Elevation.Arguments | Foreach-Object { "{0} {1}" -f $_.OriginalName, $_.DefaultValue }) -join " "
            $sb.AppendLine(('            & "{0}" {1} "{2}" $__commandArgs | & $__handler' -f $this.Elevation.Command, $__elevationArgs, $this.OriginalName))
        }
        else {
            $sb.AppendLine(('            & "{0}" $__commandArgs | & $__handler' -f $this.OriginalName))
        }
        $sb.AppendLine('        }')
        $sb.AppendLine('        else {')
        if ( $this.Elevation.Command ) {
            $__elevationArgs = $($this.Elevation.Arguments | Foreach-Object { "{0} {1}" -f $_.OriginalName, $_.DefaultValue }) -join " "
            $sb.AppendLine(('            $result = & "{0}" {1} "{2}" $__commandArgs' -f $this.Elevation.Command, $__elevationArgs, $this.OriginalName))
        }
        else {
            $sb.AppendLine(('            $result = & "{0}" $__commandArgs' -f $this.OriginalName))
        }
        $sb.AppendLine('            & $__handler $result')
        $sb.AppendLine('        }')
        $sb.AppendLine("    }")
        }
        $sb.AppendLine("  } # end PROCESS") # always present
        return $sb.ToString()
    }
    [string]GetCrescendoAttribute()
    {
        return('[PowerShellCustomFunctionAttribute(RequiresElevation=${0})]' -f (($null -eq $this.Elevation.Command) ? $false : $true))
    }
    [string]GetCommandDeclaration([bool]$EmitAttribute) {
        $sb = [System.Text.StringBuilder]::new()
        $sb.AppendFormat("function {0}`n", $this.FunctionName)
        $sb.AppendLine("{") # }
        if ( $EmitAttribute ) {
            $sb.AppendLine($this.GetCrescendoAttribute())
        }
        $sb.Append("[CmdletBinding(")
        $addlAttributes = @()
        if ( $this.SupportsShouldProcess ) {
            $addlAttributes += 'SupportsShouldProcess=$true'
        }
        if ( $this.ConfirmImpact ) {
            if ( @("high","medium","low","none") -notcontains $this.ConfirmImpact) {
                throw ("Confirm Impact '{0}' is invalid. It must be High, Medium, Low, or None." -f $this.ConfirmImpact)
            }
            $addlAttributes += 'ConfirmImpact=''{0}''' -f $this.ConfirmImpact
        }
        if ( $this.DefaultParameterSetName ) {
            $addlAttributes += 'DefaultParameterSetName=''{0}''' -f $this.DefaultParameterSetName
        }
        $sb.Append(($addlAttributes -join ','))
        $sb.AppendLine(")]")
        return $sb.ToString()
    }
    [string]GetParameters() {
        $sb = [System.Text.StringBuilder]::new()
        $sb.Append("param(")
        if ($this.Parameters.Count -gt 0) {
            $sb.AppendLine()
            $params = $this.Parameters|ForEach-Object {$_.ToString()}
            $sb.AppendLine(($params -join ",`n"))
        }
        $sb.AppendLine("    )")
        return $sb.ToString()
    }

    [void]ExportConfigurationFile([string]$filePath) {
        $sOptions = [System.Text.Json.JsonSerializerOptions]::new()
        $sOptions.WriteIndented = $true
        $sOptions.MaxDepth = 10
        $sOptions.IgnoreNullValues = $true
        $text = [System.Text.Json.JsonSerializer]::Serialize($this, $sOptions)
        Set-Content -Path $filePath -Value $text
    }

    [string]GetCrescendoConfiguration() {
        $sOptions = [System.Text.Json.JsonSerializerOptions]::new()
        $sOptions.WriteIndented = $true
        $sOptions.MaxDepth = 10
        $sOptions.IgnoreNullValues = $true
        $text = [System.Text.Json.JsonSerializer]::Serialize($this, $sOptions)
        return $text
    }

}
# =========================================================================

# function to test whether there is a parser error in the output handler
function Test-Handler {
    param (
        [Parameter(Mandatory=$true)][string]$script,
        [Parameter(Mandatory=$true)][ref]$parserErrors
    )
    $null = [System.Management.Automation.Language.Parser]::ParseInput($script, [ref]$null, $parserErrors)
    (0 -eq $parserErrors.Value.Count)
}

# functions to create the classes since you can't access the classes outside the module
function New-ParameterInfo {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions","")]
    param (
        [Parameter(Position=0,Mandatory=$true)][string]$Name,
        [Parameter(Position=1,Mandatory=$true)][AllowEmptyString()][string]$OriginalName
    )
    [ParameterInfo]::new($Name, $OriginalName)
}

function New-UsageInfo {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions","")]
    param (
        [Parameter(Position=0,Mandatory=$true)][string]$usage
        )
    [UsageInfo]::new($usage)
}

function New-ExampleInfo {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions","")]
    param (
        [Parameter(Position=0,Mandatory=$true)][string]$command,
        [Parameter(Position=1,Mandatory=$true)][string]$description,
        [Parameter(Position=2)][string]$originalCommand = ""
        )
    [ExampleInfo]::new($command, $originalCommand, $description)
}

function New-OutputHandler {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions","")]
    param ( )
    [OutputHandler]::new()

}

function New-CrescendoCommand {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions","")]
    param (
        [Parameter(Position=0,Mandatory=$true)][string]$Verb,
        [Parameter(Position=1,Mandatory=$true)][string]$Noun,
        [Parameter(Position=2)][string]$OriginalName
    )
    $cmd = [Command]::new($Verb, $Noun)
    $cmd.OriginalName = $OriginalName
    $cmd
}

function Export-CrescendoCommand {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=0,Mandatory=$true,ValueFromPipeline=$true)]
        [Command[]]$command,
        [Parameter()][string]$targetDirectory = "."
    )

    PROCESS
    {
        foreach($crescendoCommand in $command) {
            if($PSCmdlet.ShouldProcess($crescendoCommand)) {
                $fileName = "{0}-{1}.crescendo.json" -f $crescendoCommand.Verb, $crescendoCommand.Noun
                $exportPath = Join-Path $targetDirectory $fileName
                $crescendoCommand.ExportConfigurationFile($exportPath)

            }
        }
    }
}

function Import-CommandConfiguration
{
[CmdletBinding()]
param ([Parameter(Position=0,Mandatory=$true)][string]$file)
    $options = [System.Text.Json.JsonSerializerOptions]::new()
    # this dance is to support multiple configurations in a single file
    # The deserializer doesn't seem to support creating [command[]]
    Get-Content $file |
        ConvertFrom-Json -depth 10|
        Foreach-Object {$_.Commands} |
        ForEach-Object { $_ | ConvertTo-Json -depth 10 |
            Foreach-Object {
                $configuration = [System.Text.Json.JsonSerializer]::Deserialize($_, [command], $options)
                $errs = $null
                if (!(Test-Configuration -configuration $configuration -errors ([ref]$errs))) {
                    $errs | Foreach-Object { Write-Error -ErrorRecord $_ }
                }

                # emit the configuration even if there was an error
                $configuration
            }
        }
}

function Test-Configuration
{
    param ([Command]$Configuration, [ref]$errors)

    $configErrors = @()
    $configurationOK = $true

    # Validate the Platform types
    $allowedPlatforms = "Windows","Linux","MacOS"
    foreach($platform in $Configuration.Platform) {
        if ($allowedPlatforms -notcontains $platform) {
            $configurationOK = $false
            $e = [System.Management.Automation.ErrorRecord]::new(
                [Exception]::new("Platform '$platform' is not allowed. Use 'Windows', 'Linux', or 'MacOS'"),
                "ParserError",
                "InvalidArgument",
                "Import-CommandConfiguration:Platform")
            $configErrors += $e
        }
    }

    # Validate the output handlers in the configuration
    foreach ( $handler in $configuration.OutputHandlers ) {
        $parserErrors = $null
        if ( -not (Test-Handler -Script $handler.Handler -ParserErrors ([ref]$parserErrors))) {
            $configurationOK = $false
            $exceptionMessage = "OutputHandler Error in '{0}' for ParameterSet '{1}'" -f $configuration.FunctionName, $handler.ParameterSetName
            $e = [System.Management.Automation.ErrorRecord]::new(
                ([Exception]::new($exceptionMessage)),
                "Import-CommandConfiguration:OutputHandler",
                "ParserError",
                $parserErrors)
            $configErrors += $e
        }
    }
    if ($configErrors.Count -gt 0) {
        $errors.Value = $configErrors
    }

    return $configurationOK

}

function Export-Schema() {
    $sGen = [Newtonsoft.Json.Schema.JsonSchemaGenerator]::new()
    $sGen.Generate([command])
}

function Export-CrescendoModule
{
    [CmdletBinding(SupportsShouldProcess=$true)]
    param (
        [Parameter(Position=1,Mandatory=$true,ValueFromPipelineByPropertyName=$true)][SupportsWildcards()][string[]]$ConfigurationFile,
        [Parameter(Position=0,Mandatory=$true)][string]$ModuleName,
        [Parameter()][switch]$Force
        )
    BEGIN {
        [array]$crescendoCollection = @()
        if ($ModuleName -notmatch "\.psm1$") {
            $ModuleName += ".psm1"
        }
        if (-not $PSCmdlet.ShouldProcess("Creating Module '$ModuleName'"))
        {
            return
        }
        if ((Test-Path $ModuleName) -and -not $Force) {
            throw "$ModuleName already exists"
        }
        # static parts of the crescendo module
        "# Module created by Microsoft.PowerShell.Crescendo" > $ModuleName
        'class PowerShellCustomFunctionAttribute : System.Attribute { '>> $ModuleName
        '    [bool]$RequiresElevation' >> $ModuleName
        '    [string]$Source' >> $ModuleName
        '    PowerShellCustomFunctionAttribute() { $this.RequiresElevation = $false; $this.Source = "Microsoft.PowerShell.Crescendo" }' >> $ModuleName
        '    PowerShellCustomFunctionAttribute([bool]$rElevation) {' >> $ModuleName
        '        $this.RequiresElevation = $rElevation' >> $ModuleName
        '        $this.Source = "Microsoft.PowerShell.Crescendo"' >> $ModuleName
        '    }' >> $ModuleName
        '}' >> $ModuleName
        '' >> $ModuleName
        $moduleBase = [System.IO.Path]::GetDirectoryName($ModuleName)
    }
    PROCESS {
        if ( $PSBoundParameters['WhatIf'] ) {
            return
        }
        $resolvedConfigurationPaths = (Resolve-Path $ConfigurationFile).Path
        foreach($file in $resolvedConfigurationPaths) {
            Write-Verbose "Adding $file to Crescendo collection"
            $crescendoCollection += Import-CommandConfiguration $file
        }
    }
    END {
        if ( $PSBoundParameters['WhatIf'] ) {
            return
        }
        [string[]]$cmdletNames = @()
        [string[]]$aliases = @()
        [string[]]$SetAlias = @()
        [bool]$IncludeWindowsElevationHelper = $false
        foreach($proxy in $crescendoCollection) {
            if ($proxy.Elevation.Command -eq "Invoke-WindowsNativeAppWithElevation") {
                $IncludeWindowsElevationHelper = $true
            }
            $cmdletNames += $proxy.FunctionName
            if ( $proxy.Aliases ) {
                # we need the aliases without value for the psd1
                $proxy.Aliases.ForEach({$aliases += $_})
                # the actual set-alias command will be emited before the export-modulemember
                $proxy.Aliases.ForEach({$SetAlias += "Set-Alias -Name '{0}' -Value '{1}'" -f $_,$proxy.FunctionName})
            }
            # when set to true, we will emit the Crescendo attribute
            $proxy.ToString($true) >> $ModuleName
        }
        $SetAlias >> $ModuleName

        # include the windows helper if it has been included
        if ($IncludeWindowsElevationHelper) {
            "function Invoke-WindowsNativeAppWithElevation {" >> $ModuleName
            $InvokeWindowsNativeAppWithElevationFunction >> $ModuleName
            "}" >> $ModuleName
        }

        $ModuleManifestArguments = @{
            Path = $ModuleName -Replace "psm1$","psd1"
            RootModule = [io.path]::GetFileName(${ModuleName})
            Tags = "CrescendoBuilt"
            PowerShellVersion = "5.1.0"
            CmdletsToExport = @()
            AliasesToExport = @()
            VariablesToExport = @()
            FunctionsToExport = @()
            PrivateData = @{ CrescendoGenerated = Get-Date; CrescendoVersion = (Get-Module Microsoft.PowerShell.Crescendo).Version }
        }
        if ( $cmdletNames ) {
            $ModuleManifestArguments['FunctionsToExport'] = $cmdletNames
        }
        if ( $aliases ) {
            $ModuleManifestArguments['AliasesToExport'] = $aliases
        }

        New-ModuleManifest @ModuleManifestArguments

        # copy the script output handlers into place
        foreach($config in $crescendoCollection) {
            foreach($handler in $config.OutputHandlers) {
                if ($handler.HandlerType -eq "Script") {
                    $scriptInfo = Get-Command -ErrorAction Ignore -CommandType ExternalScript $handler.Handler
                    if($scriptInfo) {
                        Copy-Item $scriptInfo.Source $moduleBase
                    }
                    else {
                        $errArgs = @{
                            Category = "ObjectNotFound"
                            TargetObject = $scriptInfo.Source
                            Message = "Handler '" + $scriptInfo.Source + "' not found."
                            RecommendedAction = "Copy the handler to the module directory before packaging."
                        }
                        Write-Error @errArgs
                    }
                }
            }
        }
    }
}

# This is an elevation function for Windows which may be distributed with a crescendo module
$InvokeWindowsNativeAppWithElevationFunction = @'
    [CmdletBinding(DefaultParameterSetName="username")]
    param (
        [Parameter(Position=0,Mandatory=$true)][string]$command,
        [Parameter(ParameterSetName="credential")][PSCredential]$Credential,
        [Parameter(ParameterSetName="username")][string]$User = "Administrator",
        [Parameter(ValueFromRemainingArguments=$true)][string[]]$cArguments
    )

    $app = "cmd.exe"
    $nargs = @("/c","cd","/d","%CD%","&&")
    $nargs += $command
    if ( $cArguments.count ) {
        $nargs += $cArguments
    }
    $__OUTPUT = Join-Path ([io.Path]::GetTempPath()) "CrescendoOutput.txt"
    $__ERROR  = Join-Path ([io.Path]::GetTempPath()) "CrescendoError.txt"
    if ( $Credential ) {
        $cred = $Credential
    }
    else {
        $cred = Get-Credential $User
    }

    $spArgs = @{
        Credential = $cred
        File = $app
        ArgumentList = $nargs
        RedirectStandardOutput = $__OUTPUT
        RedirectStandardError = $__ERROR
        WindowStyle = "Minimized"
        PassThru = $True
        ErrorAction = "Stop"
    }
    $timeout = 10000
    $sleepTime = 500
    $totalSleep = 0
    try {
        $p = start-process @spArgs
        while(!$p.HasExited) {
            Start-Sleep -mill $sleepTime
            $totalSleep += $sleepTime
            if ( $totalSleep -gt $timeout )
            {
                throw "'$(cArguments -join " ")' has timed out"
            }
        }
    }
    catch {
        # should we report error output?
        # It's most likely that there will be none if the process can't be started
        # or other issue with start-process. We catch actual error output from the
        # elevated command below.
        if ( Test-Path $__OUTPUT ) { Remove-Item $__OUTPUT }
        if ( Test-Path $__ERROR ) { Remove-Item $__ERROR }
        $msg = "Error running '{0} {1}'" -f $command,($cArguments -join " ")
        throw "$msg`n$_"
    }

    try {
        if ( test-path $__OUTPUT ) {
            $output = Get-Content $__OUTPUT
        }
        if ( test-path $__ERROR ) {
            $errorText = (Get-Content $__ERROR) -join "`n"
        }
    }
    finally {
        if ( $errorText ) {
            $exception = [System.Exception]::new($errorText)
            $errorRecord = [system.management.automation.errorrecord]::new(
                $exception,
                "CrescendoElevationFailure",
                "InvalidOperation",
                ("{0} {1}" -f $command,($cArguments -join " "))
                )
            # errors emitted during the application are not fatal
            Write-Error $errorRecord
        }
        if ( Test-Path $__OUTPUT ) { Remove-Item $__OUTPUT }
        if ( Test-Path $__ERROR ) { Remove-Item $__ERROR }
    }
    # return the output to the caller
    $output
'@

class CrescendoCommandInfo {
    [string]$Module
    [string]$Source
    [string]$Name
    [bool]$IsCrescendoCommand
    [bool]$RequiresElevation
    CrescendoCommandInfo([string]$module, [string]$name, [Attribute]$attribute) {
        $this.Module = $module
        $this.Name = $name
        $this.IsCrescendoCommand = $null -eq $attribute ? $false : ($attribute.Source -eq "Microsoft.PowerShell.Crescendo")
        $this.RequiresElevation = $null -eq $attribute ? $false : $attribute.RequiresElevation
        $this.Source = $null -eq $attribute ? "" : $attribute.Source
    }
}

function Test-IsCrescendoCommand
{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline=$true,Mandatory=$true,Position=0)]
        [object[]]$Command
    )
    PROCESS {
        # loop through the commands and determine whether it is a Crescendo Function
        foreach( $cmd in $Command) {
            $fInfo = $null
            if ($cmd -is [System.Management.Automation.FunctionInfo]) {
                $fInfo = $cmd
            }
            elseif ($cmd -is [string]) {
                $fInfo = Get-Command -Name $cmd -CommandType Function -ErrorAction Ignore
            }
            if(-not $fInfo) {
                Write-Error -Message "'$cmd' is not a function" -TargetObject "$cmd" -RecommendedAction "Be sure that the command is a function"
                continue
            }
            #  check for the PowerShellFunctionAttribute and report on findings
            $crescendoAttribute = $fInfo.ScriptBlock.Attributes|Where-Object {$_.TypeId.Name -eq "PowerShellCustomFunctionAttribute"} | Select-Object -Last 1
            [CrescendoCommandInfo]::new($fInfo.Source, $fInfo.Name, $crescendoAttribute)
        }
    }
}
