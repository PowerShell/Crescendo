---
description: This article provides examples for using the Crescendo cmdlets to create a configuration. This can be used as an alternate for manually created the JSON configuration file.
ms.date: 06/28/2023
title: Create a Crescendo configuration using the Crescendo cmdlets
---
# Create a Crescendo configuration using the Crescendo cmdlets

The Crescendo module includes a set of cmdlets that create various Crescendo object types. You can
use these cmdlets to create a Crescendo configuration without the need to manually edit a JSON file.

During the design of Crescendo, we created these cmdlets before the decision that module and cmdlet
creation could be better served by a declarative approach. Their utility was still appreciated, so
we decided to support both approaches.

> [!IMPORTANT]
> Since developer tools like Visual Studio Code (VS Code) provide IntelliSense based on the JSON
> schema, creating the configuration by editing the JSON file is the preferred method for authoring
> a configuration. This article is provided as an example for how the cmdlets could be used.

## Create a configuration for two cmdlets

This example shows how to create the configuration for two cmdlets that wrap the Windows
command-line tool `VSSAdmin.exe`. Specifically, the script creates cmdlets for the
`vssadmin list providers` and `vssadmin list shadows` commands.

By inspecting the help for these two commands, you can see that `vssadmin list providers` takes no
additional parameters, but `vssadmin list shadows` has a combination of optional parameters forming
multiple parameter sets.

```powershell
vssadmin list providers /?
vssadmin list shadows /?
```

```Output
vssadmin 1.1 - Volume Shadow Copy Service administrative command-line tool
(C) Copyright 2001-2013 Microsoft Corp.

List Providers
    - List registered volume shadow copy providers.

     Example Usage:  vssadmin List Providers

vssadmin 1.1 - Volume Shadow Copy Service administrative command-line tool
(C) Copyright 2001-2013 Microsoft Corp.

List Shadows [/For=ForVolumeSpec] [/Shadow=ShadowId|/Set=ShadowSetId]
    - Displays existing shadow copies on the system.  Without any options,
    all shadow copies on the system are displayed ordered by shadow copy set.
    Combinations of options can be used to refine the list operation.
    - The Shadow Copy ID can be obtained by using the List Shadows command.
    When entering a Shadow ID, it must be in
    the following format:
       {XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}
    where the X's are hexadecimal characters.

    Example Usage:  vssadmin List Shadows
                             /Shadow={c5946237-af12-3f23-af80-51aadb3b20d5}
```

For the `vssadmin list shadows` command, you can see that the `/For` parameter is optional and can
be used alone or with either of the `/Shadow` or `/ShadowSetId` parameters. This results in three
possible parameter sets.

### The script code

The following script defines the configuration for two new cmdlets. The comments in the script
provide the following outline of tasks:

- Create an empty configuration object
  - Create first Crescendo command and set its properties
    - Add an example to the command
    - Add an Output Handler to the command
    - Add the command to the Commands collection of the configuration
  - Create second Crescendo command and set its properties
    - Add multiple examples to the command
    - Define the parameters and parameter sets
    - Add an Output Handler to the command
  - Add the command to the Commands collection of the configuration
- Export the configuration to a JSON file and create the module

The configuration contains references to Output Handler functions. These functions are contained in
a separate script file that must be dot-source loaded into your session before you can export the
configuration to create a new PowerShell module. For a detailed explanation of these Output
Handlers, see [this series of posts][blog] on the **PowerShell Community** blog.

