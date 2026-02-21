BeforeAll {
    . $PSScriptRoot/../src/ForgeCli/Private/KnownProviders.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/ProviderHelpers.ps1
    . ([scriptblock]::Create((Get-Content "$PSScriptRoot/../src/ForgeCli/Forge.psm1" -Raw)))
}

Describe "Resolve-ForgeProvider" {

    BeforeEach {
        $global:ForgeProviders = @{}
        Mock Find-ForgeProviders {}
    }

    Context "Explicit provider" {
        It "Should return registered provider" {
            $global:ForgeProviders['github'] = $global:ForgeKnownProviders['github']
            $Result = Resolve-ForgeProvider -Provider 'github'
            $Result.Name | Should -Be 'Github'
        }

        It "Should be case-insensitive" {
            $global:ForgeProviders['github'] = $global:ForgeKnownProviders['github']
            $Result = Resolve-ForgeProvider -Provider 'GitHub'
            $Result.Name | Should -Be 'Github'
        }

        It "Should throw when known provider is not loaded" {
            { Resolve-ForgeProvider -Provider 'github' } | Should -Throw '*not loaded*'
        }

        It "Should throw for completely unknown provider" {
            { Resolve-ForgeProvider -Provider 'bitbucket' } | Should -Throw '*Unknown provider*'
        }
    }

    Context "Auto-detect from git remote" {
        It "Should detect GitHub from remote host" {
            Mock Get-ForgeRemoteHost { [PSCustomObject]@{ Host = 'github.com'; Branch = 'main' } }
            $global:ForgeProviders['github'] = $global:ForgeKnownProviders['github']
            $Result = Resolve-ForgeProvider
            $Result.Name | Should -Be 'Github'
        }

        It "Should detect GitLab from remote host" {
            Mock Get-ForgeRemoteHost { [PSCustomObject]@{ Host = 'gitlab.com'; Branch = 'main' } }
            $global:ForgeProviders['gitlab'] = $global:ForgeKnownProviders['gitlab']
            $Result = Resolve-ForgeProvider
            $Result.Name | Should -Be 'Gitlab'
        }

        It "Should throw when not in git repo and no providers installed" {
            Mock Get-ForgeRemoteHost { [PSCustomObject]@{ Host = ''; Branch = '' } }
            { Resolve-ForgeProvider } | Should -Throw '*no forge providers are installed*'
        }

        It "Should throw when not in git repo but has providers" {
            Mock Get-ForgeRemoteHost { [PSCustomObject]@{ Host = ''; Branch = '' } }
            $global:ForgeProviders['github'] = $global:ForgeKnownProviders['github']
            { Resolve-ForgeProvider -CommandName 'Get-Issue' } | Should -Throw '*Could not detect*'
        }

        It "Should throw when host matches known but unloaded provider" {
            Mock Get-ForgeRemoteHost { [PSCustomObject]@{ Host = 'github.com'; Branch = 'main' } }
            { Resolve-ForgeProvider } | Should -Throw '*not loaded*'
        }

        It "Should throw for unrecognized host" {
            Mock Get-ForgeRemoteHost { [PSCustomObject]@{ Host = 'bitbucket.org'; Branch = 'main' } }
            { Resolve-ForgeProvider } | Should -Throw '*Unrecognized forge host*'
        }
    }
}

Describe "Resolve-ForgeCommand" {

    BeforeEach {
        $global:ForgeProviders = @{
            'github' = $global:ForgeKnownProviders['github']
        }
        Mock Find-ForgeProviders {}
    }

    It "Should return provider name and mapped command" {
        $Result = Resolve-ForgeCommand -CommandName 'Get-Issue' -Provider 'github'
        $Result.ProviderName | Should -Be 'github'
        $Result.Command | Should -Be 'Get-GithubIssue'
    }

    It "Should normalize provider name to lowercase" {
        $global:ForgeProviders['github'].Name = 'GitHub'
        $Result = Resolve-ForgeCommand -CommandName 'Get-Issue' -Provider 'github'
        $Result.ProviderName | Should -Be 'github'
    }

    It "Should throw for unsupported command" {
        $global:ForgeProviders['github'].Commands.Remove('Get-Issue')
        { Resolve-ForgeCommand -CommandName 'Get-Issue' -Provider 'github' } | Should -Throw '*does not support*'
    }
}
