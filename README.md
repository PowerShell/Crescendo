# PowerShell Crescendo

PowerShell is capable of invoking native applications like any shell. However,
it would be an improved experience if the native command could participate
in the PowerShell pipeline and take advantage of the parameter behaviors
that are part of PowerShell.

The Crescendo module is an experiment to provide a novel way to create functions
which invoke native commands by using a `JSON` configuration file.

The Microsoft.PowerShell.Crescendo module provides native commands a way to more easily
participate in the PowerShell pipeline by facilitating parameter handling,
converting native output into objects, and calling the native executable.
This module provides a way to create a small bit of json,
which can then be used to create a function which calls the native command.

A schema is provided as part of the module which may be used for authoring.

The Crescendo module allows you to define parameters which can
be used by the native command. You can add attributes to the parameters
to have the proxies take advantage of the PowerShell pipeline and value
validation.

## Progress and releases

To learn the latest about our progress and releases:
- [Crescendo.Preview.1](https://devblogs.microsoft.com/powershell/announcing-powershell-crescendo-preview-1/)
- [Crescendo.Preview.2](https://devblogs.microsoft.com/powershell/announcing-powershell-crescendo-preview-2/)
- [Crescendo.Preview.3](https://devblogs.microsoft.com/powershell/announcing-powershell-crescendo-preview-3/)
- - [Crescendo.Preview.4](https://devblogs.microsoft.com/powershell/announcing-powershell-crescendo-preview-4/)

You can learn more about our approach from the blog discussion:
[Part 1](https://devblogs.microsoft.com/powershell/native-commands-in-powershell-a-new-approach/)
and
[Part 2](https://devblogs.microsoft.com/powershell/native-commands-in-powershell-a-new-approach-part-2)

## How to use Crescendo

For more information using **Microsoft.PowerShell.Crescendo**, check out this excellent blog series
by Sean Wheeler posted to the
[PowerShell Community](https://devblogs.microsoft.com/powershell-community/).

* [My Crescendo journey](https://devblogs.microsoft.com/powershell-community/my-crescendo-journey/)
* [Converting string output to objects](https://devblogs.microsoft.com/powershell-community/converting-string-output-to-objects/)
* [A closer look at the parsing code of a Crescendo output handler](https://devblogs.microsoft.com/powershell-community/a-closer-look-at-the-parsing-code-of-a-crescendo-output-handler/)
* [A closer look at the Crescendo configuration](https://devblogs.microsoft.com/powershell-community/a-closer-look-at-the-crescendo-configuration/)

## Community guidance

We are approaching our general release (GA) of **PowerShell Crescendo 1.0**. We look forward to
community feedback and suggestions. Please file issues for erroneous behavior or suggested features.
As we stabilize for GA, we will not be taking feature PRs.
