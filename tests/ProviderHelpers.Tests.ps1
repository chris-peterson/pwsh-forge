BeforeAll {
    . $PSScriptRoot/../src/ForgeCli/Private/Validations.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/KnownProviders.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/ProviderHelpers.ps1
}

Describe "Get-ForgeProvider" {

    It "Should return both providers" {
        $Result = @(Get-ForgeProvider)
        $Result.Count | Should -Be 2
        $Result.Name | Should -Contain 'Github'
        $Result.Name | Should -Contain 'Gitlab'
    }
}

Describe "ForgeProviders" {

    It "Should define Github as a provider" {
        $global:ForgeProviders.ContainsKey('github') | Should -BeTrue
    }

    It "Should define Gitlab as a provider" {
        $global:ForgeProviders.ContainsKey('gitlab') | Should -BeTrue
    }

    It "Should map forge commands to provider commands" {
        $GH = $global:ForgeProviders['github'].Commands
        $GH['Close-Issue'] | Should -Be 'Close-GithubIssue'
        $GH['Get-Branch'] | Should -Be 'Get-GithubBranch'
        $GH['Get-ChangeRequest'] | Should -Be 'Get-GithubPullRequest'
        $GH['Get-Commit'] | Should -Be 'Get-GithubCommit'
        $GH['Get-Group'] | Should -Be 'Get-GithubOrganization'
        $GH['Get-Issue'] | Should -Be 'Get-GithubIssue'
        $GH['Get-Release'] | Should -Be 'Get-GithubRelease'
        $GH['Get-Repo'] | Should -Be 'Get-GithubRepository'
        $GH['Get-User'] | Should -Be 'Get-GithubUser'
        $GH['Merge-ChangeRequest'] | Should -Be 'Merge-GithubPullRequest'
        $GH['New-ChangeRequest'] | Should -Be 'New-GithubPullRequest'
        $GH['New-Issue'] | Should -Be 'New-GithubIssue'
        $GH['New-Repo'] | Should -Be 'New-GithubRepository'
        $GH['Search-Repo'] | Should -Be 'Search-GithubRepository'
        $GH['Update-Issue'] | Should -Be 'Update-GithubIssue'

        $GL = $global:ForgeProviders['gitlab'].Commands
        $GL['Close-Issue'] | Should -Be 'Close-GitlabIssue'
        $GL['Get-Branch'] | Should -Be 'Get-GitlabBranch'
        $GL['Get-ChangeRequest'] | Should -Be 'Get-GitlabMergeRequest'
        $GL['Get-Commit'] | Should -Be 'Get-GitlabCommit'
        $GL['Get-Group'] | Should -Be 'Get-GitlabGroup'
        $GL['Get-Issue'] | Should -Be 'Get-GitlabIssue'
        $GL['Get-Release'] | Should -Be 'Get-GitlabRelease'
        $GL['Get-Repo'] | Should -Be 'Get-GitlabProject'
        $GL['Get-User'] | Should -Be 'Get-GitlabUser'
        $GL['Merge-ChangeRequest'] | Should -Be 'Merge-GitlabMergeRequest'
        $GL['New-ChangeRequest'] | Should -Be 'New-GitlabMergeRequest'
        $GL['New-Issue'] | Should -Be 'New-GitlabIssue'
        $GL['New-Repo'] | Should -Be 'New-GitlabProject'
        $GL['Search-Repo'] | Should -Be 'Search-GitlabProject'
        $GL['Update-Issue'] | Should -Be 'Update-GitlabIssue'
    }
}
