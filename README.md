# pwsh-forge

Unified PowerShell interface for GitHub, GitLab, and other ["forges"](https://en.wikipedia.org/wiki/Forge_(software))

Use the same commands regardless of which platform hosts your code.
ForgeCli detects your git remote and routes to the right provider.

## How It Works

ForgeCli is a thin dispatch layer.  It doesn't talk to any API directly.
Instead, provider modules (`GitHubCli`, `GitlabCli`) do the real work.
`ForgeCli` just proxies cmdlets

```
You run:     Get-Issue
ForgeCli:    reads git remote → github.com → routes to GitHubCli
GitHubCli:   calls GitHub API → returns issues
```

## Installation

```powershell
# Install the forge (dispatch layer) and one or more providers
Install-Module ForgeCli
Install-Module GitHubCli    # for GitHub
Install-Module GitlabCli    # for GitLab
```

### Profile Setup

Add to your `$PROFILE`

```powershell
Import-Module GitHubCli    # if you use GitHub
Import-Module GitlabCli    # if you use GitLab
Import-Module ForgeCli     # unified interface (can go anywhere in the list)
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

**No providers installed:**
```
No forge providers are registered.
Install and import a provider module, then re-import ForgeCli.
  GitHub: Install-Module GitHubCli
  GitLab: Install-Module GitlabCli
```

**Wrong provider for the current repo:**
```
This is a GitHub repository, but the GitHub provider is not loaded.
  Install-Module GitHubCli
  Import-Module GitHubCli
```

**Unrecognized forge:**
```
Unrecognized forge host: 'bitbucket.org'
Currently supported: GitHub, GitLab
Request support: https://github.com/chris-peterson/pwsh-forge/issues
```

## Terminology

See [TERMINOLOGY.md](TERMINOLOGY.md) for the cross-platform term mappings
and rationale (e.g., why "ChangeRequest" instead of "PullRequest" or "MergeRequest").

## Ecosystem

| Module | Purpose |
|--------|---------|
| **pwsh-forge** | Unified dispatch layer (this module) |
| [pwsh-github](https://github.com/chris-peterson/pwsh-github) | GitHub provider |
| [pwsh-gitlab](https://github.com/chris-peterson/pwsh-gitlab) | GitLab provider |
