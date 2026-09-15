---
document type: cmdlet
external help file: ForgeCli-Help.xml
HelpUri: https://chris-peterson.github.io/pwsh-forge/#/Utility/Invoke-ForgeApi
Locale: en-US
Module Name: ForgeCli
ms.date: 09/15/2026
PlatyPS schema version: 2024-05-01
title: Invoke-ForgeApi
---

# Invoke-ForgeApi

## SYNOPSIS

Call a forge REST endpoint directly

## SYNTAX

### __AllParameterSets

```
Invoke-ForgeApi [-HttpMethod] <string> [-Path] <string> [[-Query] <hashtable>] [-Body <hashtable>]
 [-MaxPages <uint>] [-Forge <string>] [<CommonParameters>]
```

## ALIASES

## DESCRIPTION

Reaches an endpoint `ForgeCli` does not wrap, using the credentials and base URL the active
provider is already configured with. Authentication, pagination, and host resolution are
handled; everything else is the caller's.

The path and the response are the provider's own, not a unified shape. A GitHub call takes a
GitHub path and returns GitHub's JSON, and the same is true of GitLab, so code written against
one will not run against the other. That is the trade an escape hatch makes: reach for
`Invoke-ForgeApi` when no unified command covers what you need, and expect to branch on the
provider yourself.

## EXAMPLES

### Example 1

Read the authenticated user from whichever forge the current repository belongs to:

```powershell
Invoke-ForgeApi GET 'user'
```

### Example 2

List a GitHub repository's deploy keys, paging through all of them:

```powershell
Invoke-ForgeApi GET 'repos/chris-peterson/pwsh-forge/keys' -MaxPages 10 -Forge github
```

### Example 3

Create a GitLab project hook:

```powershell
Invoke-ForgeApi POST 'projects/42/hooks' -Body @{ url = 'https://example.com/hook'; push_events = $true } -Forge gitlab
```

## PARAMETERS

### -Body

Request body, sent as JSON

```yaml
Type: System.Collections.Hashtable
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

### -HttpMethod

HTTP verb, such as GET, POST, PUT, or DELETE

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases:
- Method
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

### -MaxPages

Maximum number of pages to retrieve

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

### -Path

Endpoint path relative to the provider's API root, such as `user` or `projects/42/hooks`

```yaml
Type: System.String
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 1
  IsRequired: true
  ValueFromPipeline: false
  ValueFromPipelineByPropertyName: false
  ValueFromRemainingArguments: false
DontShow: false
AcceptedValues: []
HelpMessage: ''
```

### -Query

Query string parameters

```yaml
Type: System.Collections.Hashtable
DefaultValue: ''
SupportsWildcards: false
Aliases: []
ParameterSets:
- Name: (All)
  Position: 2
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
