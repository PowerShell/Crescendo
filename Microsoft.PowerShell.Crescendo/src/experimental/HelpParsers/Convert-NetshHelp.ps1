[CmdletBinding()]
param ( $file, [switch]$force )
if ( ! $IsWindows ) {
    throw "this can only be run on Windows"
}
$exe = "netsh.exe"
$helpChar = "-?"
$commandPattern = "Commands in this context:$"
$optionPattern = "options are available:"
$usagePattern = "^Usage: (?<usage>.*)"
$argumentPattern = "arguments are available:"
$headerLength = 0
$linkPattern = "^More help can be found at: (?<link>.*)"
$parmPattern = "--(?<pname>\w+)\s+(?<phelp>.*)"

class ParsedCommand {
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
        if ( $this.Usage ) {
            $c.Usage = New-UsageInfo -usage $this.Usage
        }
        else {
            Write-Verbose ("skipping usage for " + ($this.commandElements -join " "))
        }
        if ( $this.CommandElements ) {
            $c.OriginalCommandElements = $this.commandElements | foreach-object {$_}
        }
        $c.Platform = "Windows"
        $c.OriginalText = $this.OriginalHelptext -join ([char]5)
        $c.Description = $this.Help -join "`n"
        $c.HelpLinks = $this.Link
        foreach ( $p in $this.Parameters) {
            $parm = New-ParameterInfo -name $p.Name -originalName $p.OriginalName
            $parm.Description = $p.Help
            if ( $p.Position -ne [int]::MaxValue ) {
                $parm.Position = $p.Position
            }
            $c.Parameters.Add($parm)
        }
        return $c
    }
    [string]GetCrescendoJson() {
        return $this.GetCrescendoCommand().GetCrescendoConfiguration()
    }
}

class cParameter {
    [string]$Name
    [string]$OriginalName
    [string]$Help
    [int]$Position = [int]::MaxValue
    cParameter([string]$name, [string]$originalName, [string]$help) {
        $this.Name = $name
        $this.OriginalName = $originalName
        $this.Help = $help
    }
}

function Get-Parm ( $parameterString ) {
    write-verbose $parameterString
}

function Test-ParameterContinue {
    param ( [string[]]$text, [int]$offset )
    [bool]$continues = $false
    if ($offset -ge $text.Count ) {
        break
    }
    elseif ( $text[$i+1] -match "^\s{9}(?<parm>[^\s].*)" ) {
        $continues = $true
    }
    elseif ( $text[$i+1] -match "^\s{13}[^\s]" ) {
        $continues = $true
    }
    elseif ( $text[$i].Trim() -match "\|$" ) {
        $continues = $true
    }
    elseif ( $text[$i+1].Trim() -match "^\|" ) {
        $continues = $true
    }
    return $continues
}

function Test-IsParameter {
    param ( [string[]]$text, [int]$offset )
    if ( $offset -ge $text.Count ) {
        return $false
    }
    [string]$possibleParameter = $text[$offset].Trim()
    if ( $possibleParameter -eq "Not Supported." ) {
        return $false
    }
    elseif ( $possibleParameter -eq "Please go to the Network Connections folder to install." ){
        return $false
    }
    elseif ( $text[$offset] -match "^\s{6}(?<parm>[^\s].*)" ) {
        return $true
    }
    return $false
}

function Get-ParameterFromUsage ( [string[]]$prolog, [string]$usage ) {

    #wait-debugger
    $pnum = $prolog.count - 1
    if ( $pnum -ge 0 ) {
        foreach ( $i in 0..$pnum ) {
            $plog = $prolog[${i}..($pnum)] -join " "
            if ( $usage -match "$plog" ) {
                $parm = $usage -replace ".*${plog}"
                $parm = "$parm".Trim()
                # if ( $parm -match " " ) { wait-debugger  }
                if ( "$parm" -eq "" ){ Write-Verbose ("trimmed everything from $usage with " + ($prolog -join ":"))}
                return "$parm"
            }
        }
    }
    if ( $usage -match ".*${exe} (?<parms>.*)" ) {
        $parm = $matches['parms'].Trim()
        # if ( $parm -match " " ) { wait-debugger  }
        return $parm
    }
    # wait-debugger
    Write-verbose "no parameter in $usage"
    return "no parameter"
}

