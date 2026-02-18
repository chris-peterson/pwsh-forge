BeforeAll {
    . $PSScriptRoot/../src/ForgeCli/Private/KnownProviders.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/ProviderHelpers.ps1
}

Describe "Get-ForgeProvider" {

    BeforeEach {
        $global:ForgeProviders = @{}
    }

    It "Should return nothing and warn when no providers are registered" {
        $Result = Get-ForgeProvider -WarningVariable warnings -WarningAction SilentlyContinue
        $Result | Should -BeNullOrEmpty
        $warnings | Should -Not -BeNullOrEmpty
    }
}

Describe "KnownProviders" {

    It "Should define Github as a known provider" {
        $global:ForgeKnownProviders.ContainsKey('github') | Should -BeTrue
        $global:ForgeKnownProviders['github'].ModuleName | Should -Be 'GithubCli'
    }

    It "Should define Gitlab as a known provider" {
        $global:ForgeKnownProviders.ContainsKey('gitlab') | Should -BeTrue
        $global:ForgeKnownProviders['gitlab'].ModuleName | Should -Be 'GitlabCli'
    }

    It "Should map forge commands to provider commands" {
        $GH = $global:ForgeKnownProviders['github'].Commands
        $GH['Get-Branch'] | Should -Be 'Get-GithubBranch'
        $GH['Get-ChangeRequest'] | Should -Be 'Get-GithubPullRequest'
        $GH['Get-Group'] | Should -Be 'Get-GithubOrganization'
        $GH['Get-Issue'] | Should -Be 'Get-GithubIssue'
        $GH['Get-Release'] | Should -Be 'Get-GithubRelease'
        $GH['Get-Repo'] | Should -Be 'Get-GithubRepository'
        $GH['Get-User'] | Should -Be 'Get-GithubUser'

        $GL = $global:ForgeKnownProviders['gitlab'].Commands
        $GL['Get-Branch'] | Should -Be 'Get-GitlabBranch'
        $GL['Get-ChangeRequest'] | Should -Be 'Get-GitlabMergeRequest'
        $GL['Get-Group'] | Should -Be 'Get-GitlabGroup'
        $GL['Get-Issue'] | Should -Be 'Get-GitlabIssue'
        $GL['Get-Release'] | Should -Be 'Get-GitlabRelease'
        $GL['Get-Repo'] | Should -Be 'Get-GitlabProject'
        $GL['Get-User'] | Should -Be 'Get-GitlabUser'
    }
}
