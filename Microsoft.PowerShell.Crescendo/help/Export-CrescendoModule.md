---
external help file: Microsoft.PowerShell.Crescendo-help.xml
Module Name: Microsoft.PowerShell.Crescendo
ms.date: 11/09/2021
online version: https://docs.microsoft.com/powershell/module/microsoft.powershell.crescendo/export-crescendomodule?view=ps-modules&wt.mc_id=ps-gethelp
schema: 2.0.0
---

# Export-CrescendoModule

## SYNOPSIS
Creates a module from PowerShell Crescendo JSON configuration files

## SYNTAX

```
Export-CrescendoModule [-ConfigurationFile] <String[]> [-ModuleName] <String> [-Force] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet exports an object that can be converted into a function that acts as a proxy for a
platform specific command. The resultant module file should be executable down to version 5.1 of
PowerShell.

## EXAMPLES

### EXAMPLE 1

```
Export-CrescendoModule -ModuleName netsh -ConfigurationFile netsh*.json
Import-Module ./netsh.psm1
```

### EXAMPLE 2

```
Export-CrescendoModule netsh netsh*.json -force
```

## PARAMETERS

### -ConfigurationFile

This is a list of JSON files which represent the proxies for the module

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -Force

By default, if `Export-CrescendoModule` finds an already created module, it will not overwrite the
existing file. Use the **Force** parameter to overwrite the existing file, or remove it prior to
running `Export-CrescendoModule`.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ModuleName

The name of the module file you wish to create. You can omit the trailing `.psm1`.

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

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs. The cmdlet is not run.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
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

## OUTPUTS

### None

## NOTES

Internally, this function calls the `Import-CommandConfiguration` cmdlet that returns a command
object. All files provided in the **ConfigurationFile** parameter are then used to create each
individual function. Finally, all proxies are used to create an `Export-ModuleMember` command
invocation, so when the resultant module is imported, the module has all the command proxies
available.

## RELATED LINKS

[Import-CommandConfiguration](Import-CommandConfiguration.md)
