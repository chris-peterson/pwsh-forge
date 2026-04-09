# <img src="favicon.svg" alt="pwsh-forge" width="64" height="64" style="vertical-align: middle"> pwsh-forge

Unified PowerShell interface for GitHub, GitLab, and other ["forges"](https://en.wikipedia.org/wiki/Forge_(software)).

Use the same commands regardless of which platform hosts your code. ForgeCli detects your git remote and routes to the right provider.

## How It Works

ForgeCli is a thin dispatch layer. It doesn't talk to any API directly. Instead, provider modules (GithubCli, GitlabCli) do the real work. ForgeCli maps each unified command to the provider-specific equivalent and auto-detects the provider from your git remote.

```text
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

Add to your `$PROFILE`:

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
Get-Issue -Forge github
Get-ChangeRequest -Forge gitlab
```

## Cmdlet Categories

Browse the sidebar to find cmdlets organized by category:

- [Branches](/Branches/) - Create, list, and delete branches
- [ChangeRequests](/ChangeRequests/) - Manage pull requests and merge requests
- [Commits](/Commits/) - View commit information
- [Groups](/Groups/) - Manage organizations and groups
- [Issues](/Issues/) - Create, update, and close issues
- [Milestones](/Milestones/) - Track milestones
- [Releases](/Releases/) - View releases
- [Repos](/Repos/) - Manage repositories and projects
- [Search](/Search/) - Search across forges
- [Users](/Users/) - User information and activity

## Ecosystem

| Module | Purpose |
|--------|---------|
| **pwsh-forge** | Unified dispatch layer |
| [pwsh-github](https://chris-peterson.github.io/pwsh-github/) | GitHub provider |
| [pwsh-gitlab](https://chris-peterson.github.io/pwsh-gitlab/) | GitLab provider |
