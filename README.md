# PowerShell Crescendo

PowerShell is capable of invoking native applications like any shell. However,
it would be an improved experience if the native command could participate
in the PowerShell pipeline and take advantage of the parameter behaviors
that are part of PowerShell.

The Crescendo module is an experiment to provide a novel way to create functions
which invoke native commands by using a `JSON` configuration file.

The Microsoft.PowerShell.Crescendo module provides a way to more easily for native commands to
participate in the PowerShell pipeline by facilitating parameter handling,
converting native output into objects, and calling the native executable.
This module provides a way to create a small bit of json,
which can then be used to create a function which calls the native command.

A schema is provided as part of the module which may be used for authoring.

The Crescendo module allows you to define parameters which can
be used by the native command. You can add attributes to the parameters
to have the proxies take advantage of the PowerShell pipeline and value
validation.

You can find more about it in the PowerShell blogs:
[Part 1](https://devblogs.microsoft.com/powershell/native-commands-in-powershell-a-new-approach/)
and
[Part 2](https://devblogs.microsoft.com/powershell/native-commands-in-powershell-a-new-approach-part-2)

We're not taking PRs at the moment.
