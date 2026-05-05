---
external help file: Microsoft.PowerShell.Crescendo-help.xml
Module Name: Microsoft.PowerShell.Crescendo
ms.date: 12/13/2022
online version: https://learn.microsoft.com/powershell/module/microsoft.powershell.crescendo/test-iscrescendocommand?view=ps-modules&wt.mc_id=ps-gethelp
schema: 2.0.0
---

# Test-IsCrescendoCommand

## SYNOPSIS
Tests whether a cmdlet was created by Crescendo.

## SYNTAX

```
Test-IsCrescendoCommand [-Command] <Object[]> [<CommonParameters>]
```

## DESCRIPTION
Tests a cmdlet to see if it was created by Crescendo.

## EXAMPLES

### Example 1 - Test various cmdlet to see if they were created by Crescendo

```powershell
Test-IsCrescendoCommand Get-Command
```

```Output
Test-IsCrescendoCommand: 'Get-Command' is not a function
```

```powershell
Test-IsCrescendoCommand Expand-Archive
```

```Output
   Module: Microsoft.PowerShell.Archive

Name           IsCrescendoCommand RequiresElevation
----           ------------------ -----------------
Expand-Archive False              False
```

```powershell
Test-IsCrescendoCommand Get-VssProvider
```

```Output
   Module: VssAdmin

Name            IsCrescendoCommand RequiresElevation
----            ------------------ -----------------
Get-VssProvider True               False
```

## PARAMETERS

### -Command

The name of the cmdlet to test.

```yaml
Type: Object[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose,
-WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.Object[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
