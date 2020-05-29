$Utilities = {

    $script:TextInfo = (Get-Culture).TextInfo

    class ParameterInfo {
        [string]$Name
        [string]$OriginalName
        [string]$Description
        [object]$DefaultValue
        [string]$TypeName
        [type]$ValueType
        [bool]$IsMandatory
        hidden [bool]$Parsed
        hidden [string]$OriginalText
        ParameterInfo ([string]$OriginalText, [string]$Name, [string]$TypeName, [string]$Description) {
            $this.OriginalText = $OriginalText
            $this.Name = $Name
            $this.TypeName = $TypeName
            $this.Description = $Description
        }
        [string]ToString() {
            return $this.Name
        }
    }
    
    class CommandBase {
        [string]$Command
        [string]$Description
        [string]$Usage
        [ParameterInfo[]]$Options
        [ParameterInfo[]]$Parameters
        hidden [string[]]$OriginalText
    
        CommandBase ([string]$text ) {
            $c,$d = "$text".Trim().Split("  ", 2, [System.StringSplitOptions]::RemoveEmptyEntries) | %{"$_".Trim()}
            $this.Command = $c
            $this.Description = $d
            $this.OriginalText = $text
        }
    
        CommandBase ([string]$command, [string]$description, [string[]]$OriginalText ) {
            $this.Command = $command
            $this.Description = $description
            $this.OriginalText = $OriginalText
        }
    }
    
    
    
    function GetPowerShellType
    {
        [CmdletBinding()]
        param ([string]$dockerTypeName)
    
        $result = 'switch'
        if (! [string]::IsNullOrEmpty($dockerTypeName))
        {
            $result = $dockerTypeName
            if ($dockerTypeName -eq 'filter') {$result = 'string'}
            if ($dockerTypeName -eq 'list') {$result = 'string[]'}
            if ($dockerTypeName -eq 'strings') {$result = 'string'}
            if ($dockerTypeName -eq 'external-ca') {$result = 'string'}
            if ($dockerTypeName -eq 'duration') {$result = 'uint'}
            if ($dockerTypeName -eq 'ipNetSlice') {$result = 'string'}
            if ($dockerTypeName -eq 'node-addr') {$result = 'string'}
            if ($dockerTypeName -eq 'pem-file') {$result = 'string'}
            if ($dockerTypeName -eq 'credential-spec') {$result = 'string'}
            if ($dockerTypeName -eq 'command') {$result = 'string'}
            if ($dockerTypeName -eq 'secret') {$result = 'string'}
            if ($dockerTypeName -eq 'bytes') {$result = 'string'}
            if ($dockerTypeName -eq 'ulimit') {$result = 'string'}
        }
    
        return $result
    }
    
    function Get-Options
    {
        [CmdletBinding()]
        param ( [string[]]$text, [string]$pattern )
    
        $results = [System.Collections.ArrayList]::new()
        for ( $i = 0; $i -lt $text.Count; $i++ )
        {
            if ( $text[$i] -match $pattern )
            {
                $i++
                $NextTrimmedline = $text[$i].Trim()
                while( -not ([string]::IsNullOrEmpty($NextTrimmedline)))
                {
                    $concatLine = $NextTrimmedline
                    $NextTrimmedline = $null
                    while( $i -lt ($text.count-1) )
                    {
                        $NextTrimmedline = $text[$i+1].Trim()
                        $i++
                        if (-not (([string]::IsNullOrEmpty($NextTrimmedline) -or $NextTrimmedline.StartsWith('-'))))
                        {
                            $concatLine += " " + $NextTrimmedline
                        }
                        else
                        {
                            break
                        }
                    }
    
                    if ( $concatLine -match ".*--(?<option>\S+) (?<type>\S+)?\s+(?<description>\S+.*$)" )
                    {
                        $OriginalName = $matches['option']
                        $Name = $script:TextInfo.ToTitleCase($OriginalName.ToLower()).Replace("-", "")
                        $typeName = GetPowerShellType -dockerTypeName $matches['type']
                        $description = $matches['description']
                        if ([string]::IsNullOrEmpty($typeName)) {$typeName = "switch"}
                        
                        $pi = [ParameterInfo]::new($concatLine, $Name, $typeName, $description)
                        $pi.OriginalName = $OriginalName
                        $pi.IsMandatory = $false
    
                        $null = $results.Add($pi)
                    }
                }
                break
            }
        }
        
        return $results
    }
    
    function Parse-UsageParameters
    {
        [CmdletBinding()]
        param ( [string] $usageText, [string] $commandName )
     
        #$usageText
        $usageText = $usageText.TrimStart("docker " + $commandName).Trim()
        #$usageText
        $results = [System.Collections.ArrayList]::new()
    
        if (-not [string]::IsNullOrEmpty($usageText))
        {
            $usageText = $usageText.Replace(" | ", "|")
            $parts = $usageText.Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)
            foreach ($part in $parts)
            {
                $typeName = "string"
    
                if ($part -eq "[OPTIONS]")
                {
                    continue # place of options in the final command string is predefined, so we don't need to process them here
                }
    
                $mandatory = $true
                if ($part.StartsWith('['))
                {
                    $mandatory = $false
                    $part = $part.Trim('[',']')
                }
    
                if ( $part -match "^(?<parameter>\w+)\W*" ) # for now, do not support complex param strings or choice params
                {
                    $OriginalName = $matches['parameter']
                    $Name = $script:TextInfo.ToTitleCase($OriginalName.ToLower()).Replace("-", "")
                    $paramAlreadyExists = $false
                    foreach ($prevPi in $results) # if this is a repetiion of one of previous parameters - make previous one an array
                    {
                        if ($prevPi.Name -eq $Name)
                        {
                            $prevPi.TypeName += "[]"
                            $paramAlreadyExists = $true
                            break
                        }
                    }
    
                    if (-not $paramAlreadyExists)
                    {
                        $pi = [ParameterInfo]::new($part, $Name, $typeName, "")
                        $pi.OriginalName = $OriginalName
                        $pi.IsMandatory = $mandatory
                        $null = $results.Add($pi)
                    }
                }
            }
        }
    
        return $results
    }
    
    function Parse-Usage
    {
        [CmdletBinding()]
        param ([string[]]$text, [string]$patternRegex )
        for ( $i = 0; $i -lt $text.Count; $i++ )
        {
            if ( $text[$i] -match $patternRegex )
            {
                return $text[$i].Trim()
            }
        }
    }
    
    function Parse-Command
    {
        [CmdletBinding()]
        param ( [string[]]$text, [string]$pattern )
        
        $patternRegex = $pattern
        $results = [System.Collections.ArrayList]::new()
        for ( $i = 0; $i -lt $text.Count; $i++ )
        {
            if ( $text[$i] -match $patternRegex )
            {
                $i++
                while ( $text[$i].Trim() -ne "" )
                {
                    $null = $results.Add([CommandBase]::new($text[$i]))
                    $i++
                    if ( $i -gt $text.count ) { break }
                }
                break
            }
        }
        return $results
    }
    
    function CreateCommandObject
    {
        [CmdletBinding()]
        #param ([string]$cmd, [string[]]$text)
        param ([string]$cmd, [string]$description, [string[]]$commandHelpText)

        $command = [CommandBase]::new($cmd,$description,$commandHelpText)
    
        $term = "Usage:"
        $usage = Parse-Usage -text $commandHelpText -patternRegex $term
        $command.Usage = $usage.TrimStart($term).Trim()
    
        $command.Options = Get-Options -text $commandHelpText -pattern "Options:"
        $command.Parameters = Parse-UsageParameters -usageText $command.Usage -commandName $command.Command
        return $command
    }

    function Read-CommandsFromHelp
    {
        [CmdletBinding()]
        param ([hashtable]$cmdsht)

        foreach ($cmd in $cmdsht.Keys)
        {
            $Description = $cmdsht[$cmd]
            
            $commandline = "docker $cmd --help"
            [string[]]$cmdText = Invoke-Expression $commandline

            CreateCommandObject -cmd $cmd -description $Description -commandHelpText $cmdText
        }
    }
}



