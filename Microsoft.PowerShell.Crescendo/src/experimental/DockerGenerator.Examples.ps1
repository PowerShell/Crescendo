# generate Docker proxy functions
Import-Module .\Microsoft.PowerShell.Crescendo\src\Microsoft.PowerShell.Crescendo.psd1 -Force
New-DockerProxy

# pull PowerShell preview Docker image and read PS version from it
$ImageName = 'mcr.microsoft.com/powershell'
Pull-DockerImage -Name "$ImageName`:preview"
$Image = Get-DockerImage -Repository $ImageName
$Image | Run-DockerCommand -Command 'pwsh' -Arg '-c','$psversiontable'
$Image | Remove-DockerImage -Force

# get times of previous container operations
Get-DockerContainer -Last 1 | Get-DockerContainerLogs -Timestamps

# get image history
Get-DockerImage -Repository <#tab-through-options#>fedora | Get-DockerImageHistory | Format-Table

# read cmdlet/parameter help
Get-Help Get-DockerImage -Full
# read online help for the operation
Get-Help Inspect-DockerContainer -Online

# tab-completion examples
Get-DockerImage -Repository <tab-through-options>
Inspect-DockerImage -Image <tab-through-options>
Get-DockerContainerLogs -Container <tab-through-options>
