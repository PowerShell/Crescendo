---
external help file: Microsoft.PowerShell.Crescendo-help.xml
Module Name: Microsoft.PowerShell.Crescendo
ms.date: 11/09/2021
online version: https://docs.microsoft.com/powershell/module/microsoft.powershell.crescendo/new-parameterinfo?view=ps-modules&wt.mc_id=ps-gethelp
schema: 2.0.0
---

# New-ParameterInfo

## SYNOPSIS
Creates a PowerShell object representing a Crescendo Parameter definition.

## SYNTAX

```
New-ParameterInfo [-Name] <String> [-OriginalName] <String> [<CommonParameters>]
```

## DESCRIPTION

Creates a PowerShell object representing a Crescendo Parameter definition. You can assign values to
the properties of the object. The resulting object can be added to the **Parameters** property of
a command object or it can be converted to JSON to be inserted in the configuration file.

## EXAMPLES

### Example 1 - Create a new parameter object

```powershell
PS> $param = New-ParameterInfo -Name ComputerName -OriginalName '--targethost'
PS> $param

Name                            : ComputerName
OriginalName                    : --targethost
OriginalText                    :
Description                     :
DefaultValue                    :
DefaultMissingValue             :
ApplyToExecutable               : False
ParameterType                   : object
AdditionalParameterAttributes   :
Mandatory                       : False
ParameterSetName                :
Aliases                         :
Position                        : 2147483647
OriginalPosition                : 0
ValueFromPipeline               : False
ValueFromPipelineByPropertyName : False
ValueFromRemainingArguments     : False
NoGap                           : False
```

{{ Add example description here }}

## PARAMETERS

### -Name

The name of the parameter for the cmdlet being defined.

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

### -OriginalName

The original parameter used by the native executable.

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

[New-ExampleInfo](New-ExampleInfo.md)

[New-OutputHandler](New-OutputHandler.md)

[New-UsageInfo](New-UsageInfo.md)
