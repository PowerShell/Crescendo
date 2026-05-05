---
external help file: Microsoft.PowerShell.Crescendo-help.xml
Module Name: Microsoft.PowerShell.Crescendo
ms.date: 12/13/2022
online version: https://learn.microsoft.com/powershell/module/microsoft.powershell.crescendo/export-crescendomodule?view=ps-modules&wt.mc_id=ps-gethelp
schema: 2.0.0
---

# Export-CrescendoModule

## SYNOPSIS
Creates a module from PowerShell Crescendo JSON configuration files

## SYNTAX

```
Export-CrescendoModule [-ConfigurationFile] <String[]> [-ModuleName] <String> [-Force]
 [-NoClobberManifest] [-PassThru] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

This cmdlet exports an object that can be converted into a function that acts as a proxy for a
platform specific command. The resultant module file should be executable down to version 5.1 of
PowerShell.

The cmdlet creates both the module `.psm1` and the module manifest `.psd1` files. This can create
problems when you have customized the module manifest beyond the scope of Crescendo. Use the
**NoClobberManifest** parameter to prevent overwriting the manifest.

## EXAMPLES

### EXAMPLE 1

```powershell
Export-CrescendoModule -ModuleName netsh -ConfigurationFile netsh*.json
Import-Module ./netsh.psm1
```

### EXAMPLE 2

```powershell
Export-CrescendoModule netsh netsh*.json -force
```

## PARAMETERS

### -ConfigurationFile

This is a list of JSON files that represent the proxies for the module.

```yaml
Type: System.String[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: True
```

### -Force

By default, if `Export-CrescendoModule` doesn't overwrite an existing module. Use the **Force**
parameter to overwrite the existing file, or remove it before running `Export-CrescendoModule`.

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
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoClobberManifest

Prevents overwriting the module manifest.

You must manually update the manifest with any new cmdlets and settings.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru

Emit an object with the path to the .psm1 and the arguments to New-ModuleManifest.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
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

Shows what would happen if the cmdlet runs. The cmdlet isn't run.

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

### System.String[]

## OUTPUTS

### System.Object

## NOTES

Internally, this function calls the `Import-CommandConfiguration` cmdlet that returns a command
object. All files provided in the **ConfigurationFile** parameter are then used to create each
individual function. Finally, all proxies are used to create an `Export-ModuleMember` command
invocation, so when the resultant module is imported, the module has all the command proxies
available.

`Export-CrescendoModule` adds the **CrescendoBuilt** tag to the module manifest. You can use this
tag to find modules in the PowerShell Gallery that were created using Crescendo. For more
information, see:

- [Gallery Search Syntax](/powershell/scripting/gallery/how-to/finding-packages/search-syntax)
- [Find-Module](/powershell/module/powershellget/find-module)

## RELATED LINKS

[Import-CommandConfiguration](Import-CommandConfiguration.md)
