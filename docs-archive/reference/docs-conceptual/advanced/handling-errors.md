---
description: This article describes how to handle native command errors in your Crescendo output handler.
ms.date: 08/23/2023
title: Handling errors in Crescendo
---
# Handling errors in Crescendo

Prior to Crescendo 1.1, native command errors were streamed directly to the user, not captured by
Crescendo. This prevented you from creating enhanced error handling. Now, Crescendo can capture
error output (stderr) from the native command.

By default, when you don't define an output handler, Crescendo uses the default handler. The default
output handler ensures that errors respect the `-ErrorVariable` and `-ErrorAction` parameters and
adds errors to `$Error`. If you set `HandlerType` to `ByPass`, Crescendo doesn't capture errors and
all output is streamed directly to the user.

Crescendo v1.1 adds two internal functions to manage errors.

- `Push-CrescendoNativeError` adds errors to an error queue. This function is automatically called
  by the output handler. You don't have to call it directly.
- `Pop-CrescendoNativeError` removes an error from the error queue. Use this function to inspect
  errors in the output handler so you can handle them or pass them through to the caller.

By default, `$PSNativeCommandUseErrorActionPreference` is set to `$true`. This causes Crescendo to
produce an additional error record for every error. To prevent this, Crescendo changes the value to
`$false` for each generated cmdlet. This change is scoped to your cmdlets in the generated module, so
it doesn't affect cmdlets outside of the module.

## Returning errors to the user

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

## Example - The native command writes information and errors to stderr

Consider the following scenario. You have a command-line tool that does the following:

- Writes informational messages such as banner text, progress, and others to `stderr`
- Writes error messages to `stderr`
- Writes successful output of data to `stdout`

You want to create a Crescendo output handler that can distinguish between informational messages
and errors, as well as, convert the data from successful output to PowerShell objects.

The following examples show a fictitious command-line tool called `fizztool.exe` that has the
behavior described previously.

### Successful example

Here is an example invocation of the tool that should succeed:

```
fizztool.exe --key fizz
```

The copyright line is written to stderr, and the JSON object is written to stdout.

```Output
fizztool.exe v1.0.0 (c) 2021 Tailspin Toys, Ltd.

{
    "fizz": "buzz"
}
```

If you run it from PowerShell, the you see the following output:

```powershell
fizztool.exe --key fizz | ConvertFrom-Json
```

```Output
fizztool.exe v1.0.0 (c) 2021 Tailspin Toys, Ltd.

fizz
----
buzz
```

### Failure example

Here is an example invocation of the tool that produces an error:

```
fizztool.exe --key buzz
```

The copyright line and the error message are written to `stderr`.

```Output
fizztool.exe v1.0.0 (c) 2021 Tailspin Toys, Ltd.
ERROR: Key not found: buzz
```

If you run it from PowerShell, the you see the following output:

```powershell
fizztool.exe --key buzz | ConvertFrom-Json
```

```Output
fizztool.exe v1.0.0 (c) 2021 Tailspin Toys, Ltd.
ERROR: Key not found: buzz
```

### Handling the errors in Crescendo

The following Crescendo configuration defines the cmdlet `Get-FizzBuzz` that calls the
`fizztool.exe`, processes the output, and handles error conditions.

```json
{
    "$schema": "https://aka.ms/PowerShell/Crescendo/Schemas/2022-06",
    "Commands": [
        {
            "Verb": "Get",
            "Noun": "FizzBuzz",
            "OriginalName": "fizztool",
            "Parameters": [
                {
                    "Name": "Key",
                    "OriginalName": "--key",
                    "ParameterType": "string",
                    "OriginalPosition": 0,
                    "Required": true
                },
            ],
            "OutputHandlers": [
                {
                    "ParameterSetName": "Default",
                    "HandlerType": "Function",
                    "Handler": "FizzToolParser"
                }
            ]
        }
    ]
}
```

The output handler use the following `FizzToolParser` function to process the output.

```powershell
function FizzToolParser {
    param(
        [Parameter(Mandatory)]
        [AllowNull()]
        $cmdResults = ''
    )

    if ($null -ne $cmdResults) {
        $cmdResults | Out-String | ConvertFrom-Json
    } else {
        Pop-CrescendoNativeError |
            Where-Object {$_ -like 'ERROR:*'} |
            Write-Error
    }
}
```

The `FizzToolParser` function does the following actions:

- If `$cmdResults` isn't null, it converts JSON output to a PowerShell object.
- If `$cmdResults` is null then it checks for errors.
  - `Pop-CrescendoNativeError` retrieves the error output from there queue.
  - The errors are filtered to select messages that start with `ERROR:`. Informational messages,
    such as the copyright notice, are ignored.
  - You could inspect the errors and handle them or pass them through to the caller, as shown in the
    function.

### Using the new cmdlet

```powershell
Get-FizzBuzz -Key fizz
```

```Output
fizz
----
buzz
```

```powershell
Get-FizzBuzz -Key buzz
```

```Output
Write-Error: ERROR: Key not found: buzz
```
