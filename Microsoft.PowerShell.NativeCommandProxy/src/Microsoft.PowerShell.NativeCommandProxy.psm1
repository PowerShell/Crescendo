# this contains code common for all generators
# OM VERSION 1.2
# =========================================================================
using namespace System.Collections.Generic
class UsageInfo { # used for .SYNOPSIS of the comment-based help
    [string]$Usage
    [bool]$SupportsFlags
    [bool]$HasOptions
    hidden [string[]]$OriginalText

    UsageInfo() { }
    UsageInfo([string] $usage)
    {
        $this.Usage = $usage
    }

    [string]ToString() #  this is to be replaced with actual proxy-generation code
    {
        return ((".SYNOPSIS",$this.Usage) -join "`n")
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

    [string]ToString() #  this is to be replaced with actual proxy-generation code
    {
        $sb = [text.stringbuilder]::new()
        $sb.AppendLine(".EXAMPLE")
        $sb.AppendLine("PS> " + $this.Command)
        $sb.AppendLine("")
        $sb.AppendLine($this.Description)
        $sb.AppendLine("Original Command: " + $this.OriginalCommand)
        return $sb.ToString()
    }
}


class ParameterInfo {
    [string]$Name # PS-proxy name
    [string]$OriginalName # original native parameter name

    [string]$OriginalText
    [string]$Description
    [object]$DefaultValue
    # some parameters are -param or +param which can be represented with a switch parameter
    # so we need way to provide for this
    [object]$DefaultMissingValue
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

    ParameterInfo() {
        $this.Position = [int]::MaxValue
    }
    ParameterInfo ([string]$Name, [string]$OriginalName)
    {
        $this.Name = $Name
        $this.OriginalName = $OriginalName
        $this.Position = [int]::MaxValue
    }

