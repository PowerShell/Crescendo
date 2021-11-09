---
external help file: Microsoft.PowerShell.Crescendo-help.xml
Module Name: Microsoft.PowerShell.Crescendo
ms.date: 03/16/2021
online version: https://docs.microsoft.com/powershell/module/microsoft.powershell.crescendo/import-commandconfiguration?view=ps-modules&wt.mc_id=ps-gethelp
schema: 2.0.0
---

# Import-CommandConfiguration

## SYNOPSIS
Import a PowerShell Crescendo json file.

## SYNTAX

```
Import-CommandConfiguration [-file] <String> [<CommonParameters>]
```

## DESCRIPTION

This cmdlet exports an object that can be converted into a function that acts as a proxy for the
platform specific command. The resultant object may then be used to call a native command that can
participate in the PowerShell pipeline. The `ToString` method of the output object returns a
string that can be used to create a function that calls the native command. Microsoft Windows,
Linux, and macOS can run the generated function, if the native command is on all of the platform.

## EXAMPLES

### EXAMPLE 1

```powershell
Import-CommandConfiguration ifconfig.crescendo.json
```

```output
Verb                    : Invoke
Noun                    : ifconfig
OriginalName            : ifconfig
OriginalCommandElements :
Aliases                 :
DefaultParameterSetName :
SupportsShouldProcess   : False
SupportsTransactions    : False
NoInvocation            : False
Description             : This is a description of the generated function
Usage                   : .SYNOPSIS
                          Run invoke-ifconfig
Parameters              : {[Parameter()]
                          [string]$Interface = ""}
Examples                :
OriginalText            :
HelpLinks               :
OutputHandlers          :
```

## PARAMETERS

### -file

The json file which represents the command to be wrapped.

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

### A Command object

## NOTES

The object returned by `Import-CommandConfiguration` is converted through the `ToString` method.
Generally, you should use the `Export-CrescendoModule`, which creates a PowerShell `.psm1` file.

## RELATED LINKS

[Export-CrescendoModule](Export-CrescendoModule.md)
