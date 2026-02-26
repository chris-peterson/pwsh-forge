BeforeAll {
    . $PSScriptRoot/../src/ForgeCli/Private/Validations.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Init.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/ProviderHelpers.ps1
    . ([scriptblock]::Create((Get-Content "$PSScriptRoot/../src/ForgeCli/Forge.psm1" -Raw)))

    # Save provider data for restoration after tests that modify it
    $script:AllProviders = $global:ForgeProviders.Clone()

    # GitHub provider command stubs
    function Get-GithubIssue { param($IssueId, $State, [switch]$Mine, $Organization, $Assignee, $Creator, $Labels, $Since, $Sort, $Direction, [uint]$MaxPages, [switch]$All) }
    function New-GithubIssue { param($Title, $Description, [string[]]$Assignees, [string[]]$Labels) }
    function Update-GithubIssue { param($IssueId, $Title, $Description, $State) }
    function Close-GithubIssue { param($IssueId) }
    function Get-GithubPullRequest { param($PullRequestId, $State, [switch]$Mine, $Head, $Base, [uint]$MaxPages, [switch]$All) }
    function New-GithubPullRequest { param($Title, $SourceBranch, $TargetBranch, $Description, [switch]$Draft) }
    function Merge-GithubPullRequest { param($PullRequestId, $MergeMethod, [switch]$DeleteSourceBranch) }
    function Get-GithubRepository { param($RepositoryId, [switch]$Mine, $Organization, $Select, [uint]$MaxPages, [switch]$All) }
    function New-GithubRepository { param($Name, $Description, $Visibility) }
    function Search-GithubRepository { param($Query, $Scope, [uint]$MaxPages, [switch]$All) }
    function Get-GithubOrganization { param($Name, [switch]$Mine, [uint]$MaxPages, [switch]$All) }
    function Get-GithubBranch { param($Name, [switch]$Protected, [uint]$MaxPages, [switch]$All) }
    function Get-GithubRelease { param($Tag, [switch]$Latest, [uint]$MaxPages, [switch]$All) }
    function Get-GithubUser { param($Username, [switch]$Me, $Select) }
    function Get-GithubCommit { param($Sha, $Branch, $Author, $Since, $Until, [uint]$MaxPages, [switch]$All) }

    # GitLab provider command stubs
    function Get-GitlabIssue { param($IssueId, $State, [switch]$Mine, $GroupId, $AssigneeUsername, $AuthorUsername, $CreatedAfter, [uint]$MaxPages, [switch]$All) }
    function New-GitlabIssue { param($Title, $Description, $Labels) }
    function Update-GitlabIssue { param($IssueId, $Title, $Description, $StateEvent) }
    function Close-GitlabIssue { param($IssueId) }
    function Get-GitlabMergeRequest { param($MergeRequestId, $State, [switch]$Mine, $GroupId, $SourceBranch, $Username, [switch]$IsDraft, $CreatedAfter, [uint]$MaxPages, [switch]$All) }
    function New-GitlabMergeRequest { param($Title, $SourceBranch, $TargetBranch, $Description) }
    function Merge-GitlabMergeRequest { param($MergeRequestId, [switch]$Squash, [switch]$ShouldRemoveSourceBranch) }
    function Get-GitlabProject { param($ProjectId, [switch]$Mine, $GroupId, $Select, [switch]$IncludeArchived, [uint]$MaxPages, [switch]$All) }
    function New-GitlabProject { param($Name, $Description, $Visibility) }
    function Search-GitlabProject { param($Search, [uint]$MaxPages, [switch]$All) }
    function Get-GitlabGroup { param($GroupId, [uint]$MaxPages, [switch]$All) }
    function Get-GitlabBranch { param($Ref, $Search, [uint]$MaxPages, [switch]$All) }
    function Get-GitlabRelease { param($Tag, [uint]$MaxPages, [switch]$All) }
    function Get-GitlabUser { param($UserId, [switch]$Me, $Select) }
    function Get-GitlabCommit { param($Sha, $Ref, [uint]$MaxPages, [switch]$All) }
}

# =============================================================================
# Issues
# =============================================================================

