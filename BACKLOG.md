# Backlog

Potential unified commands that have implementations in both GitHub and GitLab providers.

## Change Requests

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Close-ChangeRequest` | `Close-GithubPullRequest` | `Close-GitlabMergeRequest` | Simple Id mapping |
| `Update-ChangeRequest` | `Update-GithubPullRequest` | `Update-GitlabMergeRequest` | Title, description, draft/ready, reviewers |
| `Get-ChangeRequestComment` | `Get-GithubPullRequestComment` | `Get-GitlabMergeRequestNote` | |
| `New-ChangeRequestComment` | `New-GithubPullRequestComment` | `New-GitlabMergeRequestNote` | |

## Branches

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `New-Branch` | `New-GithubBranch` | `New-GitlabBranch` | |
| `Remove-Branch` | `Remove-GithubBranch` | `Remove-GitlabBranch` | |

## Issues

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Open-Issue` | `Open-GithubIssue` | `Open-GitlabIssue` | Could also be `Update-Issue -State open` |
| `Get-IssueComment` | `Get-GithubIssueComment` | `Get-GitlabIssueNote` | |
| `New-IssueComment` | `New-GithubIssueComment` | `New-GitlabIssueNote` | |

## Repositories

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Update-Repo` | `Update-GithubRepository` | `Update-GitlabProject` | Name, description, visibility, settings |
| `Remove-Repo` | `Remove-GithubRepository` | `Remove-GitlabProject` | Destructive; confirm by default |

## Groups / Organizations

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Get-GroupMember` | `Get-GithubOrganizationMember` | `Get-GitlabGroupMember` | |
| `Add-GroupMember` | `Add-GithubOrganizationMember` | `Add-GitlabGroupMember` | |
| `Remove-GroupMember` | `Remove-GithubOrganizationMember` | `Remove-GitlabGroupMember` | |

## Project Management

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Get-Milestone` | `Get-GithubMilestone` | `Get-GitlabMilestone` | Only Get overlaps; GitHub also has New/Update/Remove |

## Search / Utility

| Forge Command | GitHub | GitLab | Notes |
|---|---|---|---|
| `Search` | `Search-Github` | `Search-Gitlab` | Generic cross-entity search |
| `Invoke-Api` | `Invoke-GithubApi` | `Invoke-GitlabApi` | Escape hatch for direct API calls |
| `Get-Configuration` | `Get-GithubConfiguration` | `Get-GitlabConfiguration` | Show current provider config |
