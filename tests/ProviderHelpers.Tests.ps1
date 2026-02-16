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

    It "Should define GitHub as a known provider" {
        $global:ForgeKnownProviders.ContainsKey('github') | Should -BeTrue
        $global:ForgeKnownProviders['github'].ModuleName | Should -Be 'GitHubCli'
    }

    It "Should define GitLab as a known provider" {
        $global:ForgeKnownProviders.ContainsKey('gitlab') | Should -BeTrue
        $global:ForgeKnownProviders['gitlab'].ModuleName | Should -Be 'GitlabCli'
    }

    It "Should map forge commands to provider commands" {
        $GH = $global:ForgeKnownProviders['github'].Commands
        $GH['Get-Issue'] | Should -Be 'Get-GitHubIssue'
        $GH['Get-ChangeRequest'] | Should -Be 'Get-GitHubPullRequest'
        $GH['Get-Repo'] | Should -Be 'Get-GitHubRepository'

        $GL = $global:ForgeKnownProviders['gitlab'].Commands
        $GL['Get-Issue'] | Should -Be 'Get-GitlabIssue'
        $GL['Get-ChangeRequest'] | Should -Be 'Get-GitlabMergeRequest'
        $GL['Get-Repo'] | Should -Be 'Get-GitlabProject'
    }
}
