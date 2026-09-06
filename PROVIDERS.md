# Provider Feature Matrix

How each forge command's common parameters map to provider-specific parameters.
The mapping code lives inline in each command in
[Forge.psm1](src/ForgeCli/Forge.psm1) -- this document is the reference.

## Get-Issue

| Common Param   | Github                | Gitlab                                |
|----------------|-----------------------|---------------------------------------|
| `-Id`          | `-IssueNumber`        | `-IssueId`                            |
| `-State open`  | `-State open`         | `-State opened`                       |
| `-State closed`| `-State closed`       | `-State closed`                       |
| `-State all`   | `-State all`          | (omits State param)                   |
| `-Mine`        | `-Mine`               | `-Mine`                               |
| `-Group`       | `-Organization`       | `-GroupId`                            |
| `-Assignee`    | `-Assignee`           | `-AssigneeUsername`                   |
| `-Author`      | `-Creator`            | `-AuthorUsername`                     |
| `-Labels`      | `-Labels`             | `-Labels`                             |
| `-Since`       | `-Since`              | `-CreatedAfter`                       |
| `-Sort`        | `-Sort`               | `-OrderBy` (`comments` not supported) |
| `-Direction`   | `-Direction`          | `-Sort`                               |
| `-MaxPages`    | `-MaxPages`           | `-MaxPages`                           |
| `-All`         | `-All`                | `-All`                                |

## Get-ChangeRequest

| Common Param     | Github                  | Gitlab                  |
|------------------|-------------------------|-------------------------|
| `-Id`            | `-PullRequestNumber`    | `-MergeRequestId`       |
| `-State open`    | `-State open`           | `-State opened`         |
| `-State closed`  | `-State closed`         | `-State closed`         |
| `-State all`     | `-State all`            | `-State all`            |
| `-State merged`  | `-State closed` (warn)  | `-State merged`         |
| `-Mine`          | `-Mine`                 | `-Mine`                 |
| `-Group`         | not yet supported       | `-GroupId`              |
| `-SourceBranch`  | `-Head`                 | `-SourceBranch`         |
| `-TargetBranch`  | `-Base`                 | `-TargetBranch`         |
| `-Author`        | `-Author`               | `-Username`             |
| `-IsDraft`       | `-IsDraft`              | `-IsDraft`              |
| `-Since`         | `-Since`                | `-CreatedAfter`         |
| `-MaxPages`      | `-MaxPages`             | `-MaxPages`             |
| `-All`           | `-All`                  | `-All`                  |

## Get-Repo

| Common Param       | Github                | Gitlab                |
|--------------------|-----------------------|-----------------------|
| `-Id`              | `-Repository`         | `-ProjectId`          |
| `-Mine`            | `-Mine`               | `-Mine`               |
| `-Group`           | `-Organization`       | `-GroupId`            |
| `-Select`          | `-Select`             | `-Select`             |
| `-IncludeArchived` | not applicable        | `-IncludeArchived`    |
| `-MaxPages`        | `-MaxPages`           | `-MaxPages`           |
| `-All`             | `-All`                | `-All`                |

## Get-Branch

| Common Param   | Github                | Gitlab                  |
|----------------|-----------------------|-------------------------|
| `-Name`        | `-Name`               | `-Ref`                  |
| `-Protected`   | `-Protected`          | not supported (use `Get-GitlabProtectedBranch`) |
| `-Search`      | not supported         | `-Search`               |
| `-MaxPages`    | `-MaxPages`           | `-MaxPages`             |
| `-All`         | `-All`                | `-All`                  |

## Get-Release

| Common Param   | Github                | Gitlab                  |
|----------------|-----------------------|-------------------------|
| `-Tag`         | `-Tag`                | `-Tag`                  |
| `-Latest`      | `-Latest`             | not supported           |
| `-MaxPages`    | `-MaxPages`           | `-MaxPages`             |
| `-All`         | `-All`                | `-All`                  |

## Get-User

| Common Param   | Github                | Gitlab                  |
|----------------|-----------------------|-------------------------|
| `-Username`    | `-Username`           | `-UserId`               |
| `-Me`          | `-Me`                 | `-Me`                   |
| `-Select`      | `-Select`             | `-Select`               |

