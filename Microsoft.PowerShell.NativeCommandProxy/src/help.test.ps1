# using module ./Microsoft.PowerShell.NativeCommandProxy.psd1
import-module -force ./Microsoft.PowerShell.NativeCommandProxy.psd1
$verb = "Invoke"
$noun = "Ifconfig"
$c = New-ProxyCommand -Verb $verb -Noun $noun
$c.OriginalName = "ifconfig"
$c.DefaultParameterSetName = 'standard'
$c.Description = "The ifconfig utility is used to assign an address to a network interface and/or configure network interface parameters."
$c.Usage = New-UsageInfo -usage 'ifconfig [-C] [-L] interface address_family [address [dest_address]] [parameters]'

$p1 = New-ParameterInfo -Name "Interface" -originalName "unused"
$p1.ParameterSetName = 'standard'
$p1.Position = 0
$p1.OriginalPosition = [Int32]::MaxValue - 1
$p1.Description = "This parameter is a string of the form 'name unit', for example, 'en0'."
$p1.ParameterType = [string]
$c.Parameters.Add($p1)

$p2 = New-ParameterInfo -Name "Family" -originalName "unused"
$p2.ParameterSetName = 'standard','link'
$p2.Position = 1
$p2.AdditionalParameterAttributes = '[ValidateSet("inet","inet6","link")]'
$p2.OriginalPosition = [Int32]::MaxValue
$p2.Description = "Specify the address family which affects interpretation of the remaining parameters.  Since an interface can receive transmissions in differing protocols with different naming schemes, specifying the address family is recommended.  The address or protocol families currently supported are 'inet', 'inet6', and 'link'.  The default is 'inet'.  'ether' and 'lladdr' are synonyms for 'link'"
$c.Parameters.Add($p2)

$p3 = New-ParameterInfo -Name "Link" -originalName "-l"
$p3.ParameterType = [int]
$p3.AdditionalParameterAttributes = "[ValidateRange(0,2)]"
$p3.ParameterSetName = "link"
$p3.OriginalPosition = 0
$p3.Description = "Disable special processing at the link level with the specified interface."
$c.Parameters.Add($p3)

$p4 = New-ParameterInfo -Name "RouteInfo" -originalname "-r"
$p4.ParameterType = [switch]
$p4.OriginalPosition = 0
$p4.Description = "Add additional information related to the count of route references on the network interface"
$c.Parameters.Add($p4)
$c.HelpLinks = "netstat","netintro","sysctl"

$funcDec = $c.ToString()
$t = $e = $null;
$null = [System.Management.Automation.Language.parser]::ParseInput($funcDec, [ref]$t, [ref]$e)
if ( $e.count -ne 0 ) {
   throw "Error for $funcDec" 
}

$funcDec