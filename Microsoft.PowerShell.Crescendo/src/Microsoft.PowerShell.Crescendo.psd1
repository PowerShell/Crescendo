#
# Module manifest for module 'Microsoft.PowerShell.Crescendo'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Microsoft.PowerShell.Crescendo.psm1'

# Version number of this module.
ModuleVersion = '0.4.1'

# ID used to uniquely identify this module
GUID = '2dd09744-1ced-4636-a8ce-09a0bf0e566a'

Author = 'Microsoft Corporation'
CompanyName = 'Microsoft Corporation'
Copyright = '(c) Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = "Module that improves user experience with native commands"

# Link to updateable help
HelpInfoUri = 'https://aka.ms/ps-modules-help'

# Types and Formats to process
TypesToProcess = 'Microsoft.PowerShell.Crescendo.Types.ps1xml'
FormatsToProcess = 'Microsoft.PowerShell.Crescendo.Format.ps1xml'

# Minimum version of the Windows PowerShell engine required by this module is version 7
# the resultant module may be run on PowerShell 5.1
PowerShellVersion = '7.0'

# Functions to export from this module
FunctionsToExport = @(
    'New-ExampleInfo',
    'New-CrescendoCommand',
    'New-ParameterInfo',
    'New-UsageInfo',
    'Import-CommandConfiguration',
    'Export-Schema',
    'Export-CrescendoModule'
    )
}
