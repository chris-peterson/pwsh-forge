---
document type: cmdlet
external help file: ForgeCli-Help.xml
HelpUri: https://chris-peterson.github.io/pwsh-forge/#/Labels/Get-Label
Locale: en-US
Module Name: ForgeCli
ms.date: 08/30/2026
PlatyPS schema version: 2024-05-01
title: Get-Label
---

# Get-Label

## SYNOPSIS

List labels or fetch one by name

## SYNTAX

### __AllParameterSets

```
Get-Label [[-Name] <string>] [-Group <string>] [-Repo <string>] [-Forge <string>]
 [<CommonParameters>]
```

## ALIASES

## DESCRIPTION


Retrieves labels from a repository on GitHub or GitLab. Supplying `-Name` returns the single
matching label.

GitHub fetches a named label directly; GitLab lists the labels and matches on name, so the
result is the same but the request count is not.

## EXAMPLES

### Example 1

Get-Label -Repo owner/repo

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

### -Group

Group or organization identifier. Gitlab only; Github labels are repository-scoped

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

### -Name

Label name

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



