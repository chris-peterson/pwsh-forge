# Provider registry.
# Both GithubCli and GitlabCli are required modules (see ForgeCli.psd1),
# so they are guaranteed to be loaded when this runs.

$global:ForgeProviders = @{
    'github' = @{
        Name         = 'Github'
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
    }
    'gitlab' = @{
        Name         = 'Gitlab'
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
    }
}
