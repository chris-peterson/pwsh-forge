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

Each section is generated from a schema in [`src/ForgeCli/Schemas`](src/ForgeCli/Schemas). Edit the schema, then paste the section the contract test prints.

### Branch

A named line of commits in a repo.

| Field          | Type    | Description                                                                                                                                     | Github                                    | Gitlab                               |
|----------------|---------|-------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------------------------|--------------------------------------|
| `forge`        | forge   | Provider that answered the request.                                                                                                             | `github`                                  | `gitlab`                             |
| `host`         | string  | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url`                        | host of `web_url`                    |
| `project_path` | string  | Full path of the repo the record belongs to: `owner/repo` on GitHub, `group/subgroup/project` on GitLab.                                        | `full_name` of the repo                   | `path_with_namespace` of the project |
| `name`         | string  | Name of the branch, without `refs/heads/`.                                                                                                      | `name`                                    | `name`                               |
| `url`          | string  | Web URL of the branch's tree.                                                                                                                   | repo `html_url` + `/tree/{name}`          | `web_url`                            |
| `commit_sha`   | string  | Full SHA of the commit the branch points to.                                                                                                    | `commit.sha`                              | `commit.id`                          |
| `protected`    | boolean | Whether branch protection rules apply to the branch.                                                                                            | `protected`                               | `protected`                          |
| `default`      | boolean | Whether this is the repo's default branch.                                                                                                      | `name` equals the repo's `default_branch` | `default`                            |

### ChangeRequest

A request to review and merge a set of changes: a GitHub pull request or a GitLab merge request.

| Field             | Type              | Description                                                                                                                                                                           | Github                                       | Gitlab                                       |
|-------------------|-------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------|----------------------------------------------|
| `forge`           | forge             | Provider that answered the request.                                                                                                                                                   | `github`                                     | `gitlab`                                     |
| `host`            | string            | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from.                                       | host of `html_url`                           | host of `web_url`                            |
| `project_path`    | string            | Full path of the repo the record belongs to: `owner/repo` on GitHub, `group/subgroup/project` on GitLab.                                                                              | `base.repo.full_name`                        | `references.full`, without the `!iid` suffix |
| `id`              | integer           | Number of the change request within its repo, as shown in the forge UI (`#17`, `!46`). Not the forge's global database id.                                                            | `number`                                     | `iid`                                        |
| `url`             | string            | Web URL of the change request. The natural key for a record across forges.                                                                                                            | `html_url`                                   | `web_url`                                    |
| `title`           | string            | Title of the change request.                                                                                                                                                          | `title`                                      | `title`                                      |
| `description`     | string \| null    | Markdown body of the change request. `null` when the author left it empty.                                                                                                            | `body`                                       | `description`                                |
| `state`           | string            | Where the change request is in its lifecycle. A draft is still `open`; see `draft`.                                                                                                   | `state`, or `merged` when `merged_at` is set | `state`, with `opened` as `open`             |
| `draft`           | boolean           | Whether the author marked the change request as not ready for review.                                                                                                                 | `draft`                                      | `draft`                                      |
| `author_username` | string            | Username of the author.                                                                                                                                                               | `user.login`                                 | `author.username`                            |
| `author_name`     | string            | Display name of the author, or the username when the account has no display name.                                                                                                     | `name` of `users/{user.login}`               | `author.name`                                |
| `source_branch`   | string            | Branch that holds the changes.                                                                                                                                                        | `head.ref`                                   | `source_branch`                              |
| `target_branch`   | string            | Branch the changes merge into.                                                                                                                                                        | `base.ref`                                   | `target_branch`                              |
| `created_at`      | timestamp         | When the change request was opened.                                                                                                                                                   | `created_at`                                 | `created_at`                                 |
| `updated_at`      | timestamp         | When the change request last changed, including comments and pushes.                                                                                                                  | `updated_at`                                 | `updated_at`                                 |
| `merged_at`       | timestamp \| null | When the change request merged. `null` when it hasn't merged, and also on a merged change request whose forge recorded no merge time (GitLab returns some older merged MRs this way). | `merged_at`                                  | `merged_at`                                  |

#### `state` values

