param ( $file = "KubectlGenerated.Crescendo.Json", [switch]$force )
$headerLength = 0
$exe = "kubectl"
$helpChar = "--help"
$commandPattern = "Commands:|Commands .*\):"
$optionPattern = "Options:"
$usagePattern = "^Usage:"
$argumentPattern = "arguments are available:"
$linkPattern = "^More help can be found at: (?<link>.*)"
#$parmPattern = "--(?<pname>\w+)\s+(?<phelp>.*)"
$parmPattern = "(-(?<alias>[\w-]*), )?--(?<pname>[\w-]+=)(?<value>.[^:]*):\s+(?<phelp>.*)"

class WinGetCommand {
    [string]$exe
    [string[]]$commandElements
    [string]$Verb
    [string]$Noun
    [cParameter[]]$Parameters
    [string]$Usage
    [string[]]$Help
    [string]$Link
    [string[]]$OriginalHelptext
    [object]GetCrescendoCommand() {
        $c = New-CrescendoCommand -Verb $this.Verb -Noun $this.Noun -originalname $this.exe
        $c.Usage = New-UsageInfo -usage $this.Usage
        if ( $this.CommandElements ) {
            $c.OriginalCommandElements = $this.commandElements | foreach-object {$_}
        }
        $c.OriginalText = $this.OriginalHelptext -join ""
        $c.Description = $this.Help -join "`n"
        $c.HelpLinks = $this.Link
        foreach ( $p in $this.Parameters) {
            $pName = $p.GetPSParameterName()
            $origName = $p.OriginalName
            if ( $p.ParameterType -match "switch") {
                $origName = $origName.Trim("=")
            }
            $parm = New-ParameterInfo -name $pName -originalName $origName
            $parm.Description = $p.Help
            $parm.ParameterType = $p.ParameterType
            #$parm.Aliases = $p.Alias
            $parm.NoGap = $true
            $allowedValues = $p.GetAllowedValues()
            if( $allowedValues.Count -gt 0 ) {
                if ( $pName -eq "output" -and $allowedValues -contains "json" ) {
                    $parm.DefaultValue = "json"
                }
                $parm.AdditionalParameterAttributes = ("[ValidateSet('$($allowedValues -join ''',''')')]")
            }
            if ( $p.Position -ne [int]::MaxValue ) {
                $parm.Position = $p.Position
            }
            $c.Parameters.Add($parm)
        }
        # it looks like we have a positional parameter
        if ($this.Usage -cmatch "\[NAME ") {
            $p = New-ParameterInfo -name "Name" -originalName ""
            $p.Position = 0
            $p.OriginalPosition = 0
            $p.Description = "Name"
            $p.ParameterType = "string"
            $c.Parameters.Add($p)
        }
        if ($c.Parameters.Name -eq "output") {
            $parm = $c.Parameters|Where-Object { $_.name -eq "output" }
            if ( $parm.Description -match "json" ) {
                $handler = New-OutputHandler
                $handler.ParameterSetName = "Default"
                $handler.StreamOutput = $true
                $handler.Handler = '($input | convertfrom-json).items'
                $c.OutputHandlers = $handler
            }
        }
        return $c
    }
    [string]GetCrescendoJson() {
        return $this.GetCrescendoCommand().GetCrescendoConfiguration()
    }
}

class cParameter {
    [string]$OriginalName
    [string]$Help
    [string]$ParameterType = "string"
    [string]$alias
    [string[]]$AllowedValues
    [int]$Position = [int]::MaxValue
    cParameter([string]$originalName, [string]$help) {
        $this.OriginalName = $originalName
        $this.Help = $help
    }
    [string] GetPSParameterName() {
        try {
        $t = $this.OriginalName.Replace("=","").Split("-",[StringSplitOptions]::RemoveEmptyEntries).ForEach({[char]::ToUpper("$_"[0]) + "$_".SubString(1).ToLower()}) -join ""
        return $t
        }
        catch {
            wait-debugger
        }
        return ""
    }
    [string[]]GetAllowedValues() {
        if ( $this.Help -match "One of: (?<values>.[^\.]+)\." ) {
            return $matches['values'].Split("|",[StringSplitOptions]::RemoveEmptyEntries)
        }
        return @()
    }
}

function capString {
    param ( [Parameter(Position=0,Manditory=$true,ValueFromPipeline=$true)][string[]]$text )
    PROCESS {
        $text.ForEach
    }
}

