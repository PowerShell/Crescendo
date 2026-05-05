---
description: How to create a Crescendo cmdlet.
ms.date: 08/23/2023
title: Create a Crescendo cmdlet
---
# Create a Crescendo cmdlet

Modern command-line tools provide commands for effective management of domain-specific technologies.
Administrative users can confidently execute these commands inside of PowerShell and get the
expected results. However, PowerShell users prefer the syntax, readability, and object-based output
that cmdlets provide, especially in automation.

As previously discussed, there are several reasons you may want to amplify a command-line tool:

- The string output is difficult to use in automation
- The command syntax is difficult to use or remember
- The tool lacks informative help documentation

In the [previous article][04], we discussed how to discover and choose the feature of the tool that
you want to amplify with Crescendo. For the examples in this article, we continue to use the
`azcmagent` command-line tool that was previously introduced.

## Creating the configuration for a Crescendo cmdlet

A Crescendo configuration describes a new cmdlet. The cmdlet definition includes:

- The location of the original command-line tool
- The subcommands and parameters passed to the command-line tool
- The `Verb-Noun` name of the new cmdlet
- The parameters used by the cmdlet

Crescendo takes the configuration file and generates proxy cmdlets for the original command-line
tool. The generated code is stored in a PowerShell script module, ready for deployment.

You can create your own configuration file, copy an existing file and modify it, or start a new
configuration using the `New-CrescendoCommand` cmdlet. Crescendo configuration files are written in
JSON.

- The **Verb** parameter specifies the verb for the new cmdlet. Use `Get-Verb` to get a list of
  approved verb names.
- The **Noun** parameter specifies the noun that the verb is acting on.
- The **OriginalName** parameter specifies the path to the original command-line tool.

```powershell
$parameters = @{
    Verb = 'Show'
    Noun = 'AzCmAgent'
    OriginalName = "c:/program files/AzureConnectedMachineAgent/azcmagent.exe"
}
New-CrescendoCommand @parameters | Format-List *
```

`New-CrescendoCommand` creates a Crescendo command object. The cmdlet does populate all the possible
property values.

```output
FunctionName            : Show-AzCmAgent
Verb                    : Show
Noun                    : AzCmAgent
OriginalName            : c:/program files/AzureConnectedMachineAgent/azcmagent.exe
OriginalCommandElements :
Platform                : {Windows, Linux, MacOS}
Elevation               :
Aliases                 :
DefaultParameterSetName :
SupportsShouldProcess   : False
ConfirmImpact           :
SupportsTransactions    : False
NoInvocation            : False
Description             :
Usage                   :
Parameters              : {}
Examples                : {}
OriginalText            :
HelpLinks               :
OutputHandlers          :
```

The following example shows how to create a new configuration file.

```powershell
$parameters = @{
    Verb = 'Show'
    Noun = 'AzCmAgent'
    OriginalName = "c:/program files/AzureConnectedMachineAgent/azcmagent.exe"
}
$CrescendoCommands += New-CrescendoCommand @parameters
Export-CrescendoCommand -command $CrescendoCommands -fileName .\AzCmAgent.json
```

Crescendo configuration file has a JSON schema and can contain one or more cmdlet definitions in an
array. In this example, `$NewConfiguration` is an object containing the link to the JSON schema and
an array to contain the cmdlet definitions. The output from `New-CrescendoCommand` is added to the
**Commands** array. The `$NewConfiguration` is converted to JSON and written to a file. The
`AzCmAgent.json` file contains the following code:

```json
{
  "$schema": "https://aka.ms/PowerShell/Crescendo/Schemas/2022-06",
  "Commands": [
    {
      "Verb": "Show",
      "Noun": "AzCmAgent",
      "OriginalName": "c:/program files/AzureConnectedMachineAgent/azcmagent.exe",
      "Platform": [
        "Windows",
        "Linux",
        "MacOS"
      ],
      "SupportsShouldProcess": false,
      "SupportsTransactions": false,
      "NoInvocation": false,
      "Parameters": [],
      "Examples": []
    }
  ]
}
```

It's important to have the schema link in the Crescendo configuration file. The schema provides
tools like [Visual Studio Code][02] with IntelliSense and tooltips during the authoring experience.

## Completing the Crescendo command configuration

