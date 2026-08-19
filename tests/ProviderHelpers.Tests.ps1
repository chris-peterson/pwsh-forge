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

    It "Should keep the memoized detail off the object's public surface" {
        Mock Get-GithubPullRequest {
            [PSCustomObject]@{
                Head = [PSCustomObject]@{ Ref = 'feature' }
                Base = [PSCustomObject]@{ Ref = 'main' }
            }
        }

        $Cr = [PSCustomObject]@{ ProjectPath = 'owner/repo'; Number = 7 } |
            Add-GithubChangeRequestBranch
        $null = $Cr.SourceBranch

        ($Cr | Get-Member -MemberType Properties).Name | Should -Not -Contain '__ForgeDetail'
        $Cr | ConvertTo-Json -Compress | Should -Not -Match 'ForgeDetail'
    }

    It "Should warn rather than render an empty branch when the resolve is refused" {
        Mock Get-GithubPullRequest { throw "401 Unauthorized" }

        $Cr = [PSCustomObject]@{ ProjectPath = 'owner/repo'; Number = 7 } |
            Add-GithubChangeRequestBranch
        $Warning = $($null = $Cr.SourceBranch) 3>&1

        "$Warning" | Should -Match 'owner/repo#7'
        "$Warning" | Should -Match '401 Unauthorized'
    }

    It "Should memoize a refusal instead of retrying it on every read" {
        Mock Get-GithubPullRequest { throw "401 Unauthorized" }

        $Cr = [PSCustomObject]@{ ProjectPath = 'owner/repo'; Number = 7 } |
            Add-GithubChangeRequestBranch
        $null = ($Cr.SourceBranch, $Cr.TargetBranch, $Cr.SourceBranch) 3>$null

        Should -Invoke Get-GithubPullRequest -Times 1 -Exactly
    }
}

Describe "Add-ChangeRequestBranchContract" {

    It "Should apply the Github contract for the github provider" {
        Mock Get-GithubPullRequest { throw "should not be called" }

        $Cr = [PSCustomObject]@{
            Head = [PSCustomObject]@{ Ref = 'my-feature' }
            Base = [PSCustomObject]@{ Ref = 'main' }
        } | Add-ChangeRequestBranchContract -Provider 'github'

        $Cr.SourceBranch | Should -Be 'my-feature'
        $Cr.TargetBranch | Should -Be 'main'
    }

    It "Should pass a gitlab merge request through untouched" {
        $Mr = [PSCustomObject]@{ SourceBranch = 'mr-feature'; TargetBranch = 'main' } |
            Add-ChangeRequestBranchContract -Provider 'gitlab'

        $Mr.SourceBranch | Should -Be 'mr-feature'
        ($Mr | Get-Member -Name SourceBranch).MemberType | Should -Be 'NoteProperty'
    }
}
