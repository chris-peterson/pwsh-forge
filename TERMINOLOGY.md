# Terminology Reference

Cross-platform terminology mapping for the unified PowerShell Git interface.

Github and Gitlab use different names for the same concepts.
This document is the source of truth for how platform-specific terms
map to the **common terms** used by `ForgeCli`.

## Core Resources

| Common Term        | Github             | Gitlab             | Notes                                                               |
|--------------------|--------------------|--------------------|---------------------------------------------------------------------|
| **Repo**           | Repository         | Project            | The code container. See [naming rationale](#why-repo).              |
| **ChangeRequest**  | Pull Request       | Merge Request      | The code review unit. See [naming rationale](#why-changerequest).   |
| **Issue**          | Issue              | Issue              | Same on both platforms.                                             |
| **Group**          | Organization       | Group              | Org/namespace that owns repos.                                      |
| **Branch**         | Branch             | Branch             | Same on both platforms.                                             |
| **Pipeline**       | Workflow / Actions  | Pipeline           | CI/CD execution. Structural differences beyond naming.             |
| **Milestone**      | Milestone          | Milestone          | Same on both platforms.                                             |
| **Label**          | Label              | Label              | Same on both platforms.                                             |
| **User**           | User               | User               | Same on both platforms.                                             |
| **UserActivity**   | Event              | UserEvent          | User activity feed. GitHub filters client-side for dates/actions.   |
| **Comment**        | Comment            | Note               | Attached to issues/CRs.                                             |

## Detailed Property Mappings

### Repo

Maps to: `Github.Repository` / `Gitlab.Project`

| Common Property    | Github                | Gitlab                    |
|--------------------|-----------------------|---------------------------|
| Id                 | `id`                  | `id`                      |
| Name               | `name`                | `name`                    |
| FullName           | `full_name`           | `path_with_namespace`     |
| Description        | `description`         | `description`             |
| Url                | `html_url`            | `web_url`                 |
| DefaultBranch      | `default_branch`      | `default_branch`          |
| Owner              | `owner.login`         | (group path)              |
| Visibility         | `visibility`          | `visibility`              |
| Archived           | `archived`            | `archived`                |

### ChangeRequest

Maps to: `Github.PullRequest` / `Gitlab.MergeRequest`

| Common Property    | Github                | Gitlab                    |
|--------------------|-----------------------|---------------------------|
| Id                 | `number`              | `iid`                     |
| Title              | `title`               | `title`                   |
| Description        | `body`                | `description`             |
| State              | `state`               | `state`                   |
| SourceBranch       | `head.ref`            | `source_branch`           |
| TargetBranch       | `base.ref`            | `target_branch`           |
| Author             | `user.login`          | `author.username`         |
| Url                | `html_url`            | `web_url`                 |
| Draft              | `draft`               | `work_in_progress`        |
| CreatedAt          | `created_at`          | `created_at`              |
| UpdatedAt          | `updated_at`          | `updated_at`              |
| MergedAt           | `merged_at`           | `merged_at`               |

### Issue

| Common Property    | Github                | Gitlab                    |
|--------------------|-----------------------|---------------------------|
| Id                 | `number`              | `iid`                     |
| Title              | `title`               | `title`                   |
| Description        | `body`                | `description`             |
| State              | `state`               | `state`                   |
| Author             | `user.login`          | `author.username`         |
| Assignee           | `assignee.login`      | `assignee.username`       |
| Labels             | `labels[].name`       | `labels[]`                |
| Url                | `html_url`            | `web_url`                 |
| CreatedAt          | `created_at`          | `created_at`              |
| UpdatedAt          | `updated_at`          | `updated_at`              |

### UserActivity

Maps to: `Github.Event` / `Gitlab.Event`

| Common Property    | Github                | Gitlab                    |
|--------------------|-----------------------|---------------------------|
| Id                 | `Id` (`EventId`)      | `Id`                      |
| CreatedAt          | `CreatedAt`           | `CreatedAt`               |
| Actor/Author       | `ActorName`           | `AuthorUsername`          |
| Action             | `Type` (e.g. `PushEvent`) | `ActionName` (e.g. `pushed to`) |
| Summary            | `Summary` (repo name) | `Summary` (branch/MR/issue title) |

**Formatting gap:** GitLab's `ActionName` is human-readable (`pushed to`, `accepted`,
`opened`) while GitHub's `Type` is a raw event class (`PushEvent`,
`PullRequestEvent`). GitLab's `Summary` includes contextual detail (branch names,
MR titles) while GitHub's is just the repo name. Improving GitHub's computed
properties is tracked in the backlog.

