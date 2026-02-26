BeforeAll {
    . $PSScriptRoot/../src/ForgeCli/Private/Validations.ps1
    Import-Module $PSScriptRoot/../src/ForgeCli/Private/Init.psm1 -Force
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/ProviderHelpers.ps1
    . ([scriptblock]::Create((Get-Content "$PSScriptRoot/../src/ForgeCli/Forge.psm1" -Raw)))

    # Save provider data for restoration after tests that modify it
    $script:OriginalProviders = $global:ForgeProviders.Clone()
}

Describe "Resolve-ForgeProvider" {

    Context "Explicit provider" {
        It "Should return registered provider" {
            $Result = Resolve-ForgeProvider -Provider 'github'
            $Result.Name | Should -Be 'Github'
        }

        It "Should be case-insensitive" {
            $Result = Resolve-ForgeProvider -Provider 'GitHub'
            $Result.Name | Should -Be 'Github'
        }

        It "Should throw for unknown provider" {
            { Resolve-ForgeProvider -Provider 'bitbucket' } | Should -Throw '*Unknown provider*'
        }
    }

    Context "Auto-detect from git remote" {
        It "Should detect GitHub from remote host" {
            Mock Get-ForgeRemoteHost { [PSCustomObject]@{ Host = 'github.com'; Branch = 'main' } }
            $Result = Resolve-ForgeProvider
            $Result.Name | Should -Be 'Github'
        }

        It "Should detect GitLab from remote host" {
            Mock Get-ForgeRemoteHost { [PSCustomObject]@{ Host = 'gitlab.com'; Branch = 'main' } }
            $Result = Resolve-ForgeProvider
            $Result.Name | Should -Be 'Gitlab'
        }

        It "Should throw when not in git repo" {
            Mock Get-ForgeRemoteHost { [PSCustomObject]@{ Host = ''; Branch = '' } }
            { Resolve-ForgeProvider -CommandName 'Get-Issue' } | Should -Throw '*Could not detect*'
        }

        It "Should throw for unrecognized host" {
            Mock Get-ForgeRemoteHost { [PSCustomObject]@{ Host = 'bitbucket.org'; Branch = 'main' } }
            { Resolve-ForgeProvider } | Should -Throw '*Unrecognized forge host*'
        }
    }
}

Describe "Resolve-ForgeCommand" {

    AfterEach {
        $global:ForgeProviders = $script:OriginalProviders.Clone()
    }

    It "Should return provider name and mapped command" {
        $Result = Resolve-ForgeCommand -CommandName 'Get-Issue' -Provider 'github'
        $Result.Provider | Should -Be 'github'
        $Result.Command | Should -Be 'Get-GithubIssue'
    }

    It "Should normalize provider name to lowercase" {
        $global:ForgeProviders['github'].Name = 'GitHub'
        $Result = Resolve-ForgeCommand -CommandName 'Get-Issue' -Provider 'github'
        $Result.Provider | Should -Be 'github'
    }

    It "Should throw for unsupported command" {
        $global:ForgeProviders['github'].Commands.Remove('Get-Issue')
        { Resolve-ForgeCommand -CommandName 'Get-Issue' -Provider 'github' } | Should -Throw '*does not support*'
    }
}