| Value    | Description                                         |
|----------|-----------------------------------------------------|
| `open`   | Accepting changes and review; not merged or closed. |
| `merged` | The changes landed on the target branch.            |
| `closed` | Closed without merging.                             |

### ChangeRequestApproval

One reviewer's current approval of a change request: a record per approver, not per change request. A withdrawn or superseded approval is not a record.

| Field               | Type              | Description                                                                                                                                     | Github                         | Gitlab                               |
|---------------------|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|--------------------------------------|
| `forge`             | forge             | Provider that answered the request.                                                                                                             | `github`                       | `gitlab`                             |
| `host`              | string            | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url`             | host of `web_url`                    |
| `project_path`      | string            | Full path of the repo the record belongs to: `owner/repo` on GitHub, `group/subgroup/project` on GitLab.                                        | `full_name` of the repo        | `path_with_namespace` of the project |
| `change_request_id` | integer           | Number of the approved change request, as in the change request record's `id`.                                                                  | number in `pull_request_url`   | `iid`                                |
| `approver_username` | string            | Username of the approver.                                                                                                                       | `user.login`                   | `approved_by[].user.username`        |
| `approver_name`     | string            | Display name of the approver, or the username when the account has no display name.                                                             | `name` of `users/{user.login}` | `approved_by[].user.name`            |
| `approved_at`       | timestamp \| null | When the approval was given. `null` when the forge reports no time for it.                                                                      | `submitted_at`                 | `approved_by[].approved_at`          |

### ChangeRequestComment

A comment on a change request: a conversation comment, or an inline comment on a line of the diff. Both kinds are change request comments.

| Field               | Type            | Description                                                                                                                                                                                               | Github                                            | Gitlab                                 |
|---------------------|-----------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------|----------------------------------------|
| `forge`             | forge           | Provider that answered the request.                                                                                                                                                                       | `github`                                          | `gitlab`                               |
| `host`              | string          | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from.                                                           | host of `html_url`                                | host of `web_url`                      |
| `project_path`      | string          | Full path of the repo the record belongs to: `owner/repo` on GitHub, `group/subgroup/project` on GitLab.                                                                                                  | `full_name` of the repo                           | `path_with_namespace` of the project   |
| `change_request_id` | integer         | Number of the change request the comment is on, as in the change request record's `id`.                                                                                                                   | last segment of `issue_url` or `pull_request_url` | `noteable_iid`                         |
| `id`                | integer         | Id of the comment; the one its web URL anchors to.                                                                                                                                                        | `id`                                              | `id`                                   |
| `url`               | string          | Web URL of the comment.                                                                                                                                                                                   | `html_url`                                        | merge request `web_url` + `#note_{id}` |
| `body`              | string          | Markdown body of the comment.                                                                                                                                                                             | `body`                                            | `body`                                 |
| `author_username`   | string          | Username of the comment's author.                                                                                                                                                                         | `user.login`                                      | `author.username`                      |
| `author_name`       | string          | Display name of the comment's author, or the username when the account has no display name.                                                                                                               | `name` of `users/{user.login}`                    | `author.name`                          |
| `file_path`         | string \| null  | Path of the file an inline comment is on. `null` for a conversation comment.                                                                                                                              | `path` (review comments)                          | `position.new_path`                    |
| `line`              | integer \| null | Line an inline comment is on, in the new version of the file; the last line of a multi-line comment. `null` for a conversation comment, or a comment on a removed line.                                   | `line` when `side` is `RIGHT` (review comments)   | `position.new_line`                    |
| `system`            | boolean         | Whether the forge generated the comment to record activity (a push, a status change) rather than a person writing it. GitHub's comments APIs return only written comments, so it is always `false` there. | always `false`                                    | `system`                               |
| `created_at`        | timestamp       | When the comment was posted.                                                                                                                                                                              | `created_at`                                      | `created_at`                           |
| `updated_at`        | timestamp       | When the comment was last edited, or posted if never edited.                                                                                                                                              | `updated_at`                                      | `updated_at`                           |

### Commit

A git commit in a repo.