## Naming Rationale

### Why "Repo"

"Repo" is how developers actually talk about their code containers.
Both "repository" and "project" carry platform-specific baggage:

- **Github** uses "repository" as the primary resource but reserves
  "project" for its project-board feature (Projects v2)
- **Gitlab** uses "project" as the primary resource, with "repository"
  referring to the underlying git storage

"Repo" sidesteps both collisions. It aligns with everyday developer
language ("clone this repo", "which repo is that in?") and is shorter
than either formal name.

The mapping is explicit:

- `Get-Repo` dispatches to `Get-GithubRepository` or `Get-GitlabProject`

### Why "ChangeRequest"

Neither "pull request" nor "merge request" is neutral:

- "Pull request" is Github-specific, originating from the fork-and-pull model
- "Merge request" is Gitlab/Gitea terminology

"ChangeRequest" describes what the entity actually is: a request to
review and accept a set of changes. It's platform-neutral and
self-documenting. The `cr` alias keeps it terse.

The mapping is explicit:

- `Get-ChangeRequest` dispatches to `Get-GithubPullRequest` or `Get-GitlabMergeRequest`

### Why "Group" over "Organization"

"Group" is more generic and applies beyond Github's org model.
Gitlab groups can be nested; Github orgs cannot. "Group" works as
an abstraction over both.

## Noun Mapping

Each forge command is `<Verb>-<Noun>`. The verb is preserved; only the
noun differs between providers (with a provider prefix added).

`Forge`, `ForgeApi`, and `ForgeConfiguration` are the exceptions: they carry a
`Forge` the providers don't. A bare `Search`, `Invoke-Api`, or
`Get-Configuration` says nothing about what it acts on, and these sit in a shell
alongside every other loaded module, so the forge name does the disambiguating.

| Forge Noun             | Github               | Gitlab            |
|------------------------|----------------------|-------------------|
| Branch                 | Branch               | Branch            |
| ChangeRequest          | PullRequest          | MergeRequest      |
| ChangeRequestApproval  | PullRequestReview    | MergeRequestApproval |
| ChangeRequestComment   | PullRequestComment   | MergeRequestNote  |
| Commit                 | Commit               | Commit            |
| Forge                  | *(none)*             | *(none)*          |
| ForgeApi               | Api                  | Api               |
| ForgeConfiguration     | Configuration        | Configuration     |
| Group                  | Organization         | Group             |
| GroupMember            | OrganizationMember   | GroupMember       |
| Issue                  | Issue                | Issue             |
| IssueComment           | IssueComment         | IssueNote         |
| Label                  | Label                | Label             |
| Milestone              | Milestone            | Milestone         |
| Release                | Release              | Release           |
| Repo                   | Repository           | Project           |
| User                   | User                 | User              |
| UserActivity           | Event                | UserEvent         |

For example, `Get-Repo` dispatches to `Get-GithubRepository` or
`Get-GitlabProject`. The canonical mapping is maintained in
[Init.psm1](src/ForgeCli/Private/Init.psm1).

`Forge` maps to no noun on either provider, because the provider name is the
whole command: `Search-Forge` dispatches to `Search-Github` or `Search-Gitlab`.

## Search Scope

`Search-Forge -Scope` names what to search. The providers disagree about both
vocabulary and coverage, so the forge value is translated per provider. A scope
the active provider cannot express warns and searches code, which is what both
providers search when given no scope.

| Forge Scope      | Github         | Gitlab           |
|------------------|----------------|------------------|
| `code`           | `code`         | `blobs`          |
| `repos`          | `repositories` | `projects`       |
| `commits`        | `commits`      | —                |
| `issues`         | `issues`       | —                |
| `users`          | `users`        | —                |
| `changerequests` | —              | `merge_requests` |

`code` and `repos` are the only scopes both providers accept.

`Search-Repo -Scope` is a narrower, separate set (`code`, `commits`, `issues`)
because it searches within one repository.

## Unified Command Surface

`ForgeCli` uses the common terms for command names, dispatching to the
provider-specific command based on git remote context:

