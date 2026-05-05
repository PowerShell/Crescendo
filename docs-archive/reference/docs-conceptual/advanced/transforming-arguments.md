---
description: This article describes how to transform arguments from the input format to the format needed by the native command.
ms.date: 06/28/2023
title: Transforming arguments in Crescendo
---
# Transforming arguments in Crescendo

There are many scenarios where the input values handed to a Crescendo wrapped command must be
translated to a different format for the underlying native command. Crescendo 1.1 added two new
members to the **Parameter** class, `ArgumentTransform` and `ArgumentTransformType` to support these
scenarios. These members are similar to the `Handler` and `HandlerType` members.

The value of `ArgumentTransformType` specifies how the value of `ArgumentTransform` is interpreted.
It must be one of the following values:

- `Inline` - The value of `ArgumentTransform` is a string to be evaluated as a script block. This is
  the default value when no value is specified.
- `Function` - The value of `ArgumentTransform` is the name of a function loaded in the current
  session.
- `Script` - The value of `ArgumentTransform` is the name of a script file found on disk.

In this example, the native command expects a comma-separated list of values for the parameter
`--p2`. The cmdlet parameter, **ValueList**, is an array of strings. Crescendo passes `$ValueList`
to the scriptblock in `ArgumentTransform` as a string array. The scriptblock joins the values in the
array with a comma and returns the result.

```json
"Parameters": [
    {
        "Name": "ValueList",
        "OriginalName": "--p2",
        "ParameterType": "string[]",
        "OriginalPosition": 1,
        "ArgumentTransform": "param([string[]]$v) $v -join ','"
    }
]
```

## Example - Add environment variables to a Docker image

The following Crescendo configuration defines the `Start-DockerRun` cmdlet that wraps the
`docker run` command. The `Environment` parameter is a hashtable containing key-value pairs that
need to be transformed into arguments for the `--env` parameter of the `docker run` command. When
you define multiple environment variables, the `docker run` commands expects an instance of
`--env key=value` for each variable. This isn't possible without using argument transformation.

```json
{
    "$schema": "https://aka.ms/PowerShell/Crescendo/Schemas/2022-06",
    "Commands": [
        {
            "Verb": "Start",
            "Noun": "DockerRun",
            "OriginalName": "docker",
            "OriginalCommandElements": [
                "run",
                "--rm",
                "-it"
            ],
            "Parameters": [
                {
                    "Name": "Environment",
                    "OriginalName": "",
                    "ParameterType": "Hashtable",
                    "OriginalPosition": 0,
                    "ArgumentTransform": "param([Hashtable]$v) $v.Keys|Foreach-Object {''--env''; ''{0}={1}'' -f $_, $v[$_]}"
                },
                {
                    "Name": "Image",
                    "OriginalName": "",
                    "ParameterType": "string",
                    "DefaultValue": "ubuntu:latest",
                    "OriginalPosition": 10
                }
            ],
            "OutputHandlers": [
                {
                    "ParameterSetName": "Default",
                    "HandlerType": "ByPass"
                }
            ]
        }
    ]
}
```

The argument transformer outputs `--env key=value` for every key-value pair in the hashtable.

## Example - Convert a **PSCredential** object to a username and password

In this example the Crescendo configuration defines the `Connect-WindowsShare` cmdlet that wraps the
`net use` command. The `Credential` parameter is a **PSCredential** object that must be converted to
a username and password for the `net use` command.

```json
{
    "$schema": "https://aka.ms/PowerShell/Crescendo/Schemas/2022-06",
    "Commands": [
        {
            "Verb": "Connect",
            "Noun": "WindowsShare",
            "OriginalName": "NET.exe",
            "Platform": [
                "Windows"
            ],
            "OriginalCommandElements": [ "USE" ],
            "Parameters": [
                {
                    "Name": "DriveName",
                    "OriginalName": "",
                    "DefaultValue": "*",
                    "ParameterType": "string",
                    "OriginalPosition": 0
                },
                {
                    "Name": "Share",
                    "OriginalName": "",
                    "Mandatory": true,
                    "OriginalPosition": 1,
                    "ParameterType": "string"
                },
                {
                    "Name": "Credential",
                    "OriginalName": "",
                    "ParameterType": "PSCredential",
                    "Mandatory": true,
                    "OriginalPosition": 10,
                    "ArgumentTransform": "\"/USER:$($Credential.UserName)\";$Credential.GetNetworkCredential().Password",
                    "ArgumentTransformType": "Inline"
                }
            ]
        }
    ]
}
```

The argument transformer converts the **PSCredential** object to `/USER:username password` for the
`net use` command.