| Field             | Type            | Description                                                                                                                                                       | Github                         | Gitlab                               |
|-------------------|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|--------------------------------------|
| `forge`           | forge           | Provider that answered the request.                                                                                                                               | `github`                       | `gitlab`                             |
| `host`            | string          | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from.                   | host of `html_url`             | host of `web_url`                    |
| `project_path`    | string          | Full path of the repo the record belongs to: `owner/repo` on GitHub, `group/subgroup/project` on GitLab.                                                          | `full_name` of the repo        | `path_with_namespace` of the project |
| `sha`             | string          | Full SHA of the commit.                                                                                                                                           | `sha`                          | `id`                                 |
| `url`             | string          | Web URL of the commit.                                                                                                                                            | `html_url`                     | `web_url`                            |
| `title`           | string          | First line of the commit message.                                                                                                                                 | first line of `commit.message` | `title`                              |
| `message`         | string          | Full commit message, including the title.                                                                                                                         | `commit.message`               | `message`                            |
| `author_name`     | string          | Author name recorded in the commit.                                                                                                                               | `commit.author.name`           | `author_name`                        |
| `author_email`    | string          | Author email recorded in the commit.                                                                                                                              | `commit.author.email`          | `author_email`                       |
| `author_username` | string \| null  | Username of the account the forge matched to the author email. `null` when no account matches, and always `null` on GitLab, whose commits API doesn't report one. | `author.login`                 | always `null`                        |
| `authored_at`     | timestamp       | When the change was originally written; kept through rebases and cherry-picks.                                                                                    | `commit.author.date`           | `authored_date`                      |
| `committed_at`    | timestamp       | When the commit was last written, by a rebase, amend, or cherry-pick as much as the first commit.                                                                 | `commit.committer.date`        | `committed_date`                     |
| `parent_shas`     | array of string | Full SHAs of the commit's parents. More than one for a merge commit.                                                                                              | `parents[].sha`                | `parent_ids`                         |

### Group

A namespace that owns repos and has members. GitLab groups can nest; GitHub organizations cannot.

| Field         | Type           | Description                                                                                                                                     | Github                          | Gitlab            |
|---------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------|-------------------|
| `forge`       | forge          | Provider that answered the request.                                                                                                             | `github`                        | `gitlab`          |
| `host`        | string         | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url`              | host of `web_url` |
| `path`        | string         | Full path of the group, as repo paths under it begin; its identity on the forge instance.                                                       | `login`                         | `full_path`       |
| `name`        | string         | Display name of the group, or its path when it has none.                                                                                        | `name`, falling back to `login` | `name`            |
| `description` | string \| null | Short description of the group. `null` when none is set.                                                                                        | `description`                   | `description`     |
| `url`         | string         | Web URL of the group.                                                                                                                           | `html_url`                      | `web_url`         |

### GroupMember

A person's membership in a group, with the role it grants.

| Field        | Type   | Description                                                                                                                                     | Github                            | Gitlab                         |
|--------------|--------|-------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------|--------------------------------|
| `forge`      | forge  | Provider that answered the request.                                                                                                             | `github`                          | `gitlab`                       |
| `host`       | string | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url`                | host of `web_url`              |
| `group_path` | string | Full path of the group, as in the group record's `path`.                                                                                        | organization `login`              | group `full_path`              |
| `username`   | string | Username of the member.                                                                                                                         | `login`                           | `username`                     |
| `name`       | string | Display name of the member, or the username when the account has no display name.                                                               | `name` of `users/{login}`         | `name`                         |
| `role`       | string | What the membership lets the person do. GitHub has two organization roles; GitLab has a ladder of access levels.                                | organization role; see the values | `access_level`; see the values |

#### `role` values

| Value            | Description                                                       | Github   | Gitlab            |
|------------------|-------------------------------------------------------------------|----------|-------------------|
| `owner`          | Full control of the group, including its settings and membership. | `admin`  | `access_level` 50 |
| `maintainer`     | Manages repos in the group, short of group settings.              | none     | `access_level` 40 |
| `developer`      | Pushes code and works on issues and change requests.              | none     | `access_level` 30 |
| `reporter`       | Reads code and works on issues.                                   | none     | `access_level` 20 |
| `planner`        | Plans and tracks work in issues and epics.                        | none     | `access_level` 15 |
| `guest`          | Views and comments on issues.                                     | none     | `access_level` 10 |
| `minimal_access` | Belongs to the group without access to its content.               | none     | `access_level` 5  |
| `member`         | A GitHub organization member who isn't an owner.                  | `member` | none              |