| ForgeCli Command            | Github Provider                   | Gitlab Provider                  |
|-----------------------------|-----------------------------------|----------------------------------|
| `Add-GroupMember`           | `Add-GithubOrganizationMember`    | `Add-GitlabGroupMember`          |
| `Close-ChangeRequest`       | `Close-GithubPullRequest`         | `Close-GitlabMergeRequest`       |
| `Close-Issue`               | `Close-GithubIssue`               | `Close-GitlabIssue`              |
| `Get-Branch`                | `Get-GithubBranch`                | `Get-GitlabBranch`               |
| `Get-ChangeRequest`         | `Get-GithubPullRequest`           | `Get-GitlabMergeRequest`         |
| `Get-ChangeRequestApproval` | `Get-GithubPullRequestReview`     | `Get-GitlabMergeRequestApproval` |
| `Get-ChangeRequestComment`  | `Get-GithubPullRequestComment`    | `Get-GitlabMergeRequestNote`     |
| `Get-Commit`                | `Get-GithubCommit`                | `Get-GitlabCommit`               |
| `Get-ForgeConfiguration`    | `Get-GithubConfiguration`         | `Get-GitlabConfiguration`        |
| `Get-Group`                 | `Get-GithubOrganization`          | `Get-GitlabGroup`                |
| `Get-GroupMember`           | `Get-GithubOrganizationMember`    | `Get-GitlabGroupMember`          |
| `Get-Issue`                 | `Get-GithubIssue`                 | `Get-GitlabIssue`                |
| `Get-Label`                 | `Get-GithubLabel`                 | `Get-GitlabLabel`                |
| `Get-Milestone`             | `Get-GithubMilestone`             | `Get-GitlabMilestone`            |
| `Get-Release`               | `Get-GithubRelease`               | `Get-GitlabRelease`              |
| `Get-Repo`                  | `Get-GithubRepository`            | `Get-GitlabProject`              |
| `Get-User`                  | `Get-GithubUser`                  | `Get-GitlabUser`                 |
| `Get-UserActivity`          | `Get-GithubEvent`                 | `Get-GitlabUserEvent`            |
| `Invoke-ForgeApi`           | `Invoke-GithubApi`                | `Invoke-GitlabApi`               |
| `Merge-ChangeRequest`       | `Merge-GithubPullRequest`         | `Merge-GitlabMergeRequest`       |
| `New-Branch`                | `New-GithubBranch`                | `New-GitlabBranch`               |
| `New-ChangeRequest`         | `New-GithubPullRequest`           | `New-GitlabMergeRequest`         |
| `New-Issue`                 | `New-GithubIssue`                 | `New-GitlabIssue`                |
| `New-IssueComment`          | `New-GithubIssueComment`          | `New-GitlabIssueNote`            |
| `New-Label`                 | `New-GithubLabel`                 | `New-GitlabLabel`                |
| `New-Milestone`             | `New-GithubMilestone`             | `New-GitlabMilestone`            |
| `New-Repo`                  | `New-GithubRepository`            | `New-GitlabProject`              |
| `Open-Issue`                | `Open-GithubIssue`                | `Open-GitlabIssue`               |
| `Remove-Branch`             | `Remove-GithubBranch`             | `Remove-GitlabBranch`            |
| `Remove-GroupMember`        | `Remove-GithubOrganizationMember` | `Remove-GitlabGroupMember`       |
| `Remove-Label`              | `Remove-GithubLabel`              | `Remove-GitlabLabel`             |
| `Remove-Milestone`          | `Remove-GithubMilestone`          | `Remove-GitlabMilestone`         |
| `Remove-Repo`               | `Remove-GithubRepository`         | `Remove-GitlabProject`           |
| `Search-Forge`              | `Search-Github`                   | `Search-Gitlab`                  |
| `Search-Repo`               | `Search-GithubRepository`         | `Search-GitlabProject`           |
| `Update-ChangeRequest`      | `Update-GithubPullRequest`        | `Update-GitlabMergeRequest`      |
| `Update-Issue`              | `Update-GithubIssue`              | `Update-GitlabIssue`             |
| `Update-Label`              | `Update-GithubLabel`              | `Update-GitlabLabel`             |
| `Update-Milestone`          | `Update-GithubMilestone`          | `Update-GitlabMilestone`         |

Provider detection reads the git remote to determine whether the current
directory is a Github or Gitlab repo, then routes to the appropriate provider.
