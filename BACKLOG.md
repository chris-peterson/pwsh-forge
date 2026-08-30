# Backlog

Potential unified commands that need provider gaps or naming decisions resolved before implementation.
Once a command is ready to start, it moves to an issue and comes off this list.

## Change Requests

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Get-ChangeRequest -ReviewedBy` | `Get-GithubPullRequest -ReviewedBy` | `Get-GitlabMergeRequest -Role reviewer` | **Gap**: pwsh-github lacks `-ReviewedBy`; forge `Get-ChangeRequest` has no `Role`/`ReviewedBy` param. GitLab already works via `-Role reviewer`. GitHub needs search query `reviewed-by:<user>` added to `Get-GithubPullRequest`. |
| `New-ChangeRequestComment` | `New-GithubPullRequestComment` | `New-GitlabMergeRequestNote` | **Blocked**: `New-GitlabMergeRequestNote` does not exist in pwsh-gitlab; tracked by chris-peterson/pwsh-gitlab#111 |

## Issues

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Get-IssueComment` | `Get-GithubIssueComment` | `Get-GitlabIssueNote` | **Blocked**: `Get-GitlabIssueNote` lacks `-Since`, `-MaxPages`, `-All` params; tracked by chris-peterson/pwsh-gitlab#111 |

## Repositories

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Update-Repo` | `Update-GithubRepository` | `Update-GitlabProject` | **Blocked**: `Update-GitlabProject` lacks `-Description` param |

## User Activity

| Feature | Provider | Notes |
|---|---|---|
| Richer `ActionName` computed property | pwsh-github | Map `Type` to human-readable labels (`PushEvent` → `pushed to`, `PullRequestEvent` + `payload.action` → `opened`/`merged`/`closed`). GitLab already has this via `ActionName`. |
| Richer `Summary` computed property | pwsh-github | Include contextual detail (branch name, PR title, issue title) from `Payload` instead of just repo name. GitLab already does this via `PushData`/`TargetType`/`TargetTitle`. |

## Resource Enrichment

| Feature | Description | Notes |
|---|---|---|
| `ConvertFrom-Url` | Given an arbitrary URL, return a well-structured Forge resource object | Use cases: AI-assisted development, link unfurling, structured metadata extraction. Should support forge-aware URLs (e.g. GitHub/GitLab issue, PR, repo links) and return typed objects with relevant properties. Requires provider-level implementations in pwsh-github and pwsh-gitlab. |
