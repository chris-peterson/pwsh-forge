@{
    ModuleVersion = '0.1.0'

    PrivateData = @{
        PSData = @{
            LicenseUri = 'https://github.com/chris-peterson/pwsh-forge/blob/main/LICENSE'
            ProjectUri = 'https://github.com/chris-peterson/pwsh-forge'
            Tags = @(
                'GitHub',
                'GitLab',
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
            ReleaseNotes =
@'
* Initial plugin architecture with provider registration and dispatch
* Unified commands: Get-Issue, Get-ChangeRequest, Get-Repo
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
        'Private/KnownProviders.ps1'
        'Private/Functions/GitHelpers.ps1'
        'Private/Functions/ProviderHelpers.ps1'
    )

    NestedModules = @(
        'Forge.psm1'
    )

    FunctionsToExport = @(
        # Providers
        'Register-ForgeProvider'
        'Get-ForgeProvider'

        # Commands
        'Get-Issue'
        'Get-ChangeRequest'
        'Get-Repo'
    )

    AliasesToExport = @(
        # TODO: coordinate with GitlabCli removing its short aliases first
        # 'issue'
        # 'issues'
        # 'cr'
        # 'repo'
    )
}