    [string]ToString() #  this is to be replaced with actual proxy-generation code
    {
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

        $elements = @()
        # TODO: This logic does not handle parameters in multiple sets correctly
        $sb.Append('[Parameter(')
        if ( $this.Position -ne [int]::MaxValue ) {
            $elements += "Position=" + $this.Position
        }
        if ( $this.ValueFromPipeline ) {
            $elements += 'ValueFromPipeline=$true'
        }
        if ( $this.ValueFromPipelineByPropertyName ) {
            $elements += 'ValueFromPipelineByPropertyName=$true'
        }
        if ( $this.ValueFromRemainingArguments ) {
            $elements += 'ValueFromRemainingArguments=$true'
        }
        if ( $this.ParameterSetName.Count -eq 1 ) {
            $elements += "ParameterSetName='{0}'" -f $this.ParameterSetName
        }
        if ($elements.Count -gt 0) {
            $sb.Append(($elements -join ","))
        }
        $sb.AppendLine(')]')
        if ( $this.ParameterSetName.Count -gt 1) {
            $this.ParameterSetName.ForEach({$sb.AppendLine(('[Parameter(ParameterSetName="{0}")]' -f $_))})
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

class Command {
    [string]$Verb # PS-proxy name verb
    [string]$Noun # PS-proxy name noun
    
    [string]$OriginalName # e.g. "cubectl get user" -> "cubectl"
    [string[]]$OriginalCommandElements # e.g. "cubectl get user" -> "get", "user"

    [string[]] $Aliases
    [string] $DefaultParameterSetName
    [bool] $SupportsShouldProcess
    [bool] $SupportsTransactions

    [string]$Description
    [UsageInfo]$Usage
    [List[ParameterInfo]]$Parameters
    [List[ExampleInfo]]$Examples
    [string]$OriginalText
    [string[]]$HelpLinks

    Command() { }
    Command([string]$Verb, [string]$Noun)
    {
        $this.Verb = $Verb
        $this.Noun = $Noun
        $this.Parameters = [List[ParameterInfo]]::new()
        $this.Examples = [List[ExampleInfo]]::new()
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
            return $this.Usage.ToString()
        }
        else {
            if ( Get-Command $this.OriginalName ) {
                try {
                    $nativeHelpText = & $this.OriginalName -?
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

    [string]ToString() #  this is to be replaced with actual proxy-generation code
    {
        $sb = [System.Text.StringBuilder]::new()
        # get the command declaration
        $sb.AppendLine($this.GetCommandDeclaration())
        # get the parameters
        # we always need a parameter block
        $sb.AppendLine($this.GetParameters())
        # get the parameter map
        # this may be null if there are no parameters
        $sb.AppendLine("BEGIN {")
        $parameterMap = $this.GetParameterMap()
        if ( $parameterMap ) {
            $sb.AppendLine($parameterMap)
        }
        $sb.AppendLine("}")
        # construct the command invocation
        # this must exist and should never be null
        # otherwise we won't actually be invoking anything
        $sb.AppendLine("PROCESS {")
        $sb.AppendLine('    $__commandArgs = @()')
        $sb.AppendLine($this.GetInvocationCommand())
        # add the help
        $help = $this.GetCommandHelp()
        if ( $help ) {
            $sb.AppendLine($help)
        }

        # finish the function
        $sb.AppendLine("}")
        # return $this.Verb + "-" + $this.Noun
        return $sb.ToString()
    }
    [string]GetParameterMap() {
        $sb = [System.Text.StringBuilder]::new()
        $sb.AppendLine('    $__PARAMETERMAP = @{')
        $this.Parameters |ForEach-Object {
            $sb.AppendLine(("        {0} = @{{ OriginalName = '{1}'; OriginalPosition = '{2}'; Position = '{3}'; ParameterType = [{4}] }}" -f $_.Name, $_.OriginalName, $_.OriginalPosition, $_.Position, $_.ParameterType))
        }
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

    [string]GetInvocationCommand() {
        $sb = [System.Text.StringBuilder]::new()
        $sb.AppendLine('    if ($PSBoundParameters["Debug"]){wait-debugger}')
        $sb.AppendLine('    $MyInvocation.MyCommand.Parameters.Values.Where({$_.SwitchParameter -and $_.Name -notmatch "Debug|Whatif|Confirm|Verbose" -and ! $PSBoundParameters[$_.Name]}).ForEach({$PSBoundParameters[$_.Name] = [switch]::new($false)})')
        $sb.AppendLine('    $__boundparms = $PSBoundParameters') # debugging assistance
        $sb.AppendLine('    foreach ($paramName in $PSBoundParameters.Keys|Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {')
        $sb.AppendLine('        $value = $PSBoundParameters[$paramName]')
        $sb.AppendLine('        $param = $__PARAMETERMAP[$paramName]')
        $sb.AppendLine('        if ($param) {')
        $sb.AppendLine('            if ( $value -is [switch] ) { $__commandArgs += $value.IsPresent ? $param.OriginalName : $param.DefaultMissingValue } ')
        # $sb.AppendLine('            elseif ( $param.Position -ne [int]::MaxValue ) { $__commandArgs += $value }')
        $sb.AppendLine('            else { $__commandArgs += $param.OriginalName; $__commandArgs += $value |%{$_}}')
        $sb.AppendLine('        }')
        $sb.AppendLine('    }')
        $sb.AppendLine('    $__commandArgs = $__commandArgs|?{$_}') # strip nulls
        $sb.AppendLine('    if ($PSBoundParameters["Debug"]){wait-debugger}')
        $sb.AppendLine('    if ( $PSBoundParameters["Verbose"]) {')
        $sb.AppendLine('         Write-Verbose -Verbose ' + $this.OriginalName)
        $sb.AppendLine('         $__commandArgs | Write-Verbose -Verbose')
        $sb.AppendLine('    }')
        $sb.AppendLine('    if ( $PSCmdlet.ShouldProcess("' + $this.OriginalName + '")) {')
        $sb.AppendLine(('        & "{0}" $__commandArgs' -f $this.OriginalName))
        $sb.AppendLine("    }")
        $sb.AppendLine("  }")
        return $sb.ToString()
    }
    [string]GetCommandDeclaration() {
        $sb = [System.Text.StringBuilder]::new()
        $sb.AppendFormat("Function {0}-{1}`n", $this.Verb, $this.Noun)
        $sb.AppendLine("{")
        $sb.Append("[CmdletBinding(")
        $addlAttributes = @()
        if ( $this.SupportsShouldProcess ) {
            $addlAttributes += 'SupportsShouldProcess=$true'
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

}
# =========================================================================

# proxy functions to create the classes since you can't access the classes outside the module
function New-ParameterInfo {
    param (
        [Parameter(Position=0,Mandatory=$true)][string]$Name,
        [Parameter(Position=1,Mandatory=$true)][AllowEmptyString()][string]$OriginalName
    )
    [ParameterInfo]::new($Name, $OriginalName)
}

function New-UsageInfo {
    param (
        [Parameter(Position=0,Mandatory=$true)][string]$usage
        )
    [UsageInfo]::new($usage)
}

function New-ExampleInfo {
    param (
        [Parameter(Position=0,Mandatory=$true)][string]$command,
        [Parameter(Position=1,Mandatory=$true)][string]$originalCommand,
        [Parameter(Position=2,Mandatory=$true)][string]$description
        )
    [ExampleInfo]::new($command, $originalCommand, $description)
}

function New-ProxyCommand {
    param (
        [Parameter(Position=0,Mandatory=$true)][string]$Verb,
        [Parameter(Position=1,Mandatory=$true)][string]$Noun
    )
    [Command]::new($Verb, $Noun)
}

function Import-CommandConfiguration([string]$file) {
    $text = Get-Content -Read 0 $file
    $options = [System.Text.Json.JsonSerializerOptions]::new()
    [System.Text.Json.JsonSerializer]::Deserialize($text, [command], $options)  
}