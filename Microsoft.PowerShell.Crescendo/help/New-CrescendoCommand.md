---
external help file: Microsoft.PowerShell.Crescendo-help.xml
Module Name: Microsoft.PowerShell.Crescendo
ms.date: 11/09/2021
online version: https://docs.microsoft.com/powershell/module/microsoft.powershell.crescendo/new-crescendocommand?view=ps-modules&wt.mc_id=ps-gethelp
schema: 2.0.0
---

# New-CrescendoCommand

## SYNOPSIS
Creates a PowerShell command object.

## SYNTAX

```
New-CrescendoCommand [-Verb] <String> [-Noun] <String> [[-OriginalName] <String>]
 [<CommonParameters>]
```

## DESCRIPTION

Creates a PowerShell command object. You can use this object to set the properties of the command
you are defining. The resulting object can be converted to JSON to be added to a configuration file.

## EXAMPLES

### Example 1 - Create a new command and convert it to JSON

```powershell
PS> New-CrescendoCommand -Verb Get -Noun Something -OriginalName "native.exe" | ConvertTo-Json
{
  "Verb": "Get",
  "Noun": "Something",
  "OriginalName": "native.exe",
  "OriginalCommandElements": null,
  "Platform": [
    "Windows",
    "Linux",
    "MacOS"
  ],
  "Elevation": null,
  "Aliases": null,
  "DefaultParameterSetName": null,
  "SupportsShouldProcess": false,
  "ConfirmImpact": null,
  "SupportsTransactions": false,
  "NoInvocation": false,
  "Description": null,
  "Usage": null,
  "Parameters": [],
  "Examples": [],
  "OriginalText": null,
  "HelpLinks": null,
  "OutputHandlers": null,
  "FunctionName": "Get-Something"
}
```

## PARAMETERS

### -Noun

The noun of the cmdlet you are defining.

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

### -OriginalName

The name of the native command executable to run.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Verb

The verb of the cmdlet you are defining.

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

[New-ExampleInfo](New-ExampleInfo.md)

[New-OutputHandler](New-OutputHandler.md)

[New-ParameterInfo](New-ParameterInfo.md)

[New-UsageInfo](New-UsageInfo.md)