```powershell
# Create an empty array for Command object
$CrescendoCommands = @()

## Create first Crescendo command and set its properties
$cmdlet = @{
    Verb = 'Get'
    Noun = 'VssProvider'
    OriginalName = '$env:Windir/system32/vssadmin.exe'
}
$newCommand = New-CrescendoCommand @cmdlet
$newCommand.OriginalCommandElements = @('list','providers')
$newCommand.Description = 'List registered volume shadow copy providers'
$newCommand.Usage = New-UsageInfo -usage $newCommand.Description
$newCommand.Platform = @('Windows')

### Add an example to the command
$example = @{
    Command = 'Get-VssProvider'
    Description = 'Get a list of VSS Providers'
    OriginalCommand = 'vssadmin list providers'
}
$newCommand.Examples += New-ExampleInfo @example

### Add an Output Handler to the command
$handler = New-OutputHandler
$handler.ParameterSetName = 'Default'
$handler.HandlerType = 'Function'
$handler.Handler = 'ParseProvider'
$newCommand.OutputHandlers += $handler

## Add the command to the Commands collection of the configuration
$CrescendoCommands += $newCommand

## Create second Crescendo command and set its properties
$cmdlet = @{
    Verb = 'Get'
    Noun = 'VssShadow'
    OriginalName = '$env:Windir/system32/vssadmin.exe'
}
$newCommand = New-CrescendoCommand @cmdlet
$newCommand.OriginalCommandElements = @('list','shadows')
$newCommand.Description = 'List existing volume shadow copies. Without any options, ' +
    'all shadow copies on the system are displayed ordered by shadow copy set. ' +
    'Combinations of options can be used to refine the output.'
$newCommand.Usage = New-UsageInfo -usage 'List existing volume shadow copies.'
$newCommand.Platform = ,'Windows'

### Add multiple examples to the command
$example = @{
    Command = 'Get-VssShadow'
    Description = 'Get a list of VSS shadow copies'
    OriginalCommand = 'vssadmin list shadows'
}
$newCommand.Examples += New-ExampleInfo @example
$example = @{
    Command = 'Get-VssShadow -For C:'
    Description = 'Get a list of VSS shadow copies for volume C:'
    OriginalCommand = 'vssadmin list shadows /For=C:'
}
$newCommand.Examples += New-ExampleInfo @example
$example = @{
    Command = "Get-VssShadow -Shadow '{c17ebda1-5da3-4f4a-a3dc-f5920c30ed0f}"
    Description = 'Get a specific shadow copy'
    OriginalCommand = 'vssadmin list shadows /Shadow={3872a791-51b6-4d10-813f-64b4beb9f935}'
}
$newCommand.Examples += New-ExampleInfo @example

### Define the parameters and parameter sets
$newCommand.DefaultParameterSetName = 'Default'

#### Add a new parameter to the command
$parameter = New-ParameterInfo -OriginalName '/For=' -Name 'For'
$parameter.ParameterType = 'string'
$parameter.ParameterSetName = @('Default','ByShadowId','BySetId')
$parameter.NoGap = $true
$parameter.Description = "List the shadow copies for volume name like 'C:'"
$newCommand.Parameters += $parameter

#### Add a new parameter to the command
$parameter = New-ParameterInfo -OriginalName '/Shadow=' -Name 'Shadow'
$parameter.ParameterType = 'string'
$parameter.ParameterSetName = @('ByShadowId')
$parameter.NoGap = $true
$parameter.Mandatory = $true
$parameter.Description = "List shadow copies matching the Id in GUID format: " +
    "'{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}'"
$newCommand.Parameters += $parameter

#### Add a new parameter to the command
$parameter = New-ParameterInfo -OriginalName '/Set=' -Name 'Set'
$parameter.ParameterType = 'string'
$parameter.ParameterSetName = @('BySetId')
$parameter.NoGap = $true
$parameter.Mandatory = $true
$parameter.Description = "List shadow copies matching the shadow set Id in GUID format: " +
    "'{XXXXXXXX-XXXX-XXXX-XXXX-XXXXXXXXXXXX}'"
$newCommand.Parameters += $parameter

### Add an Output Handler to the command
$handler = New-OutputHandler
$handler.ParameterSetName = 'Default'
$handler.HandlerType = 'Function'
$handler.Handler = 'ParseShadow'
$newCommand.OutputHandlers += $handler

## Add the command to the Commands collection of the configuration
$CrescendoCommands += $newCommand

# Export the configuration to a JSON file and create the module
Export-CrescendoCommand -command $CrescendoCommands -fileName .\vssadmin.json
Export-CrescendoModule -ConfigurationFile vssadmin.json -ModuleName .\vssadmin.psm1 -Force
```

## Advanced use cases

The Crescendo cmdlets are powerful tools that can be used in advanced scenarios to create
configurations and build modules. There are several advanced examples in the `Experimental\HelpParsers`
folder of the **Microsoft.PowerShell.Crescendo** module. These experimental examples show how you
can parse the help output of a command-line tool and use that information to create a Crescendo
configuration for a module that wraps the tool. The [README.md][README.md] file provides a detailed
explanation of the design of these help parsers.

You could use these help parsers in a CI/CD pipeline to build new versions of a module when the
command-line tool changes.

<!-- link references -->
[blog]: https://devblogs.microsoft.com/powershell-community/tag/crescendo/
[README.md]: https://github.com/PowerShell/Crescendo/blob/master/Microsoft.PowerShell.Crescendo/src/experimental/HelpParsers/README.md
