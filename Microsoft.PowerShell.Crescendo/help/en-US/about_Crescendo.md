---
description: Describes arrays, which are data structures designed to store collections of items.
Locale: en-US
ms.date: 03/16/2021
online version: https://docs.microsoft.com/powershell/module/microsoft.powershell.crescendo/about/about_Microsoft.PowerShell.Crescendo?view=ps-modules.1&WT.mc_id=ps-gethelp
schema: 2.0.0
title: about_Microsoft.PowerShell.Crescendo
---
# Microsoft.PowerShell.Crescendo

## about_Microsoft.PowerShell.Crescendo

## SHORT DESCRIPTION

The PowerShell Crescendo module provides a novel way to create proxy functions
for native commands via `JSON` configuration files.

## LONG DESCRIPTION

PowerShell is capable of invoking native applications like any shell. However,
it would improve the experience if the native command could participate in the
PowerShell pipeline and take advantage of the parameter behaviors that are part
of PowerShell.

The PowerShell Crescendo module provides a way to more easily take advantage of
the PowerShell pipeline by invoking the native executable, facilitating
parameter handling, and converting text output into objects.

## JSON Configuration

The PowerShell Crescendo module provides a way to create a small bit of JSON
that is used to create a function that calls the native command.

An annotated schema is provided as part of the module that can improve the
authoring process.

## Parameter handling

The PowerShell Crescendo module allows you to interact with parameters of native
commands in the same way you do with cmdlets.

## Output Handling

It is also possible to provide a script block that can be used to convert the
output from the native command into objects. If the native command emits `json`
or `xml` it is as simple as:

```json
    "OutputHandler": [
        "ParameterSetName": "Default"
        "Handler": "$args[0] | ConvertFrom-Json"
    ]
```

However, script blocks of arbitrary complexity may also be used.

## EXAMPLES

A number of samples are provided as part of the module, you can see these in
the Samples directory in the module base directory.

A very simple example is as follows to wrap the unix `/bin/ls` command:

```json
{
    "$schema": "https://aka.ms/PowerShell/Crescendo/Schemas/2021-11",
    "Verb": "Get",
    "Noun":"FileList",
    "OriginalName": "/bin/ls",
    "Parameters": [
        {"Name": "Path","OriginalName": "", "OriginalPosition": 1, "Position": 0, "DefaultValue": "." },
        {"Name": "Detail","OriginalName": "-l","ParameterType": "switch"}
    ]
}
```

The name of the proxy function is `Get-FileList` and has two parameters:

- Path
  - Which is Position 0, and has a default value of "."
- Detail
  - Which is a switch parameter and adds `-l` to the native command parameters

A couple of things to note about the Path parameter

- The `OriginalPosition` is set to 1 and the `OriginalName` is set to an empty
  string. This is because some native commands have a parameter which is _not_
  named and must be the last parameter when executed. All parameters will be
  ordered by the value of `OriginalPosition` (the default is 0) and when the
  native command is called, those parameters (and their values) will be put in
  that order.

In this example, there is no output handler defined, so the text output of the
command will be returned to the pipeline.

A more complicated example which wraps the linux `apt` command follows:

```json
{
    "$schema": "https://aka.ms/PowerShell/Crescendo/Schemas/2021-11",
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
which encapsulates the `apt` output

```powershell
PS> get-installedpackage | ?{ $_.name -match "libc"}

Name        Version            Architecture State
----        -------            ------------ -----
libc-bin    2.31-0ubuntu9.1    amd64        {installed, local}
libc6       2.31-0ubuntu9.1    amd64        {installed, local}
libcap-ng0  0.7.9-2.1build1    amd64        {installed, local}
libcom-err2 1.45.5-2ubuntu1    amd64        {installed, local}
libcrypt1   1:4.4.10-10ubuntu4 amd64        {installed, local}

PS> get-installedpackage | Group-Object Architecture

Count Name  Group
----- ----  -----
   10 all   {@{Name=adduser; Version=3.118ubuntu2; Architecture=all; State=System.String[]}, @{Name=debconf; V…
   82 amd64 {@{Name=apt; Version=2.0.2ubuntu0.1; Architecture=amd64; State=System.String[]}, @{Name=base-files…
```

## TROUBLESHOOTING NOTE

The PowerShell Crescendo module is still very early in the development process,
so we expect changes to be made.

One issue is that the output handler is currently a string, so constructing the
script block may be complex; semi-colons will be required to separate
statements. This may be addressed in a later version.

## SEE ALSO

The GitHub repository may be found at:
[https://github.com/PowerShell/Crescendo](https://github.com/PowerShell/Crescendo).

PowerShell Blog posts that present the rational and approaches for native
command wrapping can be found here:

- [Part 1](https://devblogs.microsoft.com/powershell/native-commands-in-powershell-a-new-approach/)
- [Part 2](https://devblogs.microsoft.com/powershell/native-commands-in-powershell-a-new-approach-part-2))

## KEYWORDS

Native Command
