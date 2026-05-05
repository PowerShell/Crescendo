---
description: Describes the purpose of the Crescendo module.
Locale: en-US
ms.date: 12/13/2022
ms.topic: concept-article
online version: https://learn.microsoft.com/powershell/module/microsoft.powershell.crescendo/about/about_Microsoft.PowerShell.Crescendo?view=ps-modules.1&WT.mc_id=ps-gethelp
schema: 2.0.0
title: about_Microsoft.PowerShell.Crescendo
---
# about_Microsoft.PowerShell.Crescendo

## Short description

The PowerShell Crescendo module provides a novel way to create proxy functions
for native commands via `JSON` configuration files.

## Long description

PowerShell is capable of invoking native applications like any shell. However,
it would improve the experience if the native command could participate in the
PowerShell pipeline and take advantage of the parameter behaviors that are part
of PowerShell.

The PowerShell Crescendo module provides a way to take advantage of the
PowerShell pipeline by invoking the native executable, facilitating parameter
handling, and converting text output into objects.

## JSON configuration

The PowerShell Crescendo module provides a way to create a small bit of JSON
that's used to create a function that calls the native command.

An annotated schema is provided as part of the module that can improve the
authoring process.

## Parameter handling

The PowerShell Crescendo module allows you to interact with parameters of
native commands in the same way you do with cmdlets.

## Output handling

It's also possible to create a script block that can be used to convert the
output from the native command into objects. If the native command emits JSON
or XML it can be as simple as:

```json
    "OutputHandler": [
        "ParameterSetName": "Default"
        "Handler": "$args[0] | ConvertFrom-Json"
    ]
```

However, script blocks of arbitrary complexity may also be used.

## Examples

Several samples are provided as part of the module. You can find these in the
`Samples` directory of the module base directory.

The following JSON is a minimal example that wraps the unix `/bin/ls` command:

```json
{
    "$schema": "../src/Microsoft.PowerShell.Crescendo.Schema.json",
    "Verb": "Get",
    "Noun":"FileList",
    "OriginalName": "/bin/ls",
    "Parameters": [
        {
            "Name": "Path",
            "OriginalName": "",
            "OriginalPosition": 1,
            "Position": 0,
            "DefaultValue": "."
        },
        {
            "Name": "Detail",
            "OriginalName": "-l",
            "ParameterType": "switch"
        }
    ]
}
```

The name of the proxy function is `Get-FileList` and has two parameters:

- **Path** - Which is Position 0, and has a default value of "."
- **Detail** - Which is a switch parameter and adds `-l` to the native command
  parameters

A couple of things to note about the Path parameter

- The `OriginalPosition` is set to 1 and the `OriginalName` is set to an empty
  string. This is because some native commands have a parameter that's _not_
  named and must be the last parameter when executed. All parameters get
  ordered by the value of `OriginalPosition` (the default is 0). When the
  native command is called, those parameters (and their values) are put in that
  order.

In this example, there is no output handler defined, so the text output of the
command is returned to the pipeline.

The following is a more complicated example that wraps the linux `apt` command:

```json
{
    "$schema": "../src/Microsoft.PowerShell.Crescendo.Schema.json",
    "Verb": "Get",
    "Noun":"InstalledPackage",
    "OriginalName": "apt",
    "OriginalCommandElements": [
     "-q",
     "list",
     "--installed"
    ],
    "OutputHandlers": [
        {
            "ParameterSetName":"Default",
            "Handler": "$args[0]|select-object -skip 1|foreach-object{$n,$v,$p,$s = \"$_\" -split ' ';[pscustomobject]@{Name=$n -replace '/now';Version=$v;Architecture=$p;State = $s.Trim('[]') -split ','}}"
        }
    ]
}
```

In this case, the output handler converts the text output to a `pscustomobject`
to enable using other PowerShell cmdlets. When run, this provides an object
that encapsulates the `apt` output

```powershell
PS> Get-InstalledPackage | Where-Object { $_.name -match "libc"}

Name        Version            Architecture State
----        -------            ------------ -----
libc-bin    2.31-0ubuntu9.1    amd64        {installed, local}
libc6       2.31-0ubuntu9.1    amd64        {installed, local}
libcap-ng0  0.7.9-2.1build1    amd64        {installed, local}
libcom-err2 1.45.5-2ubuntu1    amd64        {installed, local}
libcrypt1   1:4.4.10-10ubuntu4 amd64        {installed, local}

PS> Get-InstalledPackage | Group-Object Architecture

Count Name  Group
----- ----  -----
   10 all   {@{Name=adduser; Version=3.118ubuntu2; Architecture=all; State=System.String[]}, @{Name=debconf; V…
   82 amd64 {@{Name=apt; Version=2.0.2ubuntu0.1; Architecture=amd64; State=System.String[]}, @{Name=base-files…
```

## See also

The PowerShell Crescendo module is still in the development process, so we
expect changes to be made.

The GitHub repository may be found at:
[https://github.com/PowerShell/Crescendo][03].

The following PowerShell Blog posts present the rational and approaches for
native command wrapping:

- [Native commands in PowerShell a new approach - Part 1][02]
- [Native commands in PowerShell a new approach - Part 2][01]

<!-- link references -->
[01]: https://devblogs.microsoft.com/powershell/native-commands-in-powershell-a-new-approach-part-2
[02]: https://devblogs.microsoft.com/powershell/native-commands-in-powershell-a-new-approach/
[03]: https://github.com/PowerShell/Crescendo