## Get-UserActivity

| Common Param   | Github                              | Gitlab                  |
|----------------|-------------------------------------|-------------------------|
| `-Mine`        | `-Username` (resolved via `GET /user`) | `-Me`                |
| `-Username`    | `-Username`                         | `-UserId`               |
| `-Since`       | client-side filter on `created_at`  | `-After`                |
| `-Until`       | client-side filter on `created_at`  | `-Before`               |
| `-Action`      | client-side filter on event `type`  | `-Action`               |
| `-TargetType`  | client-side filter on event `type`  | `-TargetType`           |
| `-MaxPages`    | `-MaxPages`                         | `-MaxPages`             |
| `-All`         | `-All`                              | `-All`                  |

**GitHub limitation:** The Events API returns at most 300 events within a
~90-day rolling window. `-Since`/`-Until` filter within that window but
cannot reach further back. GitLab supports server-side date ranges with
no such cap.

## Get-Group

| Common Param   | Github                | Gitlab                  |
|----------------|-----------------------|-------------------------|
| `-Name`        | `-Name`               | `-GroupId`              |
| `-Mine`        | `-Mine`               | not directly supported  |
| `-MaxPages`    | `-MaxPages`           | `-MaxPages`             |
| `-All`         | `-All`                | `-All`                  |

## Get-Label

| Common Param   | Github                | Gitlab                  |
|----------------|-----------------------|-------------------------|
| `-Name`        | `-Name`               | `-Name`                 |
| `-Repo`        | `-RepositoryId`       | `-ProjectId`            |
| `-Group`       | not supported         | `-GroupId`              |

**Scope defaults to the current repository.** Github's `-RepositoryId`
defaults to `.`; the Gitlab branch passes `.` explicitly so both providers
resolve the repository from the working directory.

**Name lookup differs in request count.** Github fetches the named label
directly. Gitlab lists the labels and matches on name, so the result is the
same and the request count is not.

**`-Group` and `-Repo` are separate scopes.** A Gitlab label lives on a project
or on a group, not both, so supplying `-Group` selects the group scope and
warns that `-Repo` went unused.

## New-Label

| Common Param   | Github                | Gitlab                  |
|----------------|-----------------------|-------------------------|
| `-Name`        | `-Name`               | `-Name`                 |
| `-Color`       | `-Color`              | `-Color`                |
| `-Description` | `-Description`        | `-Description`          |
| `-Priority`    | not supported         | `-Priority`             |
| `-Repo`        | `-RepositoryId`       | `-ProjectId`            |
| `-Group`       | not supported         | `-GroupId`              |

**Color format is provider-specific.** Both providers assign `-Color`
straight into the request body, so a leading `#`, three-digit shorthand, or a
named color reaches the forge unaltered.

## Update-Label

| Common Param   | Github                | Gitlab                             |
|----------------|-----------------------|------------------------------------|
| `-Name`        | `-Name`               | resolved to `-LabelId`             |
| `-NewName`     | `-NewName`            | `-NewName`                         |
| `-Color`       | `-Color`              | `-Color`                           |
| `-Description` | `-Description`        | `-Description`                     |
| `-Priority`    | not supported         | `-Priority`                        |
| `-Repo`        | `-RepositoryId`       | `-ProjectId`                       |
| `-Group`       | not supported         | `-GroupId`                         |

## Remove-Label

| Common Param   | Github                | Gitlab                             |
|----------------|-----------------------|------------------------------------|
| `-Name`        | `-Name`               | resolved to `-LabelId`             |
| `-Repo`        | `-RepositoryId`       | `-ProjectId`                       |
| `-Group`       | not supported         | `-GroupId`                         |

**Gitlab keys writes on a numeric id.** `Update-GitlabLabel` and
`Remove-GitlabLabel` accept only `-LabelId`, so the Gitlab branch resolves
`-Name` through `Get-Label` before dispatching.

## Adding Support

When a cell says "not supported", the forge command will emit a
warning at runtime. To fix it, add the mapping in the provider's
`switch` block in [Forge.psm1](src/ForgeCli/Forge.psm1) and update
this table.
