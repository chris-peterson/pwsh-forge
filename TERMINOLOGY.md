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
noun differs between providers (with a provider prefix added):

| Forge Noun             | Github               | Gitlab            |
|------------------------|----------------------|-------------------|
| Branch                 | Branch               | Branch            |
| ChangeRequest          | PullRequest          | MergeRequest      |
| ChangeRequestComment   | PullRequestComment   | MergeRequestNote  |
| Commit                 | Commit               | Commit            |
| Group                  | Organization         | Group             |
| GroupMember            | OrganizationMember   | GroupMember       |
| Issue                  | Issue                | Issue             |
| IssueComment           | IssueComment         | IssueNote         |
| Milestone              | Milestone            | Milestone         |
| Release                | Release              | Release           |
| Repo                   | Repository           | Project           |
| User                   | User                 | User              |

For example, `Get-Repo` dispatches to `Get-GithubRepository` or
`Get-GitlabProject`. The canonical mapping is maintained in
[Init.psm1](src/ForgeCli/Private/Init.psm1).

## Unified Command Surface

`ForgeCli` uses the common terms for command names, dispatching to the
provider-specific command based on git remote context:

| ForgeCli Command           | Github Provider                   | Gitlab Provider              |
|----------------------------|-----------------------------------|------------------------------|
| `Add-GroupMember`          | `Add-GithubOrganizationMember`    | `Add-GitlabGroupMember`      |
| `Close-ChangeRequest`      | `Close-GithubPullRequest`         | `Close-GitlabMergeRequest`   |
| `Close-Issue`              | `Close-GithubIssue`               | `Close-GitlabIssue`          |
| `Get-Branch`               | `Get-GithubBranch`                | `Get-GitlabBranch`           |
| `Get-ChangeRequest`        | `Get-GithubPullRequest`           | `Get-GitlabMergeRequest`     |
| `Get-ChangeRequestComment` | `Get-GithubPullRequestComment`    | `Get-GitlabMergeRequestNote` |
| `Get-Commit`               | `Get-GithubCommit`                | `Get-GitlabCommit`           |
| `Get-Group`                | `Get-GithubOrganization`          | `Get-GitlabGroup`            |
| `Get-GroupMember`          | `Get-GithubOrganizationMember`    | `Get-GitlabGroupMember`      |
| `Get-Issue`                | `Get-GithubIssue`                 | `Get-GitlabIssue`            |
| `Get-Milestone`            | `Get-GithubMilestone`             | `Get-GitlabMilestone`        |
| `Get-Release`              | `Get-GithubRelease`               | `Get-GitlabRelease`          |
| `Get-Repo`                 | `Get-GithubRepository`            | `Get-GitlabProject`          |
| `Get-User`                 | `Get-GithubUser`                  | `Get-GitlabUser`             |
| `Merge-ChangeRequest`      | `Merge-GithubPullRequest`         | `Merge-GitlabMergeRequest`   |
| `New-Branch`               | `New-GithubBranch`                | `New-GitlabBranch`           |
| `New-ChangeRequest`        | `New-GithubPullRequest`           | `New-GitlabMergeRequest`     |
| `New-Issue`                | `New-GithubIssue`                 | `New-GitlabIssue`            |
| `New-IssueComment`         | `New-GithubIssueComment`          | `New-GitlabIssueNote`        |
| `New-Repo`                 | `New-GithubRepository`            | `New-GitlabProject`          |
| `Open-Issue`               | `Open-GithubIssue`                | `Open-GitlabIssue`           |
| `Remove-Branch`            | `Remove-GithubBranch`             | `Remove-GitlabBranch`        |
| `Remove-GroupMember`       | `Remove-GithubOrganizationMember` | `Remove-GitlabGroupMember`   |
| `Remove-Repo`              | `Remove-GithubRepository`         | `Remove-GitlabProject`       |
| `Search-Repo`              | `Search-GithubRepository`         | `Search-GitlabProject`       |
| `Update-ChangeRequest`     | `Update-GithubPullRequest`        | `Update-GitlabMergeRequest`  |
| `Update-Issue`             | `Update-GithubIssue`              | `Update-GitlabIssue`         |

Provider detection reads the git remote to determine whether the current
directory is a Github or Gitlab repo, then routes to the appropriate provider.
