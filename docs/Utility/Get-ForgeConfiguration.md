---
document type: cmdlet
external help file: ForgeCli-Help.xml
HelpUri: https://chris-peterson.github.io/pwsh-forge/#/Utility/Get-ForgeConfiguration
Locale: en-US
Module Name: ForgeCli
ms.date: 09/15/2026
PlatyPS schema version: 2024-05-01
title: Get-ForgeConfiguration
---

# Get-ForgeConfiguration

## SYNOPSIS

Show the active provider's configuration

## SYNTAX

### __AllParameterSets

```
Get-ForgeConfiguration [[-Forge] <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Returns the configuration of whichever provider is active: base URL, configured sites, and
whatever else that provider tracks.

The shape is the provider's own and differs between them. GitLab's configuration lists
several sites with one marked default; GitHub's describes a single host. Read it to answer
"what am I pointed at", not to drive logic that has to work the same way on both.

This reports provider configuration only. `ForgeCli`'s own settings are separate.

## EXAMPLES

### Example 1

Show the configuration for the forge the current repository belongs to:

```powershell
Get-ForgeConfiguration
```

### Example 2

Show GitLab's configuration regardless of the current directory:

```powershell
Get-ForgeConfiguration -Forge gitlab
```

## PARAMETERS

### -Forge

Forge provider (github, gitlab). Auto-detected from git remote if not specified

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Provider
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable,
-InformationAction, -InformationVariable, -OutBuffer, -OutVariable, -PipelineVariable,
-ProgressAction, -Verbose, -WarningAction, and -WarningVariable. For more information, see
[about_CommonParameters](https://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Object

## NOTES

## RELATED LINKS