### Issue

A tracked unit of work or report in a repo. Never a change request: GitHub's issues API also returns pull requests, and they are not issue records.

| Field                | Type              | Description                                                                                                                                     | Github                          | Gitlab                                       |
|----------------------|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------|----------------------------------------------|
| `forge`              | forge             | Provider that answered the request.                                                                                                             | `github`                        | `gitlab`                                     |
| `host`               | string            | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url`              | host of `web_url`                            |
| `project_path`       | string            | Full path of the repo the record belongs to: `owner/repo` on GitHub, `group/subgroup/project` on GitLab.                                        | `full_name` of `repository_url` | `references.full`, without the `#iid` suffix |
| `id`                 | integer           | Number of the issue within its repo, as shown in the forge UI (`#42`). Not the forge's global database id.                                      | `number`                        | `iid`                                        |
| `url`                | string            | Web URL of the issue. The natural key for a record across forges.                                                                               | `html_url`                      | `web_url`                                    |
| `title`              | string            | Title of the issue.                                                                                                                             | `title`                         | `title`                                      |
| `description`        | string \| null    | Markdown body of the issue. `null` when the author left it empty.                                                                               | `body`                          | `description`                                |
| `state`              | string            | Whether the issue is still open.                                                                                                                | `state`                         | `state`, with `opened` as `open`             |
| `author_username`    | string            | Username of the person who opened the issue.                                                                                                    | `user.login`                    | `author.username`                            |
| `author_name`        | string            | Display name of the person who opened the issue, or the username when the account has no display name.                                          | `name` of `users/{user.login}`  | `author.name`                                |
| `assignee_usernames` | array of string   | Usernames of everyone assigned to the issue. Empty when nobody is.                                                                              | `assignees[].login`             | `assignees[].username`                       |
| `labels`             | array of string   | Names of the labels on the issue.                                                                                                               | `labels[].name`                 | `labels[]`                                   |
| `milestone_title`    | string \| null    | Title of the milestone the issue belongs to. `null` when it has none.                                                                           | `milestone.title`               | `milestone.title`                            |
| `milestone_due_date` | date \| null      | Due date of the issue's milestone. `null` when it has no milestone, or the milestone has no due date.                                           | date part of `milestone.due_on` | `milestone.due_date`                         |
| `due_date`           | date \| null      | Due date set on the issue itself. GitHub issues have no due date, so it is always `null` there.                                                 | always `null`                   | `due_date`                                   |
| `comment_count`      | integer           | Number of comments people have written on the issue.                                                                                            | `comments`                      | `user_notes_count`                           |
| `created_at`         | timestamp         | When the issue was opened.                                                                                                                      | `created_at`                    | `created_at`                                 |
| `updated_at`         | timestamp         | When the issue last changed, including comments.                                                                                                | `updated_at`                    | `updated_at`                                 |
| `closed_at`          | timestamp \| null | When the issue was closed. `null` when the forge reports no close time, as for an issue that was never closed.                                  | `closed_at`                     | `closed_at`                                  |

#### `state` values

| Value    | Description                                 |
|----------|---------------------------------------------|
| `open`   | Not yet resolved.                           |
| `closed` | Resolved, whether completed or not planned. |

### IssueComment

A comment on an issue.

