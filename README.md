# pwsh-forge

Unified PowerShell interface for GitHub, GitLab, and other ["forges"](https://en.wikipedia.org/wiki/Forge_(software))

Use the same commands regardless of which platform hosts your code.
ForgeCli detects your git remote and routes to the right provider.

## How It Works

ForgeCli is a thin dispatch layer.  It doesn't talk to any API directly.
Instead, provider modules (GithubCli, GitlabCli) do the real work.
ForgeCli maps each unified command to the provider-specific equivalent
using a [noun mapping](TERMINOLOGY.md#noun-mapping) (`Repo` → `Repository` / `Project`, etc.)
and auto-detects the provider from your git remote.

```
You run:     Get-Repo
ForgeCli:    reads git remote → github.com → Get-GithubRepository
GithubCli:   calls Github API → returns repo info
```

## Installation

```powershell
# Install the forge (dispatch layer) and one or more providers
Install-Module ForgeCli
Install-Module GithubCli    # for GitHub
Install-Module GitlabCli    # for GitLab
```

### Profile Setup

Add to your `$PROFILE`

```powershell
Import-Module ForgeCli     # auto-imports installed providers (GithubCli, GitlabCli)
```

## Usage

```powershell
# cd into any git repo and use unified commands
cd ~/src/my-github-project
Get-Issue                    # lists GitHub issues
Get-ChangeRequest            # lists GitHub pull requests
Get-Repo                     # shows repo info

cd ~/src/my-gitlab-project
Get-Issue                    # lists GitLab issues
Get-ChangeRequest            # lists GitLab merge requests
Get-Repo                     # shows project info
```

### Common Parameters

```powershell
# Get a specific item by ID
Get-Issue 42
Get-ChangeRequest 123

# Filter by state
Get-Issue -State closed
Get-ChangeRequest -State all

# Your items across repos
Get-Issue -Mine
Get-ChangeRequest -Mine

# Bypass auto-detection
Get-Issue -Provider github
Get-ChangeRequest -Provider gitlab
```

## Error Messages

**Not in a git repo:**

```text
Could not detect a forge provider from the current directory.
Either cd into a git repository, or specify a provider:
  Get-Issue -Provider github
  Get-Issue -Provider gitlab
```

**Unrecognized forge:**

```text
Unrecognized forge host: 'bitbucket.org'
Currently supported: github, gitlab
```

## Terminology

See [TERMINOLOGY.md](TERMINOLOGY.md) for the cross-platform term mappings
and rationale (e.g., why "ChangeRequest" instead of "PullRequest" or "MergeRequest").

## Ecosystem

| Module | Purpose |
|--------|---------|
| **pwsh-forge** | :arrow_left: this module |
| [pwsh-github](https://github.com/chris-peterson/pwsh-github) | GitHub provider |
| [pwsh-gitlab](https://github.com/chris-peterson/pwsh-gitlab) | GitLab provider |
