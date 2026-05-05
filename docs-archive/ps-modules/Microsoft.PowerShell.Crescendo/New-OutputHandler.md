---
external help file: Microsoft.PowerShell.Crescendo-help.xml
Module Name: Microsoft.PowerShell.Crescendo
ms.date: 12/13/2022
online version: https://learn.microsoft.com/powershell/module/microsoft.powershell.crescendo/new-outputhandler?view=ps-modules&wt.mc_id=ps-gethelp
schema: 2.0.0
---

# New-OutputHandler

## SYNOPSIS
Creates a PowerShell object representing a Crescendo output handler.

## SYNTAX

```
New-OutputHandler
```

## DESCRIPTION

Creates a PowerShell object representing a Crescendo output handler. You can assign values to the
properties of the object. The resulting object can be added to the **OutputHandlers** property of a
command object or it can be converted to JSON to be inserted in the configuration file.

## EXAMPLES

### Example 1 - Create a new output handler object and convert it to JSON

```powershell
$outhandler = New-OutputHandler
$outhandler.ParameterSetName = 'Default'
$outhandler.Handler = 'ParseShadowStorage'
$outhandler.HandlerType = 'Function'
$outhandler | ConvertTo-Json
```

```Output
{
  "ParameterSetName": "Default",
  "Handler": "ParseShadowStorage",
  "HandlerType": "Function",
  "StreamOutput": false
}
```

## PARAMETERS

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[New-CrescendoCommand](New-CrescendoCommand.md)

[New-ExampleInfo](New-ExampleInfo.md)

[New-ParameterInfo](New-ParameterInfo.md)

[New-UsageInfo](New-UsageInfo.md)
