#
# Module manifest for module 'Microsoft.PowerShell.NativeCommandProxy'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Microsoft.PowerShell.NativeCommandProxy.psm1'

# Version number of this module.
ModuleVersion = '0.3.1'

# ID used to uniquely identify this module
GUID = '2dd09744-1ced-4636-a8ce-09a0bf0e566a'

Author = 'Microsoft Corporation'
CompanyName = 'Microsoft Corporation'
Copyright = '(c) Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = "Module that improves user experience with native commands"

# Minimum version of the Windows PowerShell engine required by this module
# setting to V7 for the moment
PowerShellVersion = '5.1'

# Functions to export from this module
FunctionsToExport = @(
    'New-ExampleInfo',
    'New-ProxyCommand',
    'New-ParameterInfo',
    'New-UsageInfo',
    'Import-CommandConfiguration',
    'Export-Schema',
    'Export-ProxyModule'
    )

HelpInfoURI = 'https://github.com/PowerShell/PowerShell'
}