Describe "Get-Issue" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Get-GithubIssue {}
        }

        It "Should map Id to IssueId" {
            Get-Issue -Id '42' -Provider github
            Should -Invoke Get-GithubIssue -ParameterFilter { $IssueId -eq '42' }
        }

        It "Should map Group to Organization" {
            Get-Issue -Group 'my-org' -Provider github
            Should -Invoke Get-GithubIssue -ParameterFilter { $Organization -eq 'my-org' }
        }

        It "Should map Author to Creator" {
            Get-Issue -Author 'jdoe' -Provider github
            Should -Invoke Get-GithubIssue -ParameterFilter { $Creator -eq 'jdoe' }
        }

        It "Should pass State through unchanged" {
            Get-Issue -State 'closed' -Provider github
            Should -Invoke Get-GithubIssue -ParameterFilter { $State -eq 'closed' }
        }

        It "Should pass Mine switch" {
            Get-Issue -Mine -Provider github
            Should -Invoke Get-GithubIssue -ParameterFilter { $Mine -eq $true }
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Get-GitlabIssue {}
        }

        It "Should map State 'open' to 'opened'" {
            Get-Issue -State 'open' -Provider gitlab
            Should -Invoke Get-GitlabIssue -ParameterFilter { $State -eq 'opened' }
        }

        It "Should keep State 'closed' as 'closed'" {
            Get-Issue -State 'closed' -Provider gitlab
            Should -Invoke Get-GitlabIssue -ParameterFilter { $State -eq 'closed' }
        }

        It "Should map Group to GroupId" {
            Get-Issue -Group 'my-group' -Provider gitlab
            Should -Invoke Get-GitlabIssue -ParameterFilter { $GroupId -eq 'my-group' }
        }

        It "Should map Assignee to AssigneeUsername" {
            Get-Issue -Assignee 'jdoe' -Provider gitlab
            Should -Invoke Get-GitlabIssue -ParameterFilter { $AssigneeUsername -eq 'jdoe' }
        }

        It "Should map Author to AuthorUsername" {
            Get-Issue -Author 'jdoe' -Provider gitlab
            Should -Invoke Get-GitlabIssue -ParameterFilter { $AuthorUsername -eq 'jdoe' }
        }

        It "Should map Since to CreatedAfter" {
            Get-Issue -Since '2024-01-01' -Provider gitlab
            Should -Invoke Get-GitlabIssue -ParameterFilter { $CreatedAfter -eq '2024-01-01' }
        }

        It "Should warn about unsupported Labels" {
            Get-Issue -Labels 'bug' -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
            $warnings[0] | Should -BeLike '*Labels*not*supported*Gitlab*'
        }

        It "Should warn about unsupported Sort" {
            Get-Issue -Sort 'created' -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }

        It "Should warn about unsupported Direction" {
            Get-Issue -Direction 'asc' -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "New-Issue" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock New-GithubIssue {}
        }

        It "Should pass Title" {
            New-Issue -Title 'Bug report' -Provider github
            Should -Invoke New-GithubIssue -ParameterFilter { $Title -eq 'Bug report' }
        }

        It "Should pass Assignees as array" {
            New-Issue -Title 'Bug' -Assignees @('alice', 'bob') -Provider github
            Should -Invoke New-GithubIssue -ParameterFilter { $Assignees.Count -eq 2 }
        }

        It "Should not call provider command with -WhatIf" {
            New-Issue -Title 'Test' -Provider github -WhatIf
            Should -Invoke New-GithubIssue -Times 0
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock New-GitlabIssue {}
        }

        It "Should join Labels with comma" {
            New-Issue -Title 'Bug' -Labels @('bug', 'critical') -Provider gitlab
            Should -Invoke New-GitlabIssue -ParameterFilter { $Labels -eq 'bug,critical' }
        }

        It "Should warn about unsupported Assignees" {
            New-Issue -Title 'Bug' -Assignees @('alice') -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
            $warnings[0] | Should -BeLike '*Assignees*not*supported*Gitlab*'
        }
    }
}

