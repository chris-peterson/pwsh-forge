# Static catalog of known forge providers.
# Serves two purposes:
#   1. Helpful error messages even when a provider module isn't installed
#   2. Auto-discovery: if a provider module is loaded but hasn't registered
#      (e.g. it was imported before ForgeCli), forge can register it on demand
#
# This is NOT the live registry -- see $global:ForgeProviders for that.

$global:ForgeKnownProviders = @{
    'github' = @{
        Name         = 'Github'
        ModuleName   = 'GithubCli'
        HostPatterns = @('github')
        Commands     = @{
            'Get-Branch'        = 'Get-GithubBranch'
            'Get-ChangeRequest' = 'Get-GithubPullRequest'
            'Get-Group'         = 'Get-GithubOrganization'
            'Get-Issue'         = 'Get-GithubIssue'
            'Get-Release'       = 'Get-GithubRelease'
            'Get-Repo'          = 'Get-GithubRepository'
            'Get-User'          = 'Get-GithubUser'
        }
        InstallHint  = 'Install-Module GithubCli  # https://github.com/chris-peterson/pwsh-github'
    }
    'gitlab' = @{
        Name         = 'Gitlab'
        ModuleName   = 'GitlabCli'
        HostPatterns = @('gitlab')
        Commands     = @{
            'Get-Branch'        = 'Get-GitlabBranch'
            'Get-ChangeRequest' = 'Get-GitlabMergeRequest'
            'Get-Group'         = 'Get-GitlabGroup'
            'Get-Issue'         = 'Get-GitlabIssue'
            'Get-Release'       = 'Get-GitlabRelease'
            'Get-Repo'          = 'Get-GitlabProject'
            'Get-User'          = 'Get-GitlabUser'
        }
        InstallHint  = 'Install-Module GitlabCli  # https://github.com/chris-peterson/pwsh-gitlab'
    }
}

# Live registry -- populated by providers calling Register-ForgeProvider,
# or by Find-ForgeProviders discovering loaded modules
$global:ForgeProviders = @{}
