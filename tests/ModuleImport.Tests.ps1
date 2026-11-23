Describe 'Importing ForgeCli from another module' {

    # A module that imports ForgeCli is the case that breaks a helper or registry living outside ForgeCli's own scope:
    # ScriptsToProcess would define it in the importer's session state, where ForgeCli's commands can't see it.
    # It runs in a fresh process: the other test files dot-source Forge.ps1, and a second SupportedProvider class in
    # the same session shadows the module's.
    BeforeAll {
        $Probe = {
            param($Manifest)
            $Importer = New-Module -Name ForgeCliImporter -ArgumentList $Manifest -ScriptBlock {
                param($Path)
                Import-Module $Path -Force
                function Get-ImportedForgeCli { Get-Module ForgeCli }
                function Invoke-ImportedGetIssue { param($Forge) Get-Issue -Id 42 -Forge $Forge }
            }
            $ForgeCli = & $Importer { Get-ImportedForgeCli }

            # A stand-in provider, so dispatch completes without a provider module or a network call
            function global:Get-FakeIssue { 'dispatched to fake' }
            & $ForgeCli {
                $script:ForgeProviders = @{
                    'fake' = @{ HostPatterns = @(); Commands = @{ 'Get-Issue' = 'Get-FakeIssue' } }
                }
            }

            [PSCustomObject]@{
                Dispatch        = & $Importer { Invoke-ImportedGetIssue -Forge fake }
                UnknownForge    = $(try { & $Importer { Invoke-ImportedGetIssue -Forge github } } catch { $_.FullyQualifiedErrorId })
                HelperInSession = [bool](Get-Command Resolve-ForgeCommand -ErrorAction SilentlyContinue)
                GlobalRegistry  = [bool](Get-Variable ForgeProviders -Scope Global -ErrorAction SilentlyContinue)
            } | ConvertTo-Json -Compress
        }
        $Command = "& { $Probe } '$PSScriptRoot/../src/ForgeCli/ForgeCli.psd1'"
        $script:Result = pwsh -NoProfile -NonInteractive -Command $Command | ConvertFrom-Json
    }

    It 'Should dispatch through its own helpers' {
        $Result.Dispatch | Should -Be 'dispatched to fake'
    }

    It 'Should validate -Forge against its own registry' {
        $Result.UnknownForge | Should -BeLike 'ParameterArgumentValidationError*'
    }

    It 'Should keep its helpers and registry out of the session' {
        $Result.HelperInSession | Should -BeFalse
        $Result.GlobalRegistry | Should -BeFalse
    }
}
