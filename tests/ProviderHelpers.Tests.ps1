BeforeAll {
    . $PSScriptRoot/../src/ForgeCli/Private/KnownProviders.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/ProviderHelpers.ps1
}

Describe "Register-ForgeProvider" {

    BeforeEach {
        $global:ForgeProviders = @{}
    }

    It "Should register a provider" {
        Register-ForgeProvider -Name 'TestForge' -HostPattern 'testforge\.com' -Commands @{
            'Get-Issue' = 'Get-TestForgeIssue'
        }
        $global:ForgeProviders.ContainsKey('testforge') | Should -BeTrue
        $global:ForgeProviders['testforge'].Name | Should -Be 'TestForge'
    }

    It "Should store host patterns" {
        Register-ForgeProvider -Name 'TestForge' -HostPattern @('testforge\.com', 'tf\.io') -Commands @{}
        $global:ForgeProviders['testforge'].HostPatterns | Should -HaveCount 2
    }

    It "Should store command mappings" {
        Register-ForgeProvider -Name 'TestForge' -HostPattern 'testforge\.com' -Commands @{
            'Get-Issue' = 'Get-TestForgeIssue'
            'Get-Repo'  = 'Get-TestForgeRepo'
        }
        $global:ForgeProviders['testforge'].Commands['Get-Issue'] | Should -Be 'Get-TestForgeIssue'
        $global:ForgeProviders['testforge'].Commands['Get-Repo'] | Should -Be 'Get-TestForgeRepo'
    }

    It "Should normalize provider name to lowercase" {
        Register-ForgeProvider -Name 'GitHub' -HostPattern 'github' -Commands @{}
        $global:ForgeProviders.ContainsKey('github') | Should -BeTrue
    }
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

    It "Should return registered providers" {
        Register-ForgeProvider -Name 'GitHub' -HostPattern 'github' -Commands @{
            'Get-Issue' = 'Get-GitHubIssue'
        }
        $Result = Get-ForgeProvider
        $Result | Should -Not -BeNullOrEmpty
        $Result.Name | Should -Be 'GitHub'
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
