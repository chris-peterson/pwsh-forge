---
document type: cmdlet
external help file: ForgeCli-Help.xml
HelpUri: https://chris-peterson.github.io/pwsh-forge/#/ChangeRequests/Get-ChangeRequestApproval
Locale: en-US
Module Name: ForgeCli
ms.date: 04/09/2026
PlatyPS schema version: 2024-05-01
title: Get-ChangeRequestApproval
---

# Get-ChangeRequestApproval

## SYNOPSIS

Get approvals on a change request

## SYNTAX

### __AllParameterSets

```
Get-ChangeRequestApproval [-Id] <string> [-Repo <string>] [-Forge <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION


Retrieves approval reviews from a change request on GitHub or GitLab.

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

Change request identifier

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 0
  IsRequired: true
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



