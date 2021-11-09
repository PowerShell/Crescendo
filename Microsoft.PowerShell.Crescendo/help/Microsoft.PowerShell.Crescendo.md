---
Module Name: Microsoft.PowerShell.Crescendo
Module Guid: 2dd09744-1ced-4636-a8ce-09a0bf0e566a
ms.date: 11/09/2021
Download Help Link: https://aka.ms/ps-modules-help
Help Version: 0.1.0.0
Locale: en-US
---

# Microsoft.PowerShell.Crescendo Module

## Description

The PowerShell Crescendo module provides a way to more easily take advantage of the PowerShell
pipeline by invoking the native executable, facilitating parameter handling, and converting text
output into objects.

> [!NOTE]
> Support for the module is limited. Please file issues in the source repository using the **This
> product** button in the Feedback section at the bottom of the page. The module is still very early
> in the development process, so we expect changes to be made.

## Microsoft.PowerShell.Crescendo Cmdlets

### [Export-CrescendoModule](Export-CrescendoModule.md)
Creates a module from PowerShell Crescendo JSON configuration files

### [Export-Schema](Export-Schema.md)
Exports the JSON schema for command configuration as a PowerShell object.

### [Import-CommandConfiguration](Import-CommandConfiguration.md)
Import a PowerShell Crescendo json file.

### [New-CrescendoCommand](New-CrescendoCommand.md)
Creates a PowerShell command object.

### [New-ExampleInfo](New-ExampleInfo.md)
Creates a PowerShell object representing an example used in a Crescendo command object.

### [New-OutputHandler](New-OutputHandler.md)
Creates a PowerShell object representing a Crescendo output handler.

### [New-ParameterInfo](New-ParameterInfo.md)
Creates a PowerShell object representing a Crescendo Parameter definition.

### [New-UsageInfo](New-UsageInfo.md)
Creates a PowerShell object representing a Crescendo Usage definition.

### [Test-IsCrescendoCommand](Test-IsCrescendoCommand.md)
Tests a cmdlet to see if it was created by Crescendo.
