@{
    ModuleVersion = '0.13.0'

    PrivateData = @{
        PSData = @{
            LicenseUri = 'https://github.com/chris-peterson/pwsh-forge/blob/main/LICENSE'
            ProjectUri = 'https://github.com/chris-peterson/pwsh-forge'
            Tags = @(
                'Github',
                'Gitlab',
                'Forge',
                'Git',
                'API',
                'DevOps',
                'Automation',
                'PowerShell',
                'Module',
                'PSEdition_Core',
                'Windows',
                'Linux',
                'MacOS'
            )
            ExternalModuleDependencies = @('GithubCli', 'GitlabCli')
            ReleaseNotes =
@'
### Features
* Milestone write verbs: `New-Milestone`, `Update-Milestone`, `Remove-Milestone`. `-State closed` reaches Gitlab as `-StateEvent close`, so the forge parameter means the same thing on both providers: https://github.com/chris-peterson/pwsh-forge/pull/13
* Label commands: `Get-Label`, `New-Label`, `Update-Label`, `Remove-Label`. A `-Name` is resolved to Gitlab's numeric label id before dispatch, so labels stay addressable by the identifier you know: https://github.com/chris-peterson/pwsh-forge/pull/12
'@
        }
    }

    GUID = 'f0f1f2f3-a4b5-c6d7-e8f9-0a1b2c3d4e5f'

    Author = 'Chris Peterson'
    CompanyName = 'Chris Peterson'
    Copyright = '(c) 2026'

    Description = 'Unified interface for GitHub, GitLab, and other software forges'
    PowerShellVersion = '7.1'
    CompatiblePSEditions = @('Core')

    ScriptsToProcess = @(
        'Private/Validations.ps1'
        'Private/Functions/GitHelpers.ps1'
        'Private/Functions/ProviderHelpers.ps1'
    )
    RootModule = 'Private/Init.psm1'
    NestedModules = @(
        'Forge.psm1'
    )

    FunctionsToExport = @(
        'Add-GroupMember'
        'Close-ChangeRequest'
        'Close-Issue'
        'Get-Branch'
        'Get-ChangeRequest'
        'Get-ChangeRequestApproval'
        'Get-ChangeRequestComment'
        'Get-Commit'
        'Get-Group'
        'Get-GroupMember'
        'Get-Issue'
        'Get-Label'
        'Get-Milestone'
        'Get-Release'
        'Get-Repo'
        'Get-User'
        'Get-UserActivity'
        'Merge-ChangeRequest'
        'New-Branch'
        'New-ChangeRequest'
        'New-Issue'
        'New-IssueComment'
        'New-Label'
        'New-Milestone'
        'New-Repo'
        'Open-Issue'
        'Remove-Branch'
        'Remove-GroupMember'
        'Remove-Label'
        'Remove-Milestone'
        'Remove-Repo'
        'Search-Repo'
        'Update-ChangeRequest'
        'Update-Issue'
        'Update-Label'
        'Update-Milestone'
    )

    AliasesToExport = @()
}
