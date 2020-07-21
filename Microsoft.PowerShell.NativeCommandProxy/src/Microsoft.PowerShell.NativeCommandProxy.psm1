# this contains code common for all generators
# OM VERSION 1.2
# =========================================================================
using namespace System.Collections.Generic
class UsageInfo { # used for .SYNOPSIS of the comment-based help
    [string]$Usage
    [bool]$SupportsFlags
    [bool]$HasOptions
    hidden [string[]]$OriginalText

    UsageInfo([string] $usage)
    {
        $this.Usage = $usage
    }

    [string]ToString() #  this is to be replaced with actual proxy-generation code
    {
        return $this.Usage
    }
}

class ExampleInfo { # used for .EXAMPLE of the comment-based help
    [string]$Command # ps-command
    [string]$OriginalCommand # original native tool command
    [string]$Description

    ExampleInfo([string]$Command, [string]$OriginalCommand, [string]$Description)
    {
        $this.Command = $Command
        $this.OriginalCommand = $OriginalCommand
        $this.Description = $description
    }

    [string]ToString() #  this is to be replaced with actual proxy-generation code
    {
        return $this.Command
    }
}

class ParameterInfo {
    [string]$Name # PS-proxy name
    [string]$OriginalName # original native parameter name

    [string]$OriginalText
    [string]$Description
    [object]$DefaultValue
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

    ParameterInfo ([string]$Name, [string]$OriginalName)
    {
        $this.Name = $Name
        $this.OriginalName = $OriginalName
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
        if ( $this.ParameterSetName.Count -gt 0) {
            $this.ParameterSetName.ForEach({$sb.AppendLine(('[Parameter(ParameterSetName="{0}")]' -f $_))})
        }
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
        if ($elements.Count -gt 0) {
            $sb.Append(($elements -join ","))
        }
        $sb.AppendLine(')]')
        $sb.Append(('[{0}]${1}' -f $this.ParameterType, $this.Name))
        if ( $this.DefaultValue ) {
            $sb.Append(' = "' + $this.DefaultValue + '"')
        }

        return $sb.ToString()
    }

    [string]GetParameterHelp()
    {
        return [string]::Empty;
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

    Command([string]$Verb, [string]$Noun)
    {
        $this.Verb = $Verb
        $this.Noun = $Noun
        $this.Parameters = [List[ParameterInfo]]::new()
        $this.Examples = [List[ExampleInfo]]::new()
    }

    [string]ToString() #  this is to be replaced with actual proxy-generation code
    {
        $sb = [System.Text.StringBuilder]::new()
        # get the help
        $help = $this.GetCommandHelp()
        if ( $help ) {
            $sb.AppendLine($help)
        }
        # get the command declaration
        $sb.AppendLine($this.GetCommandDeclaration())
        # get the parameters
        # we always need a parameter block
        $sb.AppendLine($this.GetParameters())
        # get the parameter map
        # this may be null if there are no parameters
        $sb.AppendLine("BEGIN {")
        $sb.AppendLine('    $__commandArgs = @()')
        $parameterMap = $this.GetParameterMap()
        if ( $parameterMap ) {
            $sb.AppendLine($parameterMap)
        }
        $sb.AppendLine("}")
        # construct the command invocation
        # this must exist and should never be null
        # otherwise we won't actually be invoking anything
        $sb.AppendLine("PROCESS {")
        $sb.AppendLine($this.GetInvocationCommand())
        # finish the function
        $sb.AppendLine("}")
        # return $this.Verb + "-" + $this.Noun
        return $sb.ToString()
    }
    [string]GetParameterMap() {
        $sb = [System.Text.StringBuilder]::new()
        $sb.AppendLine('    $__PARAMETERMAP = @{')
        $this.Parameters |ForEach-Object {
            $sb.AppendLine(("        {0} = @{{ OriginalName = '{1}'; OriginalPosition = '{2}'; ParameterType = [{3}] }}" -f $_.Name, $_.OriginalName, $_.OriginalPosition, $_.ParameterType))
        }
        $sb.AppendLine("    }")
        return $sb.ToString()
    }
    [string]GetCommandHelp() {
        return [string]::Empty
    }
    [string]GetInvocationCommand() {
        $sb = [System.Text.StringBuilder]::new()
        $sb.AppendLine('if ($PSBoundParameters["Debug"]){wait-debugger}')
        $sb.AppendLine('    foreach ($paramName in $PSBoundParameters.Keys|Sort-Object {$__PARAMETERMAP[$_].OriginalPosition}) {')
        $sb.AppendLine('        $value = $PSBoundParameters[$paramName]')
        $sb.AppendLine('        if ($__PARAMETERMAP[$paramName]) {')
        $sb.AppendLine('            if ( $param.ParameterType -eq [switch] ) { $__commandArgs += $__PARAMETERMAP[$paramName].OriginalName } ')
        $sb.AppendLine('            elseif ( $param.Position -ne [int]::MaxValue ) { $__commandArgs += $value }')
        $sb.AppendLine('            else { $__commandArgs += $__PARAMETERMAP[$paramName].OriginalName, $value }')
        $sb.AppendLine('        }')
        $sb.AppendLine('    }')
        $sb.AppendLine('if ($PSBoundParameters["Debug"]){wait-debugger}')
        $sb.AppendLine(('    & {0} $__commandArgs' -f $this.OriginalName))
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
        [Parameter(Position=1,Mandatory=$true)][string]$OriginalName
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