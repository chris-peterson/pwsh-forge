$global:ForgeCommands = (Import-PowerShellDataFile "$PSScriptRoot/../ForgeCli.psd1").FunctionsToExport |
    Where-Object { $_ -notlike '*Forge*' }

$global:ForgeProviders = @{
    'github' = @{
        Module       = 'GithubCli'
        Prefix       = 'Github'
        HostPatterns = @('github')
        Resource     = @{
            'ChangeRequest' = 'PullRequest'
            'Group'         = 'Organization'
            'Repo'          = 'Repository'
        }
    }
    'gitlab' = @{
        Module       = 'GitlabCli'
        Prefix       = 'Gitlab'
        HostPatterns = @('gitlab')
        Resource     = @{
            'ChangeRequest' = 'MergeRequest'
            'Repo'          = 'Project'
        }
    }
}

foreach ($Key in $global:ForgeProviders.Keys) {
    $Provider = $global:ForgeProviders[$Key]
    $Commands = @{}
    foreach ($ForgeCommand in $global:ForgeCommands) {
        $Verb, $Noun = $ForgeCommand -split '-', 2
        $MappedNoun = if ($Provider.Resource.ContainsKey($Noun)) { $Provider.Resource[$Noun] } else { $Noun }
        $Commands[$ForgeCommand] = "$Verb-$($Provider.Prefix)$MappedNoun"
    }
    $Provider.Commands = $Commands
}

# Probe for installed provider modules and import them.
# Providers whose modules are not installed are removed from the registry.
foreach ($Key in @($global:ForgeProviders.Keys)) {
    $Provider = $global:ForgeProviders[$Key]
    $Module = $Provider.Module
    if (Get-Module -Name $Module) {
        Write-Verbose "Forge: provider '$Key' already loaded ($Module)"
    } elseif (Get-Module -ListAvailable -Name $Module) {
        Write-Verbose "Forge: loading provider '$Key' ($Module)"
        Import-Module $Module
    } else {
        Write-Verbose "Forge: provider '$Key' not available ($Module not installed)"
        $global:ForgeProviders.Remove($Key)
    }
}

Write-Verbose "Forge: $(($global:ForgeProviders.Keys) -join ', ') provider(s) registered"