$commandNameMap = @{
    "attach"="Attach-DockerContainerStream"
    #"build"="Build-DockerImage"
    #"commit"="Create-DockerImage"
    "cp"="Copy-DockerFiles"
    "create"="Create-DockerContainer"
    "diff"="Inspect-DockerFileChanges"
    "events"="Get-DockerEvents"
    "exec"="Run-DockerCommand"
    "export"="Export-DockerFilesystem"
    "history"="Show-DockerImageHistory"
    #"images"="Get-DockerImage"
    #"import"="Import-DockerImage"
    "info"="Get-DockerInformation"
    "inspect"="Inspect-DockerObject"
    "kill"="Kill-DockerContainer"
    #"load"="Load-DockerImage"

    "image ls"="Get-DockerImage"
    "image build"="Build-DockerImage"
    "image inspect"="Inspect-DockerImage"
}

$ParameterAliasMap = @{
    "dcr-image-inspect:Image"="ID;AnotherAlias"
}

$ArgumentCompleterMap = @{
    "dcr-image-inspect:Image"="(dcr-image-ls).ID | Where-Object { `$_ -like `"`$WordToComplete*`" }"
    "dcr-image-ls:Repository"="(dcr-image-ls).Repository | Where-Object { `$_ -like `"`$WordToComplete*`" }"
}

