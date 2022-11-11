#
# Module manifest for module 'Microsoft.PowerShell.Crescendo'
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'Microsoft.PowerShell.Crescendo.psm1'

# Version number of this module.
ModuleVersion = '1.1.0'

# ID used to uniquely identify this module
GUID = '2dd09744-1ced-4636-a8ce-09a0bf0e566a'

Author = 'Microsoft Corporation'
CompanyName = 'Microsoft Corporation'
Copyright = '(c) Microsoft Corporation. All rights reserved.'

# Description of the functionality provided by this module
Description = "Module that improves user experience with native commands"

# Link to updateable help
HelpInfoUri = 'https://aka.ms/ps-modules-help'

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
    'New-OutputHandler',
    'Import-CommandConfiguration',
    'Export-Schema',
    'Export-CrescendoModule',
    'Export-CrescendoCommand',
    'Test-IsCrescendoCommand'
    )

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = @('Crescendo', 'Software Generation')

        # A URL to the license for this module.
        LicenseUri = 'https://github.com/PowerShell/Crescendo/blob/master/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://github.com/PowerShell/Crescendo'

        # A URL to an icon representing this module.
        IconUri = 'https://raw.githubusercontent.com/PowerShell/Crescendo/master/Assets/Crescendo-x85.ico'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        Prerelease = 'Preview01'

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        RequireLicenseAcceptance = $false

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

        } # End of PSData hashtable

    } # End of PrivateData hashtable
}