function parseHelp([string]$exe, [string[]]$commandProlog) {
    write-progress ("parsing help for '$exe " + ($commandProlog -join " ") + "'")
    if ( $commandProlog ) {
        $helpText = & $exe $commandProlog $helpChar
    }
    else {
        $helpText = & $exe $helpChar
    }
    $offset = $headerLength
    $cmdhelp = @()
    while ( $helpText[$offset] -ne "") {
        $cmdhelp += $helpText[$offset++]
    }
    #$cmdHelpString = $cmdhelp -join " "
    $parameters = @()
    $usage = $help = ""
    for($i = $offset; $i -lt $helpText.Count; $i++) {
        if ($helpText[$i] -match $usagePattern) {
            $i++
            $usageText = @()
            while($helpText[$i] -ne "") {
                $usageText += $helpText[$i].Trim()
                $i++
            }
            $usage = $usageText -join " "
        }
        elseif ($helpText[$i] -match $linkPattern ) {
            $link = $matches['link']
        }
        elseif ($helpText[$i] -match $optionPattern) {
            $i++
            while($helpText[$i] -ne "") {
                if ($helpText[$i] -match $parmPattern) {
                    $parameterMatch = $matches
                    $originalName = "--" + $matches['pname']
                    $pHelp = $matches['phelp']
                    $pName = $originalName -replace "[- ]"
                    $p = [cParameter]::new($originalName, $pHelp)
                    $p.Alias = $matches['alias']
                    #if ( $matches['value'] -and $matches['pname'] -match "all-namespaces" ) { wait-debugger }
                    if ( $parameterMatch['value'] -match "false" ) {
                        $p.ParameterType = "switch"
                    }
                    $parameters += $p
                }
                $i++
            }
        }
        elseif ($helpText[$i] -match $argumentPattern) {
            $i++
            $position = 0
            while($helpText[$i] -ne "") {
                if ($helpText[$i] -match $parmPattern) {
                    $originalName = "--" + $matches['pname']
                    $pHelp = $matches['phelp']
                    $p = [cParameter]::new($originalName, $pHelp)
                    $p.Alias = $matches['alias']
                    $p.Position = $position++
                    if ( $matches['value'] -match "false" ) {
                        $p.ParameterType = "switch"
                    }
                    $parameters += $p
                }
                $i++
            }
        }
        elseif ($helpText[$i] -match $commandPattern) {
            $i++
            $subCommands = @()
            while($helpText[$i] -ne "") {
                $t = $helpText[$i].Trim()
                $subCommand, $subHelp = $t.split(" ",2, [System.StringSplitOptions]::RemoveEmptyEntries)
                #write-host ">>> $subCommand"
                $cPro = $commandProlog
                $cPro += $subCommand
                parseHelp -exe $exe -commandProlog $cPro
                $i++
            }
        }
    }
    $c = [WinGetCommand]::new()
    $c.exe = $exe
    $c.commandElements = $commandProlog
    $c.Verb = "Invoke"
    $c.Noun = $($exe;$commandProlog).Foreach({"$_".split("-")}).Foreach({[char]::ToUpper("$_"[0]) + "$_".SubString(1).toLower()}) -join ""
    write-host ("setting noun to " + $c.noun)
    $c.Parameters = $parameters
    $c.Usage = $usage
    $c.Help = $cmdhelp
    $c.Link = $link
    $c.OriginalHelptext = $helpText
    $c
}

$commands = parseHelp -exe $exe -commandProlog @() | ForEach-Object { $_.GetCrescendoCommand()}
# wait-debugger

$h = [ordered]@{
    '$schema' = 'https://raw.githubusercontent.com/PowerShell/Crescendo/master/Microsoft.PowerShell.Crescendo/src/Microsoft.PowerShell.Crescendo.Schema.json'
    'Commands' = $commands
}

$sOptions = [System.Text.Json.JsonSerializerOptions]::new()
$sOptions.WriteIndented = $true
$sOptions.MaxDepth = 20
$sOptions.IgnoreNullValues = $true

$winGetConfig = [System.Text.Json.JsonSerializer]::Serialize($h, $sOptions)

if ( $file -and (test-path $file) -and $force ) {
    Remove-Item $file
}
if ( $file -and !(test-path $file)) {
    $winGetConfig > $file
}
else {
    $winGetConfig
}
