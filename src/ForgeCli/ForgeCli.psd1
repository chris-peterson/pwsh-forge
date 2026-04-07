@{
    ModuleVersion = '0.7.0'

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
WIP dashboard support:
* Get-ChangeRequest now supports -Until for date range end filtering
* Get-ChangeRequest now supports -Reviewer for reviewer filtering
* Get-ChangeRequest -State merged now works on GitHub (uses search API with is:merged)
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
        'Get-ChangeRequestComment'
        'Get-Commit'
        'Get-Group'
        'Get-GroupMember'
        'Get-Issue'
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
        'New-Repo'
        'Open-Issue'
        'Remove-Branch'
        'Remove-GroupMember'
        'Remove-Repo'
        'Search-Repo'
        'Update-ChangeRequest'
        'Update-Issue'
    )

    AliasesToExport = @()
}