$HelpLinkMap = @{
    "image inspect"="https://docs.docker.com/engine/reference/commandline/image_inspect/"
    "dcr-image-ls"="https://docs.docker.com/engine/reference/commandline/images/"
}

function GenerateCommandProxy
{
    [CmdletBinding()]
    param ($command)

    $paramList = New-Object Collections.Generic.List[string]
    $ParamFillerList = New-Object Collections.Generic.List[string]
    $HelpList = New-Object Collections.Generic.List[string]
    $commandSupportsFormat = $false
    $FormatFillerText = ""
    $functionName = "dcr-" + $command.Command.Replace(" ", "-")

    foreach($p in $command.Options)
    {
        $ParamDefaultValue = ""

        if ($p.Name -eq 'Format')
        {
            $commandSupportsFormat = $true
            $ParamDefaultValue = " = `"{{json .}}`""
        }

        $paramList.Add("[Parameter(Mandatory=`$$($p.IsMandatory))][$($p.TypeName)]`$$($p.Name)$ParamDefaultValue")

        if ($p.Description)
        {
            $HelpList.Add(".PARAMETER $($p.Name)" + [Environment]::NewLine + $p.Description)
        }

        if ($p.TypeName -eq "switch")
        {
            $ParamFillerList.Add("if (`$PSBoundParameters['$($p.Name)']) {`$AllArgs += `"--$($p.OriginalName)`"}")
        }
        else
        {
            if ($p.Name -eq 'Format')
            {
                $ParamFillerList.Add("if (-not `$NativeOutput) {`$AllArgs += `"--$($p.OriginalName)`";`$AllArgs += `$Format}")
            }
            else
            {
                $ParamFillerList.Add("if (`$PSBoundParameters['$($p.Name)']) {`$AllArgs += `"--$($p.OriginalName)`";`$AllArgs += `$PSBoundParameters['$($p.Name)']}")
            }
        }
    }
    foreach($p in $command.Parameters)
    {
        $paramAliases = $ParameterAliasMap["$functionName`:$($p.Name)"]
        $paramAliasText = ""
        $paramByPropNameText = ""
        if (-not [string]::IsNullOrEmpty($paramAliases))
        {
            foreach($pAlias in $paramAliases.Split(';'))
            {
                $paramAliasText += "[Alias(`"$pAlias`")]"
            }
            $paramByPropNameText = ",ValueFromPipelineByPropertyName=`$True"
        }

        $argumentCompleter = $ArgumentCompleterMap["$functionName`:$($p.Name)"]
        $argumentCompleterText = ""
        if (-not [string]::IsNullOrEmpty($argumentCompleter))
        {
            $argumentCompleterText = "[ArgumentCompleter({param(`$CommandName,`$ParameterName,`$WordToComplete,`$CommandAst,`$FakeBoundParameters)$argumentCompleter})]"
        }

        $paramList.Add("[Parameter(Mandatory=`$$($p.IsMandatory)$paramByPropNameText)]$paramAliasText$argumentCompleterText[$($p.TypeName)]`$$($p.Name)")
        $ParamFillerList.Add("if (`$PSBoundParameters['$($p.Name)']) {`$AllArgs += `$PSBoundParameters['$($p.Name)']}")
        if ($p.Description)
        {
            $HelpList.Add(".PARAMETER $($p.Name)" + [Environment]::NewLine + $p.Description)
        }
    }

    if ($commandSupportsFormat)
    {
        $paramList.Add("[Parameter(Mandatory=`$False)][switch]`$NativeOutput")
        $HelpList.Add(".PARAMETER NativeOutput" + [Environment]::NewLine + "Return output as text instead of objects")
    }

    $HelpLink = $HelpLinkMap[$functionName]
    if (-not [string]::IsNullOrEmpty($HelpLink))
    {
        $HelpList.Add(".LINK" + [Environment]::NewLine + $HelpLink)
    }

    $helptext = "<#
.SYNOPSIS
$($command.Description)
.DESCRIPTION
$($command.Description)
$($HelpList | Out-String)
#>"

    $functionAlias = $commandNameMap[ $command.Command ]
    $functionAliasText = ""
    if ($functionAlias)
    {
        $tmp = $functionName
        $functionName = $functionAlias
        $functionAlias = $tmp
        $functionAliasText = "[Alias(`"$functionAlias`")]"
    }

    $paramText = $paramList -join ",`n"

    $cmdPartList = New-Object Collections.Generic.List[string]
    $cmdPartList.Add("docker")
    $cmdPartList.Add($command.Command)

    $cmdText = $cmdPartList -join " "
    $ParamFillerText = $ParamFillerList -join "`n"


    $ftext = "
$helptext
function global:$functionName {
[CmdletBinding()]
$functionAliasText
param ($paramText)
PROCESS
{
`$AllArgs = @()
$ParamFillerText

`$VerboseMsg = `"Calling: & $cmdText `" + `$(`$AllArgs -join `" `")
Write-Verbose `$VerboseMsg

`$output = & $cmdText `$AllArgs

if (`$NativeOutput)
{
    `$output
}
else
{
    `$output | %{ `$_ | ConvertFrom-Json}
}
}
}"

    #$ftext
    $verboseText = "Generating function $functionName"
    if ($functionAlias)
    {
        $verboseText += " / $functionAlias"
    }
    Write-Verbose $verboseText
    Write-Verbose $ftext
    [scriptBlock]::Create($ftext).Invoke()
}

