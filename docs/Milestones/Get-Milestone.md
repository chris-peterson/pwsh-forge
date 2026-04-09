---
document type: cmdlet
external help file: ForgeCli-Help.xml
HelpUri: https://chris-peterson.github.io/pwsh-forge/#/Milestones/Get-Milestone
Locale: en-US
Module Name: ForgeCli
ms.date: 04/09/2026
PlatyPS schema version: 2024-05-01
title: Get-Milestone
---

# Get-Milestone

## SYNOPSIS

Get milestone information

## SYNTAX

### __AllParameterSets

```
Get-Milestone [[-Id] <string>] [-State <string>] [-Repo <string>] [-Forge <string>]
 [<CommonParameters>]
```

## ALIASES

## DESCRIPTION


Retrieves milestones from a repository on GitHub or GitLab.

## EXAMPLES

### Example 1

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
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Id

Milestone identifier

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
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

### -Repo

Repository or project identifier

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
  IsRequired: false
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -State

Filter by state (open, closed)

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: Named
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