| Field             | Type      | Description                                                                                                                                                                                                         | Github                         | Gitlab                               |
|-------------------|-----------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--------------------------------|--------------------------------------|
| `forge`           | forge     | Provider that answered the request.                                                                                                                                                                                 | `github`                       | `gitlab`                             |
| `host`            | string    | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from.                                                                     | host of `html_url`             | host of `web_url`                    |
| `project_path`    | string    | Full path of the repo the record belongs to: `owner/repo` on GitHub, `group/subgroup/project` on GitLab.                                                                                                            | `full_name` of the repo        | `path_with_namespace` of the project |
| `issue_id`        | integer   | Number of the issue the comment is on, as in the issue record's `id`.                                                                                                                                               | last segment of `issue_url`    | `noteable_iid`                       |
| `id`              | integer   | Id of the comment; the one its web URL anchors to.                                                                                                                                                                  | `id`                           | `id`                                 |
| `url`             | string    | Web URL of the comment.                                                                                                                                                                                             | `html_url`                     | issue `web_url` + `#note_{id}`       |
| `body`            | string    | Markdown body of the comment.                                                                                                                                                                                       | `body`                         | `body`                               |
| `author_username` | string    | Username of the comment's author.                                                                                                                                                                                   | `user.login`                   | `author.username`                    |
| `author_name`     | string    | Display name of the comment's author, or the username when the account has no display name.                                                                                                                         | `name` of `users/{user.login}` | `author.name`                        |
| `system`          | boolean   | Whether the forge generated the comment to record activity (a label change, a cross-reference) rather than a person writing it. GitHub's comments API returns only written comments, so it is always `false` there. | always `false`                 | `system`                             |
| `created_at`      | timestamp | When the comment was posted.                                                                                                                                                                                        | `created_at`                   | `created_at`                         |
| `updated_at`      | timestamp | When the comment was last edited, or posted if never edited.                                                                                                                                                        | `updated_at`                   | `updated_at`                         |

### Label

A named, colored tag that can be applied to issues and change requests in a repo.

| Field          | Type           | Description                                                                                                                                     | Github                  | Gitlab                               |
|----------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------|--------------------------------------|
| `forge`        | forge          | Provider that answered the request.                                                                                                             | `github`                | `gitlab`                             |
| `host`         | string         | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url`      | host of `web_url`                    |
| `project_path` | string         | Full path of the repo the label was listed for. On GitLab that includes labels inherited from its groups.                                       | `full_name` of the repo | `path_with_namespace` of the project |
| `name`         | string         | Name of the label; its identity within the repo.                                                                                                | `name`                  | `name`                               |
| `color`        | string         | Background color of the label, as `#rrggbb` in lowercase.                                                                                       | `#` + `color`           | `color`, lowercased                  |
| `description`  | string \| null | What the label means. `null` when none is set.                                                                                                  | `description`           | `description`                        |

### Milestone

A target that groups issues and change requests, usually toward a date or a release.

| Field          | Type           | Description                                                                                                                                     | Github                  | Gitlab                               |
|----------------|----------------|-------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------|--------------------------------------|
| `forge`        | forge          | Provider that answered the request.                                                                                                             | `github`                | `gitlab`                             |
| `host`         | string         | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url`      | host of `web_url`                    |
| `project_path` | string         | Full path of the repo the milestone was listed for.                                                                                             | `full_name` of the repo | `path_with_namespace` of the project |
| `id`           | integer        | Number of the milestone within its repo or group, as the forge's milestone URL shows it.                                                        | `number`                | `iid`                                |
| `url`          | string         | Web URL of the milestone.                                                                                                                       | `html_url`              | `web_url`                            |
| `title`        | string         | Title of the milestone.                                                                                                                         | `title`                 | `title`                              |
| `description`  | string \| null | Markdown description of the milestone. `null` when none is set.                                                                                 | `description`           | `description`                        |
| `state`        | string         | Whether the milestone is still in use.                                                                                                          | `state`                 | `state`, with `active` as `open`     |
| `start_date`   | date \| null   | When work toward the milestone starts. GitHub milestones have no start date, so it is always `null` there.                                      | always `null`           | `start_date`                         |
| `due_date`     | date \| null   | When the milestone is due. `null` when no due date is set.                                                                                      | date part of `due_on`   | `due_date`                           |
| `created_at`   | timestamp      | When the milestone was created.                                                                                                                 | `created_at`            | `created_at`                         |
| `updated_at`   | timestamp      | When the milestone last changed.                                                                                                                | `updated_at`            | `updated_at`                         |

#### `state` values

| Value    | Description            |
|----------|------------------------|
| `open`   | Accepting work.        |
| `closed` | Finished or abandoned. |

### Release

A published version of a repo, tied to a git tag.

| Field             | Type              | Description                                                                                                                                     | Github                  | Gitlab                               |
|-------------------|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------|--------------------------------------|
| `forge`           | forge             | Provider that answered the request.                                                                                                             | `github`                | `gitlab`                             |
| `host`            | string            | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url`      | host of `web_url`                    |
| `project_path`    | string            | Full path of the repo the record belongs to: `owner/repo` on GitHub, `group/subgroup/project` on GitLab.                                        | `full_name` of the repo | `path_with_namespace` of the project |
| `tag_name`        | string            | Name of the git tag the release is built from; its identity within the repo.                                                                    | `tag_name`              | `tag_name`                           |
| `name`            | string \| null    | Title of the release. `null` when none is set.                                                                                                  | `name`                  | `name`                               |
| `url`             | string            | Web URL of the release.                                                                                                                         | `html_url`              | `_links.self`                        |
| `description`     | string \| null    | Markdown release notes. `null` when none were written.                                                                                          | `body`                  | `description`                        |
| `author_username` | string            | Username of the person who created the release.                                                                                                 | `author.login`          | `author.username`                    |
| `draft`           | boolean           | Whether the release is an unpublished draft. GitLab has no draft releases, so it is always `false` there.                                       | `draft`                 | always `false`                       |
| `prerelease`      | boolean \| null   | Whether the release is marked as not production-ready. `null` on GitLab, which has no such flag.                                                | `prerelease`            | always `null`                        |
| `created_at`      | timestamp         | When the release record was created.                                                                                                            | `created_at`            | `created_at`                         |
| `released_at`     | timestamp \| null | When the release was published. `null` for a draft. A GitLab release can carry a future date, for an upcoming release.                          | `published_at`          | `released_at`                        |