function Find-Parameters ( [string[]]$text, [int]$offset, [ref][int]$newOffset ) {
    $parameters = @()

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
    while ( $helpText[$offset] -ne "" -and $offset -lt $helpText.Count) {
        $cmdhelp += $helpText[$offset++]
    }
    #$cmdHelpString = $cmdhelp -join " "
    $parameters = @()
    $usage = $help = ""
    for($i = $offset; $i -lt $helpText.Count; $i++) {
        if ($helpText[$i] -match $usagePattern) {
            $usage = $matches['usage']
            try {
                $pp = get-parameterfromusage -prolog $commandprolog -usage $usage
                if ( $pp ) {
                    $parameters += $pp
                }
            }
            catch {
                wait-debugger
            }
            continue
            # this mess is about finding parameters - skip for now
            while ( Test-ParameterContinue -text $helpText -offset $i ) {
                $i++
                $usage += $helpText[$i].Trim()
                #wait-debugger
            }
            # manage parameters here
            $i++
            while($i -lt $helpText.Count -and $helpText[$i][0] -eq " ") {
                if (Test-IsParameter -text $helpText -offset $i) {
                    $helptext[$offset] -match "\s{6}(?<parm>[^\s].*)"
                    try {
                        $p = $matches['parm'].Trim()
                    }
                    catch {
                        #wait-debugger
                    }

                    while ( Test-ParameterContinue -text $helpText -offset $i ) {
                        $i++
                        $p += $helpText[$i].Trim()
                        #wait-debugger
                    }
                    if ( $p -match "not supported" ) { wait-debugger }
                    if ( ! "$p".Trim() ) { wait-debugger }
                    Get-Parm -parameterString $p
                    $parameters += $p
                    $p = ""
                    $matches = $null
                }
                $i++
                
            }
        }
        elseif ($helpText[$i] -match $linkPattern ) {
            $link = $matches['link']
        }
        elseif ($helpText[$i] -match $optionPattern) {
            $i++
            while($helpText[$i] -ne "") {
                if ($helpText[$i] -match $parmPattern) {
                    $originalName = "--" + $matches['pname']
                    $pHelp = $matches['phelp']
                    $pName = $originalName -replace "[- ]"
                    $p = [cParameter]::new($pName, $originalName, $pHelp)
                    $parameters += $p
                }
                $i++
            }
        }
        elseif ($helpText[$i] -match $argumentPattern) {
            $i++
            $position = 0
            while($helpText[$i] -ne "") {
                if ($helpText[$i] -match $parmPattern -and $i -lt $helpText.Count) {
                    $originalName = "--" + $matches['pname']
                    $pHelp = $matches['phelp']
                    $pName = $originalName -replace "[- ]"
                    $p = [cParameter]::new($pName, $originalName, $pHelp)
                    $p.Position = $position++
                    $parameters += $p
                }
                $i++
            }
        }
        elseif ($helpText[$i] -match $commandPattern) {
            $i++
            $subCommands = @()
            while($helpText[$i] -ne "" -and $i -le $helpText.Count) {
                try {
                    $t = $helpText[$i].Trim()
                }
                catch {
                    break
                }
                $subCommands, $subHelp = $t.split("-", 2, [System.StringSplitOptions]::RemoveEmptyEntries)
                $subcommand = $subCommands.Trim().Split(" ",[System.StringSplitOptions]::RemoveEmptyEntries)[-1]
                if ( $helpText[$i+1] -and $helpText[$i+1][0] -eq " " ) {
                    $i++
                    while($helpText[$i+1] -and $helpText[$i][0] -eq " " -and $i -lt $helpText.Count) {
                        $subHelp += " " + $helpText[$i].Trim()
                        $i++
                    }
                }
                #$subCommand, $dash, $subHelp = $t.split(" ",3, [System.StringSplitOptions]::RemoveEmptyEntries)
                # skip '?' and 'help'
                if ( $subCommand -eq "?" -or $subCommand -eq "help") {
                    $i++
                    continue
                }
                $cPro = $commandProlog
                $cPro += $subCommand
                #if ( $cPro[0] -eq "firewall" -and $cPro[1] -eq "add") {
                #    wait-debugger
                #}
                #write-host (">>> " + ($cPro -join " "))
                parseHelp -exe $exe -commandProlog $cPro
                $i++
            }
        }
    }
    $c = [Parsedcommand]::new()
    $c.exe = $exe
    $c.commandElements = $commandProlog
    $c.Verb = "Invoke"
    $c.Noun = $("$exe" -replace ".exe";$commandProlog).Foreach({"$_".split("-")}).Foreach({[char]::ToUpper("$_"[0]) + "$_".SubString(1).toLower()}) -join ""
    # $c.Parameters = $parameters
    $c.Usage = $usage
    $c.Help = $cmdhelp
    $c.Link = $link
    $c.OriginalHelptext = $helpText
    $c
}

$commands = parseHelp -exe $exe -commandProlog @() 
$trimmedCommands = $commands.Where({$_.Usage -or ($_.commandElements -contains "show" -and $_.commandElements[-1] -ne "show")})
$convertedCommands = $trimmedCommands | ForEach-Object { $_.GetCrescendoCommand()}

$global:parsedCommands = $convertedCommands

$h = [ordered]@{
    '$schema' = 'https://raw.githubusercontent.com/PowerShell/Crescendo/master/Microsoft.PowerShell.Crescendo/src/Microsoft.PowerShell.Crescendo.Schema.json'
    'Commands' = $convertedCommands
}

$sOptions = [System.Text.Json.JsonSerializerOptions]::new()
$sOptions.WriteIndented = $true
$sOptions.MaxDepth = 20
$sOptions.IgnoreNullValues = $true

$ParsedConfig = [System.Text.Json.JsonSerializer]::Serialize($h, $sOptions)

if ( ! $file ) {
    $parsedConfig 
}
else {
    if ($file -and (!(test-path $file) -or $force)) {
        $ParsedConfig > $file
    }
    else {
        throw "$file exists"
    }
}
