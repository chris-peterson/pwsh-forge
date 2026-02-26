# Backlog

Potential unified commands that need provider gaps or naming decisions resolved before implementation.

## Change Requests

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
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
