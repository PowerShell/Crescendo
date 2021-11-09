---
external help file: Microsoft.PowerShell.Crescendo-help.xml
Module Name: Microsoft.PowerShell.Crescendo
ms.date: 11/09/2021
online version: https://docs.microsoft.com/powershell/module/microsoft.powershell.crescendo/new-exampleinfo?view=ps-modules&wt.mc_id=ps-gethelp
schema: 2.0.0
---

# New-ExampleInfo

## SYNOPSIS
Creates a PowerShell object representing an example used in a Crescendo command object.

## SYNTAX

```
New-ExampleInfo [-command] <String> [-originalCommand] <String> [-description] <String> [<CommonParameters>]
```

## DESCRIPTION

Creates a PowerShell object representing an example used in a Crescendo command object. The
resulting object can be converted to JSON to be inserted into a configuration file or added to a
command object coversion to JSON later.

## EXAMPLES

### Example 1

```powershell
PS> New-ExampleInfo -command Get-Something -originalCommand native.exe -description 'this is some text' |
    ConvertTo-Json

{
  "Command": "Get-Something",
  "OriginalCommand": "native.exe",
  "Description": "this is some text"
}
```

## PARAMETERS

### -command

The command line for the example being described.

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

### -description

The description of the example.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -originalCommand

The original native command that is run for this cmdlet example.

```yaml
Type: System.String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
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

[New-OutputHandler](New-OutputHandler.md)

[New-ParameterInfo](New-ParameterInfo.md)

[New-UsageInfo](New-UsageInfo.md)