Describe "Update-Issue" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Update-GithubIssue {}
        }

        It "Should map Id to IssueId" {
            Update-Issue -Id '42' -Title 'Updated' -Provider github
            Should -Invoke Update-GithubIssue -ParameterFilter { $IssueId -eq '42' }
        }

        It "Should pass State through unchanged" {
            Update-Issue -Id '42' -State 'closed' -Provider github
            Should -Invoke Update-GithubIssue -ParameterFilter { $State -eq 'closed' }
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Update-GitlabIssue {}
        }

        It "Should map State 'open' to StateEvent 'reopen'" {
            Update-Issue -Id '42' -State 'open' -Provider gitlab
            Should -Invoke Update-GitlabIssue -ParameterFilter { $StateEvent -eq 'reopen' }
        }

        It "Should map State 'closed' to StateEvent 'close'" {
            Update-Issue -Id '42' -State 'closed' -Provider gitlab
            Should -Invoke Update-GitlabIssue -ParameterFilter { $StateEvent -eq 'close' }
        }
    }
}

Describe "Close-Issue" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Close-GithubIssue {}
        }

        It "Should map Id to IssueId" {
            Close-Issue -Id '42' -Provider github
            Should -Invoke Close-GithubIssue -ParameterFilter { $IssueId -eq '42' }
        }

        It "Should not call provider command with -WhatIf" {
            Close-Issue -Id '42' -Provider github -WhatIf
            Should -Invoke Close-GithubIssue -Times 0
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Close-GitlabIssue {}
        }

        It "Should map Id to IssueId" {
            Close-Issue -Id '42' -Provider gitlab
            Should -Invoke Close-GitlabIssue -ParameterFilter { $IssueId -eq '42' }
        }
    }
}

# =============================================================================
# Change Requests
# =============================================================================

Describe "Get-ChangeRequest" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Get-GithubPullRequest {}
        }

        It "Should map Id to PullRequestId" {
            Get-ChangeRequest -Id '99' -Provider github
            Should -Invoke Get-GithubPullRequest -ParameterFilter { $PullRequestId -eq '99' }
        }

        It "Should map SourceBranch to Head" {
            Get-ChangeRequest -SourceBranch 'feature' -Provider github
            Should -Invoke Get-GithubPullRequest -ParameterFilter { $Head -eq 'feature' }
        }

        It "Should map TargetBranch to Base" {
            Get-ChangeRequest -TargetBranch 'main' -Provider github
            Should -Invoke Get-GithubPullRequest -ParameterFilter { $Base -eq 'main' }
        }

        It "Should map State 'merged' to 'closed' with warning" {
            Get-ChangeRequest -State 'merged' -Provider github -WarningVariable warnings -WarningAction SilentlyContinue
            Should -Invoke Get-GithubPullRequest -ParameterFilter { $State -eq 'closed' }
            $warnings | Should -Not -BeNullOrEmpty
        }

        It "Should warn about unsupported Author" {
            Get-ChangeRequest -Author 'jdoe' -Provider github -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }

        It "Should warn about unsupported IsDraft" {
            Get-ChangeRequest -IsDraft -Provider github -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }

        It "Should warn about unsupported Since" {
            Get-ChangeRequest -Since '2024-01-01' -Provider github -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Get-GitlabMergeRequest {}
        }

        It "Should map Id to MergeRequestId" {
            Get-ChangeRequest -Id '99' -Provider gitlab
            Should -Invoke Get-GitlabMergeRequest -ParameterFilter { $MergeRequestId -eq '99' }
        }

        It "Should map State 'open' to 'opened'" {
            Get-ChangeRequest -State 'open' -Provider gitlab
            Should -Invoke Get-GitlabMergeRequest -ParameterFilter { $State -eq 'opened' }
        }

        It "Should pass State 'merged' through" {
            Get-ChangeRequest -State 'merged' -Provider gitlab
            Should -Invoke Get-GitlabMergeRequest -ParameterFilter { $State -eq 'merged' }
        }

        It "Should map Author to Username" {
            Get-ChangeRequest -Author 'jdoe' -Provider gitlab
            Should -Invoke Get-GitlabMergeRequest -ParameterFilter { $Username -eq 'jdoe' }
        }

        It "Should map Since to CreatedAfter" {
            Get-ChangeRequest -Since '2024-01-01' -Provider gitlab
            Should -Invoke Get-GitlabMergeRequest -ParameterFilter { $CreatedAfter -eq '2024-01-01' }
        }

        It "Should pass IsDraft switch" {
            Get-ChangeRequest -IsDraft -Provider gitlab
            Should -Invoke Get-GitlabMergeRequest -ParameterFilter { $IsDraft -eq $true }
        }

        It "Should warn about unsupported TargetBranch" {
            Get-ChangeRequest -TargetBranch 'main' -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "New-ChangeRequest" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock New-GithubPullRequest {}
        }

        It "Should pass Title and SourceBranch" {
            New-ChangeRequest -Title 'Add feature' -SourceBranch 'feature' -Provider github
            Should -Invoke New-GithubPullRequest -ParameterFilter {
                $Title -eq 'Add feature' -and $SourceBranch -eq 'feature'
            }
        }

        It "Should pass Draft switch" {
            New-ChangeRequest -Title 'WIP' -SourceBranch 'feature' -Draft -Provider github
            Should -Invoke New-GithubPullRequest -ParameterFilter { $Draft -eq $true }
        }

        It "Should not call provider command with -WhatIf" {
            New-ChangeRequest -Title 'Test' -SourceBranch 'feature' -Provider github -WhatIf
            Should -Invoke New-GithubPullRequest -Times 0
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock New-GitlabMergeRequest {}
        }

        It "Should pass Title and SourceBranch" {
            New-ChangeRequest -Title 'Add feature' -SourceBranch 'feature' -Provider gitlab
            Should -Invoke New-GitlabMergeRequest -ParameterFilter {
                $Title -eq 'Add feature' -and $SourceBranch -eq 'feature'
            }
        }

        It "Should warn about unsupported Draft" {
            New-ChangeRequest -Title 'WIP' -SourceBranch 'feature' -Draft -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
            $warnings[0] | Should -BeLike '*Draft*not*supported*Gitlab*'
        }
    }
}

