# Backlog

Potential unified commands that need provider gaps or naming decisions resolved before implementation.

## Change Requests

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Get-ChangeRequest -ReviewedBy` | `Get-GithubPullRequest -ReviewedBy` | `Get-GitlabMergeRequest -Role reviewer` | **Gap**: pwsh-github lacks `-ReviewedBy`; forge `Get-ChangeRequest` has no `Role`/`ReviewedBy` param. GitLab already works via `-Role reviewer`. GitHub needs search query `reviewed-by:<user>` added to `Get-GithubPullRequest`. |
| `New-ChangeRequestComment` | `New-GithubPullRequestComment` | `New-GitlabMergeRequestNote` | **Blocked**: `New-GitlabMergeRequestNote` does not exist in pwsh-gitlab |

## Issues

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Get-IssueComment` | `Get-GithubIssueComment` | `Get-GitlabIssueNote` | **Blocked**: `Get-GitlabIssueNote` lacks `-Since`, `-MaxPages`, `-All` params |

## Repositories

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Update-Repo` | `Update-GithubRepository` | `Update-GitlabProject` | **Blocked**: `Update-GitlabProject` lacks `-Description` param |

## Search / Utility

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Search-Forge` | `Search-Github` | `Search-Gitlab` | **Blocked**: `Search-Gitlab` lacks `-MaxPages`; renamed from `Search` to avoid ambiguity |
| `Invoke-ForgeApi` | `Invoke-GithubApi` | `Invoke-GitlabApi` | Renamed from `Invoke-Api` to avoid ambiguity |
| `Get-ForgeConfiguration` | `Get-GithubConfiguration` | `Get-GitlabConfiguration` | Renamed from `Get-Configuration` to avoid ambiguity |

## Resource Enrichment

| Feature | Description | Notes |
|---|---|---|
| `ConvertFrom-Url` | Given an arbitrary URL, return a well-structured Forge resource object | Use cases: AI-assisted development, link unfurling, structured metadata extraction. Should support forge-aware URLs (e.g. GitHub/GitLab issue, PR, repo links) and return typed objects with relevant properties. Requires provider-level implementations in pwsh-github and pwsh-gitlab. |
