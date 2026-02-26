@{
    ModuleVersion = '0.4.0'

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
Plugin architecture with provider registration and dispatch

Supported Cmdlets:
* Close-Issue
* Get-Branch
* Get-ChangeRequest
* Get-Commit
* Get-Group
* Get-Issue
* Get-Release
* Get-Repo
* Get-User
* Merge-ChangeRequest
* New-ChangeRequest
* New-Issue
* New-Repo
* Search-Repo
* Update-Issue
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
        'Close-Issue'
        'Get-Branch'
        'Get-ChangeRequest'
        'Get-Commit'
        'Get-Group'
        'Get-Issue'
        'Get-Release'
        'Get-Repo'
        'Get-User'
        'Merge-ChangeRequest'
        'New-ChangeRequest'
        'New-Issue'
        'New-Repo'
        'Search-Repo'
        'Update-Issue'
    )

    AliasesToExport = @()
}