Describe "Merge-ChangeRequest" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Merge-GithubPullRequest {}
        }

        It "Should map Id to PullRequestId" {
            Merge-ChangeRequest -Id '99' -Provider github
            Should -Invoke Merge-GithubPullRequest -ParameterFilter { $PullRequestId -eq '99' }
        }

        It "Should map Squash to MergeMethod 'squash'" {
            Merge-ChangeRequest -Id '99' -Squash -Provider github
            Should -Invoke Merge-GithubPullRequest -ParameterFilter { $MergeMethod -eq 'squash' }
        }

        It "Should pass DeleteSourceBranch" {
            Merge-ChangeRequest -Id '99' -DeleteSourceBranch -Provider github
            Should -Invoke Merge-GithubPullRequest -ParameterFilter { $DeleteSourceBranch -eq $true }
        }

        It "Should not call provider command with -WhatIf" {
            Merge-ChangeRequest -Id '99' -Provider github -WhatIf
            Should -Invoke Merge-GithubPullRequest -Times 0
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Merge-GitlabMergeRequest {}
        }

        It "Should map Id to MergeRequestId" {
            Merge-ChangeRequest -Id '99' -Provider gitlab
            Should -Invoke Merge-GitlabMergeRequest -ParameterFilter { $MergeRequestId -eq '99' }
        }

        It "Should pass Squash switch directly" {
            Merge-ChangeRequest -Id '99' -Squash -Provider gitlab
            Should -Invoke Merge-GitlabMergeRequest -ParameterFilter { $Squash -eq $true }
        }

        It "Should map DeleteSourceBranch to ShouldRemoveSourceBranch" {
            Merge-ChangeRequest -Id '99' -DeleteSourceBranch -Provider gitlab
            Should -Invoke Merge-GitlabMergeRequest -ParameterFilter { $ShouldRemoveSourceBranch -eq $true }
        }
    }
}

# =============================================================================
# Repositories
# =============================================================================

