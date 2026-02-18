# Provider Feature Matrix

How each forge command's common parameters map to provider-specific parameters.
The mapping code lives inline in each command in
[Forge.psm1](src/ForgeCli/Forge.psm1) -- this document is the reference.

## Get-Issue

| Common Param   | Github                | Gitlab                  |
|----------------|-----------------------|-------------------------|
| `-Id`          | `-IssueNumber`        | `-IssueId`              |
| `-State open`  | `-State open`         | `-State opened`         |
| `-State closed`| `-State closed`       | `-State closed`         |
| `-State all`   | `-State all`          | (omits State param)     |
| `-Mine`        | `-Mine`               | `-Mine`                 |
| `-Group`       | `-Organization`       | `-GroupId`              |
| `-Assignee`    | `-Assignee`           | `-AssigneeUsername`     |
| `-Author`      | `-Creator`            | `-AuthorUsername`       |
| `-Labels`      | `-Labels`             | not yet supported       |
| `-Since`       | `-Since`              | `-CreatedAfter`         |
| `-Sort`        | `-Sort`               | not yet supported       |
| `-Direction`   | `-Direction`           | not yet supported       |
| `-MaxPages`    | `-MaxPages`           | `-MaxPages`             |
| `-All`         | `-All`                | `-All`                  |

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
| `-TargetBranch`  | `-Base`                 | not yet supported       |
| `-Author`        | not yet supported       | `-Username`             |
| `-IsDraft`       | not yet supported       | `-IsDraft`              |
| `-Since`         | not yet supported       | `-CreatedAfter`         |
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

## Get-Group

| Common Param   | Github                | Gitlab                  |
|----------------|-----------------------|-------------------------|
| `-Name`        | `-Name`               | `-GroupId`              |
| `-Mine`        | `-Mine`               | not directly supported  |
| `-MaxPages`    | `-MaxPages`           | `-MaxPages`             |
| `-All`         | `-All`                | `-All`                  |

## Adding Support

When a cell says "not supported", the forge command will emit a
warning at runtime. To fix it, add the mapping in the provider's
`switch` block in [Forge.psm1](src/ForgeCli/Forge.psm1) and update
this table.