### Repo

The code container that owns branches, change requests, and issues.

| Field              | Type           | Description                                                                                                                                      | Github             | Gitlab                           |
|--------------------|----------------|--------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|----------------------------------|
| `forge`            | forge          | Provider that answered the request.                                                                                                              | `github`           | `gitlab`                         |
| `host`             | string         | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from.  | host of `html_url` | host of `web_url`                |
| `project_path`     | string         | Full path of the repo, and its identity on the forge instance.                                                                                   | `full_name`        | `path_with_namespace`            |
| `name`             | string         | Last segment of `project_path`, as it appears in the repo's URL.                                                                                 | `name`             | `path`                           |
| `owner`            | string         | Path of the user or group that owns the repo; `project_path` without its last segment.                                                           | `owner.login`      | `namespace.full_path`            |
| `description`      | string \| null | Short description of the repo. `null` when none is set.                                                                                          | `description`      | `description`                    |
| `url`              | string         | Web URL of the repo.                                                                                                                             | `html_url`         | `web_url`                        |
| `default_branch`   | string \| null | Branch the forge treats as the repo's main line. `null` for an empty repo.                                                                       | `default_branch`   | `default_branch`                 |
| `visibility`       | string         | Who can see the repo.                                                                                                                            | `visibility`       | `visibility`                     |
| `archived`         | boolean        | Whether the repo is read-only because it was archived.                                                                                           | `archived`         | `archived`                       |
| `fork`             | boolean        | Whether the repo was created as a fork of another repo.                                                                                          | `fork`             | `forked_from_project` is present |
| `created_at`       | timestamp      | When the repo was created.                                                                                                                       | `created_at`       | `created_at`                     |
| `last_activity_at` | timestamp      | Most recent activity the forge records for the repo. GitHub counts pushes only; GitLab counts any activity, including issues and merge requests. | `pushed_at`        | `last_activity_at`               |

#### `visibility` values

| Value      | Description                                               |
|------------|-----------------------------------------------------------|
| `public`   | Anyone, including people who aren't signed in.            |
| `internal` | Any signed-in member of the forge instance or enterprise. |
| `private`  | Only people granted access.                               |

### User

An account on a forge instance.

