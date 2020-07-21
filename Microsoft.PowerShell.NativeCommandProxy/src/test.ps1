import-module -force ./Microsoft.PowerShell.NativeCommandProxy.psd1
$c = New-ProxyCommand -Verb Get -Noun Thing
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
$c.Parameters.Add($p1)
$c.Parameters.Add($p2)
$c.Parameters.Add($p3)
$funcDec = $c.ToString()
$funcDec > /tmp/prox.ps1
$t = $e = $null;
$null = [System.Management.Automation.Language.parser]::ParseInput($funcDec, [ref]$t, [ref]$e)
$e.count -eq 0 ? "OK" : $e