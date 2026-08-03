BeforeAll {
    . $PSScriptRoot/../src/ForgeCli/Private/Validations.ps1
    Import-Module $PSScriptRoot/../src/ForgeCli/Private/Init.psm1 -Force
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/ProviderHelpers.ps1
}

Describe "ForgeProviders" {

    It "Should define Github as a provider" {
        $global:ForgeProviders.ContainsKey('github') | Should -BeTrue
    }

    It "Should define Gitlab as a provider" {
        $global:ForgeProviders.ContainsKey('gitlab') | Should -BeTrue
    }
}

Describe "Add-GithubChangeRequestBranch" {

    It "Should read the refs off the pulls-API shape without an extra call" {
        Mock Get-GithubPullRequest { throw "should not be called" }

        $Cr = [PSCustomObject]@{
            Head = [PSCustomObject]@{ Ref = 'my-feature' }
            Base = [PSCustomObject]@{ Ref = 'main' }
        } | Add-GithubChangeRequestBranch

        $Cr.SourceBranch | Should -Be 'my-feature'
        $Cr.TargetBranch | Should -Be 'main'
    }

    It "Should resolve the refs for the search shape, which carries neither" {
        Mock Get-GithubPullRequest {
            [PSCustomObject]@{
                Head = [PSCustomObject]@{ Ref = 'resolved-feature' }
                Base = [PSCustomObject]@{ Ref = 'master' }
            }
        }

        $Cr = [PSCustomObject]@{ ProjectPath = 'owner/repo'; Number = 7 } |
            Add-GithubChangeRequestBranch

        $Cr.SourceBranch | Should -Be 'resolved-feature'
        $Cr.TargetBranch | Should -Be 'master'
    }

    It "Should resolve once and reuse it across both properties" {
        Mock Get-GithubPullRequest {
            [PSCustomObject]@{
                Head = [PSCustomObject]@{ Ref = 'feature' }
                Base = [PSCustomObject]@{ Ref = 'main' }
            }
        }

        $Cr = [PSCustomObject]@{ ProjectPath = 'owner/repo'; Number = 7 } |
            Add-GithubChangeRequestBranch
        $null = $Cr.SourceBranch, $Cr.TargetBranch, $Cr.SourceBranch

        Should -Invoke Get-GithubPullRequest -Times 1 -Exactly
    }

    It "Should stay null rather than throw when there is nothing to resolve from" {
        Mock Get-GithubPullRequest { throw "should not be called" }

        $Cr = [PSCustomObject]@{ Title = 'no identifiers' } | Add-GithubChangeRequestBranch

        $Cr.SourceBranch | Should -BeNullOrEmpty
        $Cr.TargetBranch | Should -BeNullOrEmpty
    }
}