| Field        | Type              | Description                                                                                                                                     | Github             | Gitlab            |
|--------------|-------------------|-------------------------------------------------------------------------------------------------------------------------------------------------|--------------------|-------------------|
| `forge`      | forge             | Provider that answered the request.                                                                                                             | `github`           | `gitlab`          |
| `host`       | string            | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url` | host of `web_url` |
| `username`   | string            | Username of the account; its identity on the forge instance.                                                                                    | `login`            | `username`        |
| `name`       | string \| null    | Display name of the account. `null` when none is set.                                                                                           | `name`             | `name`            |
| `url`        | string            | Web URL of the account's profile.                                                                                                               | `html_url`         | `web_url`         |
| `bot`        | boolean           | Whether the account is an automation account rather than a person.                                                                              | `type` is `Bot`    | `bot`             |
| `created_at` | timestamp \| null | When the account was created. `null` when the forge doesn't disclose it to the caller.                                                          | `created_at`       | `created_at`      |

### UserActivity

One thing a user did on the forge, from its activity feed: a push, opening or merging a change request, a comment. The forge's own event types map onto `action` and `target_type`.

| Field            | Type            | Description                                                                                                                                     | Github                                                  | Gitlab                                                      |
|------------------|-----------------|-------------------------------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------|-------------------------------------------------------------|
| `forge`          | forge           | Provider that answered the request.                                                                                                             | `github`                                                | `gitlab`                                                    |
| `host`           | string          | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url`                                      | host of `web_url`                                           |
| `id`             | integer         | Id of the event on the forge instance.                                                                                                          | `id`, as a number                                       | `id`                                                        |
| `created_at`     | timestamp       | When the activity happened.                                                                                                                     | `created_at`                                            | `created_at`                                                |
| `actor_username` | string          | Username of the person who acted.                                                                                                               | `actor.login`                                           | `author_username`                                           |
| `project_path`   | string \| null  | Full path of the repo the activity happened in. `null` for activity outside any repo.                                                           | `repo.name`                                             | `path_with_namespace` of `project_id`                       |
| `action`         | string          | What the actor did.                                                                                                                             | from `type` and `payload.action`; see the values        | from `action_name`; see the values                          |
| `target_type`    | string          | Kind of thing the activity was on. `null` when the forge names none.                                                                            | from `type` and `payload.ref_type`; see the values      | from `target_type` and `push_data.ref_type`; see the values |
| `target_id`      | integer \| null | Number of the change request or issue the activity was on; for a comment, the one commented on. `null` for any other target.                    | `payload.pull_request.number` or `payload.issue.number` | `target_iid`, or `note.noteable_iid` for a comment          |
| `target_title`   | string \| null  | Title of the change request or issue the activity was on. `null` for any other target.                                                          | `payload.pull_request.title` or `payload.issue.title`   | `target_title`                                              |
| `ref`            | string \| null  | Branch or tag a push, create, or delete acted on, without `refs/heads/` or `refs/tags/`. `null` otherwise.                                      | `payload.ref`                                           | `push_data.ref`                                             |
| `commit_sha`     | string \| null  | Full SHA of the newest commit a push delivered. `null` for anything but a push.                                                                 | `payload.head`                                          | `push_data.commit_to`                                       |
| `commit_title`   | string \| null  | First line of the message of `commit_sha`. `null` for anything but a push.                                                                      | `title` of `commits/{payload.head}`                     | `push_data.commit_title`                                    |
| `commit_count`   | integer \| null | Number of commits a push delivered. `null` for anything but a push, and always on GitHub, whose events API doesn't report it.                   | always `null`                                           | `push_data.commit_count`                                    |

#### `action` values

| Value       | Description                                                            | Github                                                                                        | Gitlab                    |
|-------------|------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|---------------------------|
| `pushed`    | Pushed commits to a branch or tag.                                     | `PushEvent`                                                                                   | `pushed to`, `pushed new` |
| `created`   | Created a branch, tag, or repo.                                        | `CreateEvent`                                                                                 | `created`                 |
| `deleted`   | Deleted a branch, tag, or repo.                                        | `DeleteEvent`                                                                                 | `deleted`                 |
| `opened`    | Opened a change request or issue.                                      | `PullRequestEvent`, `IssuesEvent` with `payload.action` `opened`                              | `opened`                  |
| `closed`    | Closed a change request without merging it, or closed an issue.        | `PullRequestEvent` with `payload.action` `closed` and not merged; `IssuesEvent` with `closed` | `closed`                  |
| `reopened`  | Reopened a change request or issue.                                    | `PullRequestEvent`, `IssuesEvent` with `payload.action` `reopened`                            | `reopened`                |
| `merged`    | Merged a change request.                                               | `PullRequestEvent` with `payload.action` `closed` and `payload.pull_request.merged`           | `accepted`                |
| `approved`  | Approved a change request.                                             | `PullRequestReviewEvent` with `payload.review.state` `approved`                               | `approved`                |
| `reviewed`  | Submitted a review that didn't approve.                                | `PullRequestReviewEvent` in any other state                                                   | none                      |
| `commented` | Commented on a change request, issue, or commit.                       | `IssueCommentEvent`, `PullRequestReviewCommentEvent`, `CommitCommentEvent`                    | `commented on`            |
| `released`  | Published a release.                                                   | `ReleaseEvent`                                                                                | none                      |
| `forked`    | Forked a repo.                                                         | `ForkEvent`                                                                                   | none                      |
| `starred`   | Starred a repo.                                                        | `WatchEvent`                                                                                  | none                      |
| `joined`    | Joined a repo or group.                                                | `MemberEvent`                                                                                 | `joined`                  |
| `left`      | Left a repo or group.                                                  | none                                                                                          | `left`                    |
| `other`     | Anything the other values don't describe, such as editing a wiki page. | any other `type`                                                                              | any other `action_name`   |

