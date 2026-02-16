# Terminology Reference

Cross-platform terminology mapping for the unified PowerShell Git interface.

GitHub and GitLab use different names for the same concepts.
This document is the source of truth for how platform-specific terms
map to the **common terms** used by ForgeCli.

## Core Resources

| Common Term        | GitHub             | GitLab             | Notes                                                              |
|--------------------|--------------------|--------------------|---------------------------------------------------------------------|
| **Repo**           | Repository         | Project            | The code container. See [naming rationale](#why-repo).              |
| **ChangeRequest**  | Pull Request       | Merge Request      | The code review unit. See [naming rationale](#why-changerequest).   |
| **Issue**          | Issue              | Issue              | Same on both platforms.                                             |
| **Group**          | Organization       | Group              | Org/namespace that owns repos.                                      |
| **Branch**         | Branch             | Branch             | Same on both platforms.                                             |
| **Pipeline**       | Workflow / Actions  | Pipeline           | CI/CD execution. Structural differences beyond naming.              |
| **Milestone**      | Milestone          | Milestone          | Same on both platforms.                                             |
| **Label**          | Label              | Label              | Same on both platforms.                                             |
| **User**           | User               | User               | Same on both platforms.                                             |
| **Comment**        | Comment            | Note               | Attached to issues/CRs.                                            |

## Detailed Property Mappings

### Repo

Maps to: `GitHub.Repository` / `GitLab.Project`

| Common Property    | GitHub                | GitLab                    |
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

Maps to: `GitHub.PullRequest` / `GitLab.MergeRequest`

| Common Property    | GitHub                | GitLab                    |
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

| Common Property    | GitHub                | GitLab                    |
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
- **GitHub** uses "repository" as the primary resource but reserves
  "project" for its project-board feature (Projects v2)
- **GitLab** uses "project" as the primary resource, with "repository"
  referring to the underlying git storage

"Repo" sidesteps both collisions. It aligns with everyday developer
language ("clone this repo", "which repo is that in?") and is shorter
than either formal name.

The mapping is explicit:
- `Get-Repo` dispatches to `Get-GitHubRepository` or `Get-GitlabProject`

### Why "ChangeRequest"

Neither "pull request" nor "merge request" is neutral:
- "Pull request" is GitHub-specific, originating from the fork-and-pull model
- "Merge request" is GitLab/Gitea terminology

"ChangeRequest" describes what the entity actually is: a request to
review and accept a set of changes. It's platform-neutral and
self-documenting. The `cr` alias keeps it terse.

The mapping is explicit:
- `Get-ChangeRequest` dispatches to `Get-GitHubPullRequest` or `Get-GitlabMergeRequest`

### Why "Group" over "Organization"

"Group" is more generic and applies beyond GitHub's org model.
GitLab groups can be nested; GitHub orgs cannot. "Group" works as
an abstraction over both.

## Unified Command Surface

ForgeCli uses the common terms for command names, dispatching to the
provider-specific command based on git remote context:

| ForgeCli Command        | GitHub Provider            | GitLab Provider             |
|-------------------------|----------------------------|-----------------------------|
| `Get-Repo`              | `Get-GitHubRepository`     | `Get-GitlabProject`         |
| `Get-Issue`             | `Get-GitHubIssue`          | `Get-GitlabIssue`           |
| `Get-ChangeRequest`     | `Get-GitHubPullRequest`    | `Get-GitlabMergeRequest`    |
| `Get-Group`             | *(future)*                 | `Get-GitlabGroup`           |

Provider detection uses `Get-LocalGitContext` which reads the git remote
to determine whether the current directory is a GitHub or GitLab repo.
Providers register their command mappings via `Register-ForgeProvider`.
