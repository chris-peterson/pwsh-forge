# Backlog

Potential unified commands that need provider gaps or naming decisions resolved before implementation.
Once a command is ready to start, it moves to an issue and comes off this list.

## Change Requests

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Get-ChangeRequest -Reviewer` | `Get-GithubPullRequest -ReviewedBy` | `Get-GitlabMergeRequest -ReviewerUsername` | **Semantics differ**: GitHub's `reviewed-by:` matches pull requests the user submitted a review on; GitLab's `reviewer_username` matches merge requests the user is assigned to review. Decide which one `-Reviewer` means and translate the other provider to it. |
| `New-ChangeRequestComment` | `New-GithubPullRequestComment` | `New-GitlabMergeRequestNote` | **Ready**: `New-GitlabMergeRequestNote` ships in GitlabCli 1.174.0. |

## Issues

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Get-IssueComment` | `Get-GithubIssueComment` | `Get-GitlabIssueNote` | **Blocked**: `Get-GitlabIssueNote` lacks `-Since`, `-MaxPages`, `-All` params; tracked by chris-peterson/pwsh-gitlab#111 |

## Repositories

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Update-Repo` | `Update-GithubRepository` | `Update-GitlabProject` | **Blocked**: `Update-GitlabProject` lacks `-Description` param |

## Search

| Feature | Provider | Notes |
|---|---|---|
| `Search-GitlabProject -Scope` validation | pwsh-gitlab | `-Scope` is an unvalidated `[string]` defaulting to `blobs`, passed straight to the project search API, and results are always typed `Gitlab.SearchResult.Blob`. A `ValidateSet` would reject an unsupported scope up front instead of at the API, and let `Search-Repo` rely on the provider rather than duplicating the check. |

## User Activity

| Feature | Provider | Notes |
|---|---|---|
| Richer `ActionName` computed property | pwsh-github | Map `Type` to human-readable labels (`PushEvent` → `pushed to`, `PullRequestEvent` + `payload.action` → `opened`/`merged`/`closed`). GitLab already has this via `ActionName`. |
| Richer `Summary` computed property | pwsh-github | Include contextual detail (branch name, PR title, issue title) from `Payload` instead of just repo name. GitLab already does this via `PushData`/`TargetType`/`TargetTitle`. |

## Resource Enrichment

| Feature | Description | Notes |
|---|---|---|
| `ConvertFrom-Url` | Given an arbitrary URL, return a well-structured Forge resource object | Use cases: AI-assisted development, link unfurling, structured metadata extraction. Should support forge-aware URLs (e.g. GitHub/GitLab issue, PR, repo links) and return typed objects with relevant properties. Requires provider-level implementations in pwsh-github and pwsh-gitlab. |
