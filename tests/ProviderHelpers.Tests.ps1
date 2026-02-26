BeforeAll {
    . $PSScriptRoot/../src/ForgeCli/Private/Validations.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Init.ps1
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