Describe "Get-Repo" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Get-GithubRepository {}
        }

        It "Should map Id to RepositoryId" {
            Get-Repo -Id 'my-repo' -Provider github
            Should -Invoke Get-GithubRepository -ParameterFilter { $RepositoryId -eq 'my-repo' }
        }

        It "Should map Group to Organization" {
            Get-Repo -Group 'my-org' -Provider github
            Should -Invoke Get-GithubRepository -ParameterFilter { $Organization -eq 'my-org' }
        }

        It "Should warn about IncludeArchived" {
            Get-Repo -IncludeArchived -Provider github -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
            $warnings[0] | Should -BeLike '*IncludeArchived*not*applicable*Github*'
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Get-GitlabProject {}
        }

        It "Should map Id to ProjectId" {
            Get-Repo -Id 'my-project' -Provider gitlab
            Should -Invoke Get-GitlabProject -ParameterFilter { $ProjectId -eq 'my-project' }
        }

        It "Should map Group to GroupId" {
            Get-Repo -Group 'my-group' -Provider gitlab
            Should -Invoke Get-GitlabProject -ParameterFilter { $GroupId -eq 'my-group' }
        }

        It "Should pass IncludeArchived" {
            Get-Repo -IncludeArchived -Provider gitlab
            Should -Invoke Get-GitlabProject -ParameterFilter { $IncludeArchived -eq $true }
        }
    }
}

Describe "New-Repo" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock New-GithubRepository {}
        }

        It "Should pass Name, Description, and Visibility" {
            New-Repo -Name 'my-repo' -Description 'A repo' -Visibility 'public' -Provider github
            Should -Invoke New-GithubRepository -ParameterFilter {
                $Name -eq 'my-repo' -and $Description -eq 'A repo' -and $Visibility -eq 'public'
            }
        }

        It "Should not call provider command with -WhatIf" {
            New-Repo -Name 'my-repo' -Provider github -WhatIf
            Should -Invoke New-GithubRepository -Times 0
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock New-GitlabProject {}
        }

        It "Should pass Name and Visibility" {
            New-Repo -Name 'my-project' -Visibility 'private' -Provider gitlab
            Should -Invoke New-GitlabProject -ParameterFilter {
                $Name -eq 'my-project' -and $Visibility -eq 'private'
            }
        }
    }
}

Describe "Search-Repo" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Search-GithubRepository {}
        }

        It "Should pass Query and Scope" {
            Search-Repo -Query 'forge' -Scope 'code' -Provider github
            Should -Invoke Search-GithubRepository -ParameterFilter {
                $Query -eq 'forge' -and $Scope -eq 'code'
            }
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Search-GitlabProject {}
        }

        It "Should map Query to Search" {
            Search-Repo -Query 'forge' -Provider gitlab
            Should -Invoke Search-GitlabProject -ParameterFilter { $Search -eq 'forge' }
        }

        It "Should warn about unsupported Scope" {
            Search-Repo -Query 'forge' -Scope 'code' -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }
    }
}

Describe "Get-Group" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Get-GithubOrganization {}
        }

        It "Should pass Name" {
            Get-Group -Name 'my-org' -Provider github
            Should -Invoke Get-GithubOrganization -ParameterFilter { $Name -eq 'my-org' }
        }

        It "Should pass Mine switch" {
            Get-Group -Mine -Provider github
            Should -Invoke Get-GithubOrganization -ParameterFilter { $Mine -eq $true }
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Get-GitlabGroup {}
        }

        It "Should map Name to GroupId" {
            Get-Group -Name 'my-group' -Provider gitlab
            Should -Invoke Get-GitlabGroup -ParameterFilter { $GroupId -eq 'my-group' }
        }

        It "Should warn about unsupported Mine" {
            Get-Group -Mine -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }
    }
}

# =============================================================================
# Branches
# =============================================================================

Describe "Get-Branch" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Get-GithubBranch {}
        }

        It "Should pass Name" {
            Get-Branch -Name 'main' -Provider github
            Should -Invoke Get-GithubBranch -ParameterFilter { $Name -eq 'main' }
        }

        It "Should pass Protected switch" {
            Get-Branch -Protected -Provider github
            Should -Invoke Get-GithubBranch -ParameterFilter { $Protected -eq $true }
        }

        It "Should warn about unsupported Search" {
            Get-Branch -Search 'feat' -Provider github -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
            $warnings[0] | Should -BeLike '*Search*not*supported*Github*'
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Get-GitlabBranch {}
        }

        It "Should map Name to Ref" {
            Get-Branch -Name 'main' -Provider gitlab
            Should -Invoke Get-GitlabBranch -ParameterFilter { $Ref -eq 'main' }
        }

        It "Should pass Search" {
            Get-Branch -Search 'feat' -Provider gitlab
            Should -Invoke Get-GitlabBranch -ParameterFilter { $Search -eq 'feat' }
        }

        It "Should warn about unsupported Protected" {
            Get-Branch -Protected -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
            $warnings[0] | Should -BeLike '*Protected*not*supported*Gitlab*'
        }
    }
}

