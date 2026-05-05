---
external help file: Microsoft.PowerShell.Crescendo-help.xml
Module Name: Microsoft.PowerShell.Crescendo
ms.date: 12/13/2022
schema: 2.0.0
---

# Export-CrescendoCommand

## SYNOPSIS
Creates JSON configuration files for Crescendo **Command** objects.

## SYNTAX

### MultipleFile (Default)

```
Export-CrescendoCommand [-command] <Command[]> [-targetDirectory <String>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### SingleFile

```
Export-CrescendoCommand [-command] <Command[]> -fileName <String> [-Force] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

This cmdlet creates JSON configuration files for Crescendo **Command** objects. It can create one
JSON file per **Command** object or create one JSON file containing all objects passed to it.

Crescendo **Command** objects can be created using `New-CrescendoCommand` or imported from an
existing configuration using `Import-CommandConfiguration`.

This cmdlet was added in **Microsoft.PowerShell.Crescendo** v1.1.

## EXAMPLES

### Example 1 - Create separate JSON files per command

In this example, **Command** objects are imported from an existing JSON configuration file.
`Export-CrescendoCommand` is used to create separate JSON files for each cmdlet.

```powershell
$config = Import-CommandConfiguration C:\projects\vssadmin\vssadmin.crescendo.config.json
Export-CrescendoCommand -command $config -targetDirectory .
Get-ChildItem
```

```Output
    Directory: D:\temp\Crescendo

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---          12/13/2022  3:24 PM            869 Get-VssProvider.crescendo.json
-a---          12/13/2022  3:24 PM           3483 Get-VssShadow.crescendo.json
-a---          12/13/2022  3:24 PM           2474 Get-VssShadowStorage.crescendo.json
-a---          12/13/2022  3:24 PM            863 Get-VssVolume.crescendo.json
-a---          12/13/2022  3:24 PM            860 Get-VssWriter.crescendo.json
-a---          12/13/2022  3:24 PM           4973 Resize-VssShadowStorage.crescendo.json
```

### Example 2 - Create a new JSON configuration file for existing commands

In this example, **Command** objects are imported from an existing JSON configuration file.
`Export-CrescendoCommand` is used to create a new JSON configuration file containing all the
commands.

```powershell
$config = Import-CommandConfiguration C:\projects\vssadmin\vssadmin.crescendo.config.json
Export-CrescendoCommand -command $config -fileName VssAdmin.crescendo.json
Get-ChildItem
```

```Output
    Directory: D:\temp\Crescendo

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
-a---          12/13/2022  3:10 PM          15313 VssAdmin.crescendo.json
```

The new JSON file contains new properties for the current version of Crescendo and references the
new schema URL. This is a convenient way to convert an old JSON configuration file to the new
format.

## PARAMETERS

### -command

One or more Crescendo **Command** objects to be exported.

```yaml
Type: Command[]
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -fileName

The name of the JSON file to create.

```yaml
Type: System.String
Parameter Sets: SingleFile
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Force

Overwrite existing files.

```yaml
Type: System.Management.Automation.SwitchParameter
Parameter Sets: SingleFile
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -targetDirectory

The output location for the JSON files created for each **Command** object.

```yaml
Type: System.String
Parameter Sets: MultipleFile
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

### Command[]

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS

[Export-CrescendoModule](Export-CrescendoModule.md)

[Import-CommandConfiguration](Import-CommandConfiguration.md)
