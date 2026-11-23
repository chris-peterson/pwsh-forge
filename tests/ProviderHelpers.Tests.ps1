BeforeAll {
    # A dot-sourced script resets $PSScriptRoot, so resolve the source root first
    $Src = "$PSScriptRoot/../src/ForgeCli"
    . $Src/Private/Init.ps1
    . $Src/Private/Functions/GitHelpers.ps1
    . $Src/Private/Functions/ProviderHelpers.ps1
}

Describe "ForgeProviders" {

    It "Should define Github as a provider" {
        $script:ForgeProviders.ContainsKey('github') | Should -BeTrue
    }

    It "Should define Gitlab as a provider" {
        $script:ForgeProviders.ContainsKey('gitlab') | Should -BeTrue
    }
}
