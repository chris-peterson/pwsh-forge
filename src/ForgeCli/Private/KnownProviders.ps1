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
            'Close-Issue'         = 'Close-GithubIssue'
            'Get-Branch'          = 'Get-GithubBranch'
            'Get-ChangeRequest'   = 'Get-GithubPullRequest'
            'Get-Commit'          = 'Get-GithubCommit'
            'Get-Group'           = 'Get-GithubOrganization'
            'Get-Issue'           = 'Get-GithubIssue'
            'Get-Release'         = 'Get-GithubRelease'
            'Get-Repo'            = 'Get-GithubRepository'
            'Get-User'            = 'Get-GithubUser'
            'Merge-ChangeRequest' = 'Merge-GithubPullRequest'
            'New-ChangeRequest'   = 'New-GithubPullRequest'
            'New-Issue'           = 'New-GithubIssue'
            'New-Repo'            = 'New-GithubRepository'
            'Search-Repo'         = 'Search-GithubRepository'
            'Update-Issue'        = 'Update-GithubIssue'
        }
        InstallHint  = 'Install-Module GithubCli  # https://github.com/chris-peterson/pwsh-github'
    }
    'gitlab' = @{
        Name         = 'Gitlab'
        ModuleName   = 'GitlabCli'
        HostPatterns = @('gitlab')
        Commands     = @{
            'Close-Issue'         = 'Close-GitlabIssue'
            'Get-Branch'          = 'Get-GitlabBranch'
            'Get-ChangeRequest'   = 'Get-GitlabMergeRequest'
            'Get-Commit'          = 'Get-GitlabCommit'
            'Get-Group'           = 'Get-GitlabGroup'
            'Get-Issue'           = 'Get-GitlabIssue'
            'Get-Release'         = 'Get-GitlabRelease'
            'Get-Repo'            = 'Get-GitlabProject'
            'Get-User'            = 'Get-GitlabUser'
            'Merge-ChangeRequest' = 'Merge-GitlabMergeRequest'
            'New-ChangeRequest'   = 'New-GitlabMergeRequest'
            'New-Issue'           = 'New-GitlabIssue'
            'New-Repo'            = 'New-GitlabProject'
            'Search-Repo'         = 'Search-GitlabProject'
            'Update-Issue'        = 'Update-GitlabIssue'
        }
        InstallHint  = 'Install-Module GitlabCli  # https://github.com/chris-peterson/pwsh-gitlab'
    }
}

# Live registry -- populated by providers calling Register-ForgeProvider,
# or by Find-ForgeProviders discovering loaded modules
$global:ForgeProviders = @{}
