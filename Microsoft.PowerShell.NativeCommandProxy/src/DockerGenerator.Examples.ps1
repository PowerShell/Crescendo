# generate Docker proxy functions
Import-Module .\Microsoft.PowerShell.NativeCommandProxy\src\Microsoft.PowerShell.NativeCommandProxy.psd1 -Force
New-DockerProxy


# pull PowerShell preview Docker image and read PS version from it
$ImageName = 'mcr.microsoft.com/powershell'
Pull-DockerImage -Name "$ImageName`:preview"
$Image = Get-DockerImage -Repository $ImageName
$Image | Run-DockerCommand -Command 'pwsh' -Arg '-c','$psversiontable'
$Image | Remove-DockerImage -Force

# read cmdlet/parameter help
Get-Help Get-DockerImage -Full
# read online help for the cmdlet operation
Get-Help Get-DockerImage -Online