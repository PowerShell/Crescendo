[CmdletBinding(DefaultParameterSetName="Default")]
param ( [Parameter(Mandatory=$true,ParameterSetName="file")]$file, [Parameter(ParameterSetName="file")][switch]$Generate, [Parameter(ParameterSetName="file")][switch]$force )
if ( ! $IsWindows ) {
    throw "this can only be run on Windows"
}
$exe = "winget"
$helpChar = "-?"
$commandPattern = "commands are available:"
$optionPattern = "options are available:"
$usagePattern = "^usage: (?<usage>.*)"
$argumentPattern = "arguments are available:"
$headerLength = 3
$linkPattern = "^More help can be found at: (?<link>.*)"
$parmPattern = "--(?<pname>\w+)\s+(?<phelp>.*)"

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
        $c.Platform = "Windows"
        $c.OriginalText = $this.OriginalHelptext -join ""
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
    $usage = ""
    for($i = $offset; $i -lt $helpText.Count; $i++) {
        if ($helpText[$i] -match $usagePattern) {
            $usage = $matches['usage']
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
                if ($helpText[$i] -match $parmPattern) {
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
    $c = [wingetcommand]::new()
    $c.exe = $exe
    $c.commandElements = $commandProlog
    $c.Verb = "Invoke"
    $c.Noun = $($exe;$commandProlog) -join ""
    $c.Parameters = $parameters
    $c.Usage = $usage
    $c.Help = $cmdhelp
    $c.Link = $link
    $c.OriginalHelptext = $helpText
    $c
}

$commands = parseHelp -exe $exe -commandProlog @() | ForEach-Object { $_.GetCrescendoCommand()}

$h = [ordered]@{
    '$schema' = 'https://aka.ms/PowerShell/Crescendo/Schemas/2021-11'
    'Commands' = $commands
}

if ( ! $Generate ) {
    $h
    return
}

$sOptions = [System.Text.Json.JsonSerializerOptions]::new()
$sOptions.WriteIndented = $true
$sOptions.MaxDepth = 20
$sOptions.IgnoreNullValues = $true

$parsedConfig = [System.Text.Json.JsonSerializer]::Serialize($h, $sOptions)

if ( $file ) {
    if (test-path $file) {
        if ($force) {
            $parsedConfig > $file
        }
        else {
            Write-Error "'$file' exists, use '-force' to overwrite"
        }
    }
    else {
        $parsedConfig > $file
    }
}
else {
    $parsedConfig
}
