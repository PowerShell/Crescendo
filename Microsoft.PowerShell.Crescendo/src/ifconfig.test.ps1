import-module -force ./Microsoft.PowerShell.Crescendo.psd1
$verb = "Invoke"
$noun = "Ifconfig"
$proxyCommand = "{0}-{1}" -f $verb, $noun
$c = New-ProxyCommand -Verb Invoke -Noun Ifconfig
$c.OriginalName = "ifconfig"
$c.DefaultParameterSetName = 'standard'
$p1 = New-ParameterInfo -Name "Interface" -originalName "unused"
$p1.ParameterSetName = 'standard'
$p1.Position = 0
$p1.OriginalPosition = 0
$p2 = New-ParameterInfo -Name "Family" -originalName "unused"
$p2.ParameterSetName = 'standard','link'
$p2.Position = 1
$p2.OriginalPosition = 1
$p3 = New-ParameterInfo -Name "Link" -originalName "-l"
$p3.ParameterType = [switch]
$p3.ParameterSetName = "link"
$p3.OriginalPosition = 0
$p4 = New-ParameterInfo -Name "RouteInfo" -originalname "-r"
$p4.ParameterType = [switch]
$p4.OriginalPosition = 0
$c.Parameters.Add($p1)
$c.Parameters.Add($p2)
$c.Parameters.Add($p3)
$c.Parameters.Add($p4)
$funcDec = $c.ToString()
$t = $e = $null;
$null = [System.Management.Automation.Language.parser]::ParseInput($funcDec, [ref]$t, [ref]$e)
if ( $e.count -ne 0 ) {
   throw "Error for $funcDec" 
}

# output the proxy
# this is specific to MacOS ifconfig output
function Convert-IfconfigOutput([string[]]$t) {
    for ( $i = 0; $i -lt $t.count; $i++) {
        if ( $t[$i] -match "^(?<iface>[a-z](\w|\d)+): flags=(?<flgn>\d+)<(?<vals>.[^>]*)> mtu (?<mtu>\d+)" ) {
            $h = @{
                Interface = $matches.iface
                Id = [int]$matches.flgn
                Options = $matches.vals.split(",").Foreach({"$_".Trim()})
                MTU = [int]$matches.mtu
            }
            while ( $t[$i+1] -and ($t[$i+1][0] -eq "`t")) {
                $i++
                $line = $t[$i]
                if ( $line -match "inet6 " ) {
                    $segments = "$line".Trim().Split(" ")
                    if ( $segments.count -ge 4 ) {
                        $h['Inet6'] = $segments[1]
                        $h['PrefixLength'] = [int]$segments[3]
                    }
                }
                elseif ( $line -match "inet " ) {
                    $segments = "$line".Trim().Split(" ")
                    if ( $segments.count -ge 4 ) {
                        $h['Inet'] = $segments[1]
                        $h['netmask'] = [string]$segments[3]
                        $h['broadcast'] = $segments[5]
                    }
                }
            }
            [PSCustomObject]$h
        }
    }
}

# create the proxy
Invoke-Expression $funcDec

# invoke the proxy
"With Route"
& $proxyCommand -route -interface en0 -debug -verbose > WithRoute.txt
"Without Route"
& $proxyCommand -interface en0 -debug -verbose > WithoutRoute.txt
diff WithRoute.txt WithoutRoute.txt
