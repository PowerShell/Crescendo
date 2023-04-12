# PowerShell Crescendo

Crescendo is a development accelerator enabling you to rapidly build PowerShell cmdlets that
leverage existing command-line tools. Crescendo amplifies the command-line experience of the
original tool to include object output for the PowerShell pipeline, privilege elevation, and
integrated help information. A Crescendo module replaces cumbersome command-line tools with
PowerShell cmdlets that are easier to use in automation and packaged to share with team members.

The 1.0.0 release includes the following features:

- Ability to define cmdlets from simple `key/value` statements in a JSON file
- Support for modular design - cmdlet definitions can be in a one or more JSON files
- A JSON schema that helps you create your Crescendo configuration using IntelliSense and tooltips
- Three styles of output handling code allowing you to separate your code from the cmdlet
  definitions for easier debugging and development
- Privilege elevation mechanisms in **Windows**, **Linux**, and **macOS**
- Crescendo generates a PowerShell script module ready for deployment
- While Crescendo requires PowerShell 7 or higher for authoring configurations, the generated module
  can run on Windows PowerShell 5.1 and higher
- Example configurations for you to copy and reuse
- Experimental Help parsers that provide proof-of-concept examples for auto-generating cmdlet
  configurations

The 1.1.0 release adds the following features:

- New schema to support additional parameter properties
- Added `Export-CrescendoCommand` cmdlet
- Added **NoClobber** parameter to `Export-CrescendoModule`
- Added the ability to bypass all output handling
- Added the ability to handle native command errors in the output handler
- Added the ability to transform arguments

## Installing Crescendo

Requirements:

- **Microsoft.PowerShell.Crescendo** requires PowerShell 7.0 or higher

To install **Microsoft.PowerShell.Crescendo**:

```powershell
Install-Module -Name Microsoft.PowerShell.Crescendo
```

To install **Microsoft.PowerShell.Crescendo** using the new
[PowerShellGet.v3](https://www.powershellgallery.com/packages/PowerShellGet/3.0.12-beta)

```powershell
Install-PSResource -Name Microsoft.PowerShell.Crescendo
```

## Documentation and more information

To get started using Crescendo, check out the
[documentation](https://docs.microsoft.com/powershell/utility-modules/crescendo/overview).

For a detailed walkthrough using Crescendo, see this excellent blog series from Sean Wheeler -
Thanks Sean!

- Crescendo on the [PowerShell Community Blog](https://devblogs.microsoft.com/powershell-community/tag/crescendo/).

## Future plans

We value your ideas and feedback and hope you will give Crescendo a try and let us know of any
issues you find.

## Release history

Release announcements on the [PowerShell Blog](https://devblogs.microsoft.com/powershell/tag/powershell-crescendo/).

- Dec-2022 - Crescendo 1.1.0-Preview01
- Mar-2022 - Crescendo 1.0.0 GA
- Dec-2021 - Crescendo.RC
- Oct-2021 - Crescendo.Preview.4
- Jul-2021 - Crescendo.Preview.3
- May-2021 - Crescendo.Preview.2
- Dec-2020 - Crescendo.Preview.1
