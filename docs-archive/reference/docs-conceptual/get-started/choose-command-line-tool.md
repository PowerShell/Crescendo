---
description: How to select a command-line tool to amplify using Crescendo.
ms.date: 08/16/2023
title: Choosing a command-line tool to amplify
---
# Choosing the command-line tool for Crescendo

Using Crescendo is a rapid, reliable way to _amplify_ a command-line tool to produce a cmdlet-like
experience. Many times, the tool you need to work with is directly tied to the technology you are
attempting to automate. This makes the tool choice simple. However, not all tools work the same way.
To optimize your investment when developing a cmdlet, consider the following criteria:

## Command-line tools that make good candidates

- **The original tool is difficult to use.**

  If the tool is simple to use and provides the information you need, there is no need to create a
  cmdlet. However, this isn't always the case with command-line tools. Many command-line tools have
  their own unique syntax, parameters, and output that make it difficult for unfamiliar
  administrators to use the tool's commands. Converting a command into a cmdlet provides all the
  benefits of cmdlet discovery, syntax consistency, and structured output as objects.

- **The command-line tool output is difficult to use in automation.**

  Command-line tools output their information to the screen as string data. This isn't the
  structured data (objects) that PowerShell expects in the pipeline, which prevents you from using
  PowerShell cmdlets, such as `Where-Object` and `ForEach-Object`. Crescendo assists you with
  _amplifying_ the command-line tool experience so that the tool can participate in the PowerShell
  pipeline.

- **The command-line tool doesn't provide adequate help.**

  Command-line tools that lack help information can be difficult to use. Cmdlets can have
  comprehensive help information that includes details on parameters, descriptions, and examples.
  Crescendo gives you the ability to create the missing help for your amplified commands.

## Command-line tools that make bad candidates

- **Does a cmdlet already exist?**

  PowerShell has a well-established ecosystem of modules that extend the built-in capabilities of
  PowerShell. Before deciding to amplify a command-line tool with Crescendo, first check to see if a
  cmdlet already exists that performs your intended goal. For example, wrapping the Windows command
  `ipconfig.exe` to get the current IP address is a poor choice because the module **NetTCPIP**
  contains `Get-NetIPConfiguration`, which provides the same information with structured output.

- **Are there better ways?**

  Often the information you need for automation can be obtained quicker than making a cmdlet.
  PowerShell lets you access other frameworks and libraries, such as WMI and .NET. Instead of
  investing time amplifying a command-line tool, you might be able to get the information more
  quickly using one of these libraries.

- **Is the output trivial?**

  In some situations, the command-line tool may produce output that's easy to use in your
  automation. If this is the case, investing time in creating a cmdlet with structured output may
  not be worth the effort of creating an amplified cmdlet.

## Best Practices

- **Optimize your time investment by focusing on what you need.**

  When examining a command-line tool for automation, remember you aren't required to replicate all
  features of the tool in the amplified cmdlet. In other words, focus on the features of the tool
  you need to accomplish your goal. If a tool has 12 use cases and you only need the functionality
  of two, create a Crescendo configuration only for the two scenarios you need.

## Next step

> [!div class="nextstepaction"]
> [Researching the command-line tool's syntax and output](research-tool.md)
