BeforeDiscovery {
    Import-Module powershell-yaml -ErrorAction Stop
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/RecordHelpers.ps1
    $ChangeRequestFields = @((Get-ForgeSchema ChangeRequest).properties.Keys)
    $ChangeRequestCases = @(
        @{ Forge = 'github'; Fixture = 'github/pull-request-merged.json' }
        @{ Forge = 'github'; Fixture = 'github/pull-request-draft.json' }
        @{ Forge = 'gitlab'; Fixture = 'gitlab/merge-request-merged.json' }
        @{ Forge = 'gitlab'; Fixture = 'gitlab/merge-request-closed.json' }
    )
}

BeforeAll {
    # The contract is what the real provider modules emit, so stubs can't stand in for them. A fresh import leaves
    # one instance of each nested module, so the mocks below land on the instance that serves the call.
    # A module already loaded (from a profile, say) is reloaded from the same path, which may not be on PSModulePath.
    $ProviderSources = foreach ($Name in 'GithubCli', 'GitlabCli') {
        $Loaded = Get-Module $Name | Select-Object -First 1
        if ($Loaded) { $Loaded.Path } else { $Name }
    }
    # Both providers load their private helpers and classes through ScriptsToProcess, which runs in the importer's
    # scope (issue #25). Imported from inside a module, the helpers land where the providers' nested modules can see
    # them; imported from this block, the classes their parameter attributes name resolve. So import from both:
    # the module first, for the helpers it leaves behind, then this block, for the instance the mocks land on.
    $null = New-Module -Name ContractProviders -ArgumentList (, $ProviderSources) -ScriptBlock {
        param($Sources)
        Import-Module $Sources -Force -ErrorAction Stop
    }
    Get-Module GithubCli, GitlabCli -All | Remove-Module -Force
    Import-Module $ProviderSources -Force -ErrorAction Stop

    # A dot-sourced script resets $PSScriptRoot, so resolve the source root first
    $Src = "$PSScriptRoot/../src/ForgeCli"
    . $Src/Private/Init.ps1
    . $Src/Private/Functions/GitHelpers.ps1
    . $Src/Private/Functions/ProviderHelpers.ps1
    . $Src/Private/Functions/RecordHelpers.ps1
    . $Src/Forge.ps1

    # GithubCli resolves display names through this cache; seeding it keeps the run offline.
    $script:SavedGithubCache = $global:GithubCache
    $global:GithubCache = @{ users = @{ 'chris-peterson' = 'Chris Peterson' } }

    # Test-Json also reports the unmatched branches of a oneOf that passed, so a whole-record
    # failure lists noise beside the real error. Validating one field at a time keeps it exact.
    function Get-ContractViolation {
        param($Record, $Schema)
        $Json = $Record | ConvertTo-Json -Depth 8
        $null = Test-Json -Json $Json -Schema ($Schema | ConvertTo-Json -Depth 32) -ErrorVariable Errors -ErrorAction SilentlyContinue
        $Errors.Exception.Message | ForEach-Object { $_ -replace '^The JSON is not valid with the schema: ' } | Sort-Object -Unique
    }

    function Get-FieldSchema {
        param($Schema, $Field)
        [ordered]@{
            '$schema'  = $Schema['$schema']
            type       = 'object'
            properties = [ordered]@{ $Field = $Schema.properties[$Field] }
            required   = @($Field)
            '$defs'    = $Schema['$defs']
        }
    }

    function Get-CrossFieldSchema {
        param($Schema)
        $Rules = [ordered]@{} + $Schema
        $Rules.properties = [ordered]@{}
        foreach ($Field in $Schema.properties.Keys) { $Rules.properties[$Field] = $true }
        $Rules.required = @()
        $Rules
    }
}

AfterAll {
    $global:GithubCache = $script:SavedGithubCache
}

Describe 'Contract docs' {
    BeforeAll {
        . $PSScriptRoot/Support/Markdown.ps1
    }

    It 'TERMINOLOGY.md property mappings should match the schemas' {
        $Expected = ConvertTo-ContractMarkdown 'src/ForgeCli/Schemas'

        $DocContent = Get-Content "$PSScriptRoot/../TERMINOLOGY.md" -Raw
        $Actual = if ($DocContent -match '(?ms)^## Detailed Property Mappings\r?\n.*?(?=^## )') { $Matches[0].TrimEnd() -replace "`r`n", "`n" } else { '' }

        if ($Actual -ne $Expected) {
            Write-Host "`nGenerated section (copy to TERMINOLOGY.md):`n" -ForegroundColor Yellow
            Write-Host $Expected
            Write-Host ''
        }

        $Actual | Should -Be $Expected
    }
}

Describe 'ChangeRequest contract (<Forge>: <Fixture>)' -ForEach $ChangeRequestCases {
    BeforeAll {
        $script:Schema = Get-ForgeSchema ChangeRequest
        $script:Payload = Get-Content "$PSScriptRoot/fixtures/$Fixture" -Raw | ConvertFrom-Json
        # Mocks go on the provider's nested module that makes the call; the root module's scope doesn't intercept it.
        switch ($Forge) {
            'github' {
                $script:ApiModule = 'PullRequests'
                $script:ApiCommand = 'Invoke-GithubApi'
                Mock -ModuleName $ApiModule $ApiCommand { $script:Payload }
                $Repo = $Payload.base.repo.full_name
                $script:Id = $Payload.number
            }
            'gitlab' {
                $script:ApiModule = 'MergeRequests'
                $script:ApiCommand = 'Invoke-GitlabApi'
                Mock -ModuleName $ApiModule $ApiCommand { $script:Payload }
                Mock -ModuleName $ApiModule Resolve-GitlabProjectId { $script:Payload.project_id }
                $Repo = $Payload.references.full -replace '!\d+$'
                $script:Id = $Payload.iid
            }
        }
        $script:Record = Get-ChangeRequest -Id $Id -Repo $Repo -Forge $Forge | ConvertTo-ForgeRecord ChangeRequest
    }

    It 'reads the fixture rather than the live API' {
        Should -Invoke -ModuleName $ApiModule $ApiCommand -Scope Describe -Times 1 -Exactly
    }

    It 'has a conforming <_>' -ForEach $ChangeRequestFields {
        Get-ContractViolation $Record (Get-FieldSchema $Schema $_) | Should -BeNullOrEmpty
    }

    It 'satisfies the cross-field rules' {
        Get-ContractViolation $Record (Get-CrossFieldSchema $Schema) | Should -BeNullOrEmpty
    }

    It 'uses the per-repo number as id' {
        $Record.id | Should -Be $Id
    }
}
