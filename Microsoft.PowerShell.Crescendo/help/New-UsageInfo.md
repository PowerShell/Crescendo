---
external help file: Microsoft.PowerShell.Crescendo-help.xml
Module Name: Microsoft.PowerShell.Crescendo
ms.date: 11/09/2021
online version: https://docs.microsoft.com/powershell/module/microsoft.powershell.crescendo/new-usageinfo?view=ps-modules&wt.mc_id=ps-gethelp
schema: 2.0.0
---

# New-UsageInfo

## SYNOPSIS
Creates a PowerShell object representing a Crescendo Usage definition.

## SYNTAX

```
New-UsageInfo [-usage] <String> [<CommonParameters>]
```

## DESCRIPTION

Creates a PowerShell object representing a Crescendo Usage definition. You can assign values to the
properties of the object. The resulting object can be added to the **Usage** property of a command
object or it can be converted to JSON to be inserted in the configuration file. The **Synopsis** of
the object is inserted in the module as comment-based help under the `.SYNOPSIS` keyword.

## EXAMPLES

### Example 1 - Create a Usage object and convert it to JSON

```powershell
PS> $usage = New-UsageInfo -usage 'This is a description for how to use the cmdlet.'
PS> $usage | ConvertTo-Json

{
  "Synopsis": "This is a description for how to use the cmdlet.",
  "SupportsFlags": false,
  "HasOptions": false,
  "OriginalText": null
}
```

## PARAMETERS

### -usage

The text describing the purpose of the cmdlet.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[New-CrescendoCommand](New-CrescendoCommand.md)

[New-ExampleInfo](New-ExampleInfo.md)

[New-OutputHandler](New-OutputHandler.md)

[New-ParameterInfo](New-ParameterInfo.md)
