---
document type: cmdlet
external help file: ForgeCli-Help.xml
HelpUri: https://chris-peterson.github.io/pwsh-forge/#/Search/Search-Forge
Locale: en-US
Module Name: ForgeCli
ms.date: 09/15/2026
PlatyPS schema version: 2024-05-01
title: Search-Forge
---

# Search-Forge

## SYNOPSIS

Search a whole forge

## SYNTAX

### __AllParameterSets

```
Search-Forge [-Query] <string> [-Scope <string>] [-Group <string>] [-Filename <string>]
 [-MaxPages <uint>] [-All] [-Forge <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Searches across everything the authenticated user can see, rather than within a single
repository. `Search-Repo` is the repository-scoped counterpart.

The two providers accept different scopes. `code` and `repos` work on both; `commits`,
`issues`, and `users` are GitHub only, and `changerequests` is GitLab only. Asking for a
scope the active provider cannot express warns and searches code instead, so check for
warnings before trusting the result of a scoped search written for the other forge.

## EXAMPLES

### Example 1

Find every repository whose name or description mentions forge:

```powershell
Search-Forge -Query 'forge' -Scope repos
```

### Example 2

Find open merge requests mentioning a term, narrowed to one GitLab group:

```powershell
Search-Forge -Query 'retry backoff' -Scope changerequests -Group 'platform' -Forge gitlab
```

### Example 3

Find code matching a term, capped at three pages of results:

```powershell
Search-Forge -Query 'Resolve-ForgeCommand' -Scope code -MaxPages 3
```

## PARAMETERS

### -All

Retrieve all pages of results

```yaml
Type: System.Management.Automation.SwitchParameter
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

### -Filename

Restrict a code search to files with this name. Gitlab only

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

Narrow the search to one group. Gitlab only

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

### -MaxPages

Maximum number of pages to retrieve. Gitlab caps by result count instead, at 20 per page

```yaml
Type: System.UInt32
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

### -Query

Search query string

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

### -Scope

What to search. Github accepts code, commits, issues, repos, users; Gitlab accepts code,
changerequests, repos

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