#### `target_type` values

| Value            | Description                                  | Github                                                                                       | Gitlab                                          |
|------------------|----------------------------------------------|----------------------------------------------------------------------------------------------|-------------------------------------------------|
| `change_request` | A change request.                            | `PullRequestEvent`, `PullRequestReviewEvent`                                                 | `MergeRequest`                                  |
| `issue`          | An issue.                                    | `IssuesEvent`                                                                                | `Issue`, `WorkItem`                             |
| `comment`        | A comment; `target_id` names what it was on. | `IssueCommentEvent`, `PullRequestReviewCommentEvent`, `CommitCommentEvent`                   | `Note`, `DiscussionNote`, `DiffNote`            |
| `branch`         | A branch.                                    | `PushEvent` to `refs/heads/`; `CreateEvent`, `DeleteEvent` with `payload.ref_type` `branch`  | no `target_type`, `push_data.ref_type` `branch` |
| `tag`            | A tag.                                       | `PushEvent` to `refs/tags/`; `CreateEvent`, `DeleteEvent` with `payload.ref_type` `tag`      | no `target_type`, `push_data.ref_type` `tag`    |
| `repo`           | A repo.                                      | `CreateEvent` with `payload.ref_type` `repository`; `ForkEvent`, `WatchEvent`, `MemberEvent` | no `target_type` or `push_data`, on a project   |
| `release`        | A release.                                   | `ReleaseEvent`                                                                               | none                                            |
| `milestone`      | A milestone.                                 | none                                                                                         | `Milestone`                                     |
| `wiki`           | A wiki page.                                 | `GollumEvent`                                                                                | `WikiPage::Meta`                                |
| `null`           | The forge names no target.                   | any other `type`                                                                             | any other `target_type`                         |

### Common definitions

Definitions every noun's schema shares. Get-ForgeSchema merges these into each schema's `$defs`, so a noun references them as `#/$defs/<name>`.

| Definition     | Type   | Description                                                                                                                                     | Github                  | Gitlab                               |
|----------------|--------|-------------------------------------------------------------------------------------------------------------------------------------------------|-------------------------|--------------------------------------|
| `forge`        | string | Provider that answered the request.                                                                                                             | `github`                | `gitlab`                             |
| `host`         | string | Hostname of the forge instance, e.g. `github.com` or `gitlab.example.com`. Together with `forge`, identifies which instance a record came from. | host of `html_url`      | host of `web_url`                    |
| `project_path` | string | Full path of the repo the record belongs to: `owner/repo` on GitHub, `group/subgroup/project` on GitLab.                                        | `full_name` of the repo | `path_with_namespace` of the project |
| `timestamp`    | string | RFC 3339 instant in UTC, to the second.                                                                                                         |                         |                                      |
| `date`         | string | Calendar date, `YYYY-MM-DD`, with no time zone.                                                                                                 |                         |                                      |
| `username`     | string | Username of an account on this forge instance. The same person can have a different username on each instance.                                  |                         |                                      |

#### `forge` values

| Value    | Description                |
|----------|----------------------------|
| `github` | GitHub, through GithubCli. |
| `gitlab` | GitLab, through GitlabCli. |

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
