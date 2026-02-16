# Static catalog of known forge providers.
# Serves two purposes:
#   1. Helpful error messages even when a provider module isn't installed
#   2. Auto-discovery: if a provider module is loaded but hasn't registered
#      (e.g. it was imported before ForgeCli), forge can register it on demand
#
# This is NOT the live registry -- see $global:ForgeProviders for that.

$global:ForgeKnownProviders = @{
    'github' = @{
        Name         = 'GitHub'
        ModuleName   = 'GitHubCli'
        HostPatterns = @('github')
        Commands     = @{
            'Get-Issue'         = 'Get-GitHubIssue'
            'Get-ChangeRequest' = 'Get-GitHubPullRequest'
            'Get-Repo'          = 'Get-GitHubRepository'
        }
        InstallHint  = 'Install-Module GitHubCli  # https://github.com/chris-peterson/pwsh-github'
    }
    'gitlab' = @{
        Name         = 'GitLab'
        ModuleName   = 'GitlabCli'
        HostPatterns = @('gitlab')
        Commands     = @{
            'Get-Issue'         = 'Get-GitlabIssue'
            'Get-ChangeRequest' = 'Get-GitlabMergeRequest'
            'Get-Repo'          = 'Get-GitlabProject'
        }
        InstallHint  = 'Install-Module GitlabCli  # https://github.com/chris-peterson/pwsh-gitlab'
    }
}

# Live registry -- populated by providers calling Register-ForgeProvider,
# or by Find-ForgeProviders discovering loaded modules
$global:ForgeProviders = @{}
