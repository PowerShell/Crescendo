---
description: New features and changes released in Crescendo 1.1
ms.date: 08/23/2023
title: What's new in Crescendo 1.1
---
# What's new in Crescendo 1.1

This preview includes a new cmdlet, a new schema, support for argument value transformation, the
ability to bypass the output handler, and improved error handling.

## New schema version

The Crescendo schema now includes support for three new members to the **Parameter** class:
`ExcludeAsArgument`, `ArgumentTransform` and `ArgumentTransformType`. With tools like Visual Studio
Code, the schema provides IntelliSense and tooltips during the authoring experience.

URL location of the always-available Crescendo schema:

```json
{
   "$schema": "https://aka.ms/PowerShell/Crescendo/Schemas/2022-06",
   "Commands": []
}
```

## New `Export-CrescendoCommand` cmdlet

This cmdlet creates JSON configuration files for Crescendo **Command** objects. It can create one
JSON file per **Command** object or create one JSON file containing all objects passed to it.

Crescendo **Command** objects can be created using `New-CrescendoCommand` or imported from an
existing configuration using `Import-CommandConfiguration`.

For more information, see [Export-CrescendoCommand][02].

## Prevent overwriting of the module manifest

Crescendo creates both the module `.psm1` and the module manifest `.psd1` when
`Export-CrescendoModule` is executed. This can create problems when you have customized the module
manifest beyond the scope of Crescendo. The `Export-CrescendoModule` cmdlet now provides a
**NoClobberManifest** switch parameter to prevent the manifest from being overwritten.

```powershell
Export-CrescendoModule -ConfigurationFile .\myconfig.json -ModuleName .\Mymodule -NoClobberManifest
```

> [!NOTE]
> The **NoClobberManifest** parameter prevents Crescendo from updating the module manifest. You are
> responsible for manually updating the manifest with any new cmdlets and settings.

## Bypass output handling entirely

Some native commands create different output depending on whether the output is sent to the screen
or the pipeline. [Pastel][03] is an example of a command that changes its output from a graphical
screen representation to a single string value when used in a pipeline. Crescendo output handling is
pipeline based and can cause these applications to return unwanted results. Crescendo now supports
the ability to bypass the output handler entirely.

To bypass all output handling by Crescendo:

```json
"OutputHandlers": [
    {
        "ParameterSetName": "Default",
        "HandlerType": "ByPass"
    }
]
```

## Handling error output

Previously, native command errors were streamed directly to the user. They weren't captured by
Crescendo. This prevented you from creating enhanced error handling. Crescendo now captures the
generated command error output (stderr). If you don't define an output handler, Crescendo uses the
default handler. The default output handler ensures that errors respect the `-ErrorVariable` and
`-ErrorAction` parameters and adds errors to `$Error`.

Crescendo v1.1 adds two internal functions to manage errors.

- `Push-CrescendoNativeError` adds an error to an error queue. This function is automatically
  called by the output handler. You don't have to call it directly.
- `Pop-CrescendoNativeError` removes an error from the error queue. Use this function to inspect
  errors in the output handler.

Adding an output handler that includes `Pop-CrescendoNativeError` allows you to inspect errors in
the output handler so you can handle them or pass them through to the caller.

The following output handler definition uses `Pop-CrescendoNativeError` to return errors to the
user.

```json
"OutputHandlers": [
    {
        "ParameterSetName": "Default",
        "StreamOutput": true,
        "HandlerType": "Inline",
        "Handler": "PROCESS { $_ } END { Pop-CrescendoNativeError -EmitAsError }"
    }
]
```

## Argument value transformation

You may find situations where the input values handed to a Crescendo wrapped command should be
translated to a different value for the underlying native command. Crescendo now supports argument
transformation to support these scenarios. We updated the schema to add two new members to the
**Parameter** class, `ArgumentTransform` and `ArgumentTransformType`. These members work like the
`Handler` and `HandlerType` members. The value `ArgumentTransformType` can be `Inline`, `Function`,
or `Script`. The default value for `ArgumentTransformType` is `Inline`.

- If the `ArgumentTransformType` is `Inline`, the value of `ArgumentTransform` must be a string
  containing a scriptblock.
- If the `ArgumentTransformType` is `Function`, the value of `ArgumentTransform` must be the name
  of a function that is loaded in the current session.
- If the `ArgumentTransformType` is `Script`, the value of `ArgumentTransform` must be the path to a
  script file.

Crescendo passes the parameter's argument values to the argument transformation code. The code must
return the transformed values.

Example: Multiplication of a value.

```json
"Parameters": [
    {
        "Name": "mult2",
        "OriginalName": "--p3",
        "ParameterType": "int",
        "OriginalPosition": 2,
        "ArgumentTransform": "param([int]$v) $v * 2",
        "ArgumentTransformType": "Inline"
    }
]
```

Example: Accepting an ordered hashtable.

```json
"Parameters": [
    {
        "Name": "hasht2",
        "OriginalName": "--p1ordered",
        "ParameterType": "System.Collections.Specialized.OrderedDictionary",
        "OriginalPosition": 0,
        "ArgumentTransform": "param([System.Collections.Specialized.OrderedDictionary]$v) $v.Keys.ForEach({''{0}={1}'' -f $_,$v[$_]}) -join '',''",
        "ArgumentTransformType": "Inline"
    }
]
```

Example: Argument transformation with join.

```json
"Parameters": [
    {
        "Name": "join",
        "OriginalName": "--p2",
        "ParameterType": "string[]",
        "OriginalPosition": 1,
        "ArgumentTransform": "param([string[]]$v) $v -join '',''",
        "ArgumentTransformType": "Inline"
    }
]
```

Example: Calling a function based transformation.

```json
"Parameters": [
    {
        "Name" : "Param1",
        "ArgumentTransform": "myfunction",
        "ArgumentTransformType" : "function"
    }
]
```

## Creating cmdlet parameters that are not used by the native command

Crescendo is designed to pass parameters defined in the configuration as arguments to the native
application. There are times when you may want to use a parameter value in the output handler but
not the native application. To enable this, a new boolean parameter property `ExcludeAsArgument` set
to true prevents the argument from being sent to the native application. The default is `false`.

```json
"Parameters": [
        {
            "Name": "Filter",
            "ParameterType": "string",
            "ExcludeAsArgument": true,
            "Mandatory": false,
            "Description": "Variable not sent to native app"
        }
    ],
```

For this example, the string argument passed to the **Filter** parameter is stored in the variable
`$Filter`. This variable is available for use in your output handler. The output handler could use
the value of the `$Filter` variable to filter the output of the native command, rather than
returning all output.

## Installing Crescendo

For information about installing Crescendo, see [Installing Crescendo][01].

<!-- link references -->
[01]: ../get-started/install-crescendo.md
[02]: /powershell/module/microsoft.powershell.crescendo/export-crescendocommand
[03]: https://github.com/sharkdp/pastel