function New-DockerProxy
{
    [CmdletBinding()]
    param (
        # if non-empty - save generated module to this path
        [Parameter(Mandatory=$False)][string] $SaveToPath,

        [Parameter(Mandatory=$False)][int] $ParallelJobCount = 5,
        [Parameter(Mandatory=$False)][switch] $ParseOnly = $false,
        [Parameter(Mandatory=$False)][PSObject] $Command = $null
    )

    if (-not $Command)
    {
        Import-Module ThreadJob

        $text = docker --help
        [hashtable]$cmdsht = @{}
        . $Utilities

        # Read simple commands
        Parse-Command -text $text -pattern "^Commands:" | % {
            $cmdsht.Add($_.Command, $_.Description)
        }

        # Read management commands
        foreach($mgmtCmd in Parse-Command -text $text -pattern "^Management Commands:")
        {
            $mgmtCmdText = docker $mgmtCmd.Command --help
            foreach($mgmtSubCmd in Parse-Command -text $mgmtCmdText -pattern "^Commands:")
            {
                $cmdsht.Add($mgmtCmd.Command + " " + $mgmtSubCmd.Command, $mgmtSubCmd.Description)
            }
        }

        Write-Verbose "Command count = $($cmdsht.Count)"

        $ThrottleLimit = $ParallelJobCount
        Write-Verbose "ThrottleLimit set as $ThrottleLimit"
        #Write-Verbose "Job count set as $ParallelJobCount"
        $MaxItemCountPerfJob = $cmdsht.Count / $ParallelJobCount
        Write-Verbose "Max items per job set as $MaxItemCountPerfJob"

        $jobs = @()
        [hashtable]$tmp_cmdsht = @{}
        foreach ($cmd in $cmdsht.Keys)
        {
            if ($tmp_cmdsht.Count -ge $MaxItemCountPerfJob)
            {
                #Write-Verbose "Tmp command count = $($tmp_cmdsht.Count)"
                $jobs +=  Start-ThreadJob -ArgumentList @($tmp_cmdsht) -InitializationScript $Utilities -ThrottleLimit $ThrottleLimit -ScriptBlock {
                    param ([hashtable]$cmdsht)
                    Read-CommandsFromHelp -cmdsht $cmdsht
                }

                $tmp_cmdsht = @{}
            }

            $tmp_cmdsht.Add($cmd, $cmdsht[$cmd])
        }

        #Write-Verbose "Tmp command count = $($tmp_cmdsht.Count)"
        $jobs +=  Start-ThreadJob -ArgumentList @($tmp_cmdsht) -InitializationScript $Utilities -ThrottleLimit $ThrottleLimit -ScriptBlock {
            param ([hashtable]$cmdsht)
            Read-CommandsFromHelp -cmdsht $cmdsht
        }

        Write-Verbose "Started $($jobs.Count) parsing jobs"
        

        $items = $jobs | Receive-Job -Wait -AutoRemoveJob

        if ($ParseOnly)
        {
            return $items
        }
        else
        {
            $items | % { GenerateCommandProxy -command $_ }
        }
    }
    else
    {
        GenerateCommandProxy -command $Command
    }
}