# =============================================================================
# Releases
# =============================================================================

Describe "Get-Release" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Get-GithubRelease {}
        }

        It "Should pass Tag" {
            Get-Release -Tag 'v1.0' -Provider github
            Should -Invoke Get-GithubRelease -ParameterFilter { $Tag -eq 'v1.0' }
        }

        It "Should pass Latest switch" {
            Get-Release -Latest -Provider github
            Should -Invoke Get-GithubRelease -ParameterFilter { $Latest -eq $true }
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Get-GitlabRelease {}
        }

        It "Should pass Tag" {
            Get-Release -Tag 'v1.0' -Provider gitlab
            Should -Invoke Get-GitlabRelease -ParameterFilter { $Tag -eq 'v1.0' }
        }

        It "Should warn about unsupported Latest" {
            Get-Release -Latest -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }
    }
}

# =============================================================================
# Users
# =============================================================================

Describe "Get-User" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Get-GithubUser {}
        }

        It "Should pass Username" {
            Get-User -Username 'jdoe' -Provider github
            Should -Invoke Get-GithubUser -ParameterFilter { $Username -eq 'jdoe' }
        }

        It "Should pass Me switch" {
            Get-User -Me -Provider github
            Should -Invoke Get-GithubUser -ParameterFilter { $Me -eq $true }
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Get-GitlabUser {}
        }

        It "Should map Username to UserId" {
            Get-User -Username 'jdoe' -Provider gitlab
            Should -Invoke Get-GitlabUser -ParameterFilter { $UserId -eq 'jdoe' }
        }
    }
}

# =============================================================================
# Commits
# =============================================================================

Describe "Get-Commit" {

    Context "GitHub" {
        BeforeEach {
            $global:ForgeProviders = @{ 'github' = $script:AllProviders['github'] }

            Mock Get-GithubCommit {}
        }

        It "Should map Ref to Sha" {
            Get-Commit -Ref 'abc123' -Provider github
            Should -Invoke Get-GithubCommit -ParameterFilter { $Sha -eq 'abc123' }
        }

        It "Should pass Branch, Author, Since, Until" {
            Get-Commit -Branch 'main' -Author 'jdoe' -Since '2024-01-01' -Until '2024-12-31' -Provider github
            Should -Invoke Get-GithubCommit -ParameterFilter {
                $Branch -eq 'main' -and $Author -eq 'jdoe' -and $Since -eq '2024-01-01' -and $Until -eq '2024-12-31'
            }
        }
    }

    Context "GitLab" {
        BeforeEach {
            $global:ForgeProviders = @{ 'gitlab' = $script:AllProviders['gitlab'] }

            Mock Get-GitlabCommit {}
        }

        It "Should map Ref to Sha" {
            Get-Commit -Ref 'abc123' -Provider gitlab
            Should -Invoke Get-GitlabCommit -ParameterFilter { $Sha -eq 'abc123' }
        }

        It "Should map Branch to Ref" {
            Get-Commit -Branch 'main' -Provider gitlab
            Should -Invoke Get-GitlabCommit -ParameterFilter { $Ref -eq 'main' }
        }

        It "Should warn about unsupported Author" {
            Get-Commit -Author 'jdoe' -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }

        It "Should warn about unsupported Since" {
            Get-Commit -Since '2024-01-01' -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }

        It "Should warn about unsupported Until" {
            Get-Commit -Until '2024-12-31' -Provider gitlab -WarningVariable warnings -WarningAction SilentlyContinue
            $warnings | Should -Not -BeNullOrEmpty
        }
    }
}