In this example, we're creating a configuration for the `azcmagent show` command. The cmdlet
doesn't require any additional parameters. Since `azcmagent` is a modern tool that provides JSON
output, the example includes a simple output handler to convert the JSON output to objects.

The command definition includes the following properties:

- **Verb**: The name of the cmdlet verb
- **Noun**: The name of the cmdlet noun
- **Platform**: The platform that this Crescendo command run on (Windows, Linux, MacOS)
- **OriginalName**: The original native command name and location
- **OriginalCommandElements**: Some command-line tools have additional mandatory switches for a
  given scenario
- **Description**: Description for the cmdlet that's seen in Help
- **Aliases**: An alias, or short name, for the new cmdlet
- **OutputHandlers**: The output handler that captures the string output from the command-line tool
  and transforms it into PowerShell objects
- **HandlerType**: can be `Inline`, `Function`, or `Script`. This example uses `Inline`

The following example shows the full JSON definition of the new cmdlet after additional editing.

```json
{
  "$schema": "https://aka.ms/PowerShell/Crescendo/Schemas/2022-06",
  "Commands": [
    {
      "Verb": "Show",
      "Noun": "AzCmAgent",
      "OriginalName": "c:/program files/AzureConnectedMachineAgent/azcmagent.exe",
      "OriginalCommandElements": [
         "show",
         "--json"
      ],
      "Platform": [
        "Windows"
      ],
      "Description": "Gets machine metadata and Agent status. This is primarily useful for troubleshooting.",
      "Aliases": [
        "azinfo"
      ],
      "OutputHandlers": [
        {
            "ParameterSetName": "Default",
            "HandlerType": "Inline",
            "Handler": "$args[0] | ConvertFrom-Json"
        }
      ],
      "SupportsShouldProcess": false,
      "SupportsTransactions": false,
      "NoInvocation": false,
      "Parameters": [],
      "Examples": []
    }
  ]
}
```

## Defining another cmdlet that has parameters

In this example, we create a Crescendo configuration for the `azcmagent config get` command that
lists property information. A parameter named **Property** is mapped to the original parameter of
**Get**.

A parameter definition includes the following properties:

- **DefaultParameterSetName**: Defines the default parameter set if multiple parameter sets are
  implemented
- **Parameters**: Code block that contains the definition of the parameters for the command
- **Name**: This is the name of the PowerShell parameter for the generated cmdlet
- **OriginalName**: The name of the parameter
- **ParameterType**: Defines the data type of the parameter value
- **ParameterSetName**: Defines which parameter set this parameter belongs to
- **Mandatory**: Setting that determines if the parameter is required to have a value
- **Description**: Description for the parameter that's seen in Help

The following example shows the full JSON definition of the new cmdlet. You can put this to a
definition in a new JSON file or add it to the **Commands** array of the previous JSON file.

```json
{
    "Verb": "Get",
    "Noun": "AzCmAgentConfigProperty",
    "Platform": [
        "Windows"
    ],
    "OriginalCommandElements": [
        "config",
        "--json"
    ],
    "OriginalName": "c:/program files/AzureConnectedMachineAgent/azcmagent.exe",
    "Description": " Get a configuration property's value",
    "DefaultParameterSetName": "Default",
    "Parameters": [
        {
            "OriginalName": "get",
            "Name": "Property",
            "ParameterType": "string",
            "ParameterSetName": [
                "Default"
            ],
            "Mandatory": true,
            "Description": "Specify the name of the property to return"
        }
    ],
    "OutputHandlers": [
        {
            "ParameterSetName": "Default",
            "HandlerType": "Inline",
            "Handler": "$args[0] | ConvertFrom-Json"
        }
    ],
    "SupportsShouldProcess": false,
    "SupportsTransactions": false,
    "NoInvocation": false,
    "Examples": []
}
```

For a more detailed configuration example, see the blog post
[A closer look at the Crescendo configuration][03].

## Next steps

Now that you have defined your cmdlets, you are ready to generate your new module.

> [!div class="nextstepaction"]
> [Generate and test your module][01]

<!-- link references -->
[01]: generate-module.md
[02]: https://code.visualstudio.com
[03]: https://devblogs.microsoft.com/powershell-community/a-closer-look-at-the-crescendo-configuration/
[04]: research-tool.md
