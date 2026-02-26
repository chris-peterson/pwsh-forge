$global:ForgeCommands = (Import-PowerShellDataFile "$PSScriptRoot/../ForgeCli.psd1").FunctionsToExport

$global:ForgeProviders = @{
    'github' = @{
        Module       = 'GithubCli'
        Prefix       = 'Github'
        HostPatterns = @('github')
        Resource     = @{
            'Branch'               = 'Branch'
            'ChangeRequest'        = 'PullRequest'
            'ChangeRequestComment' = 'PullRequestComment'
            'Commit'               = 'Commit'
            'Group'                = 'Organization'
            'GroupMember'          = 'OrganizationMember'
            'Issue'                = 'Issue'
            'IssueComment'         = 'IssueComment'
            'Milestone'            = 'Milestone'
            'Release'              = 'Release'
            'Repo'                 = 'Repository'
            'User'                 = 'User'
        }
    }
    'gitlab' = @{
        Module       = 'GitlabCli'
        Prefix       = 'Gitlab'
        HostPatterns = @('gitlab')
        Resource     = @{
            'Branch'               = 'Branch'
            'ChangeRequest'        = 'MergeRequest'
            'ChangeRequestComment' = 'MergeRequestNote'
            'Commit'               = 'Commit'
            'Group'                = 'Group'
            'GroupMember'          = 'GroupMember'
            'Issue'                = 'Issue'
            'IssueComment'         = 'IssueNote'
            'Milestone'            = 'Milestone'
            'Release'              = 'Release'
            'Repo'                 = 'Project'
            'User'                 = 'User'
        }
    }
}

foreach ($Key in $global:ForgeProviders.Keys) {
    $Provider = $global:ForgeProviders[$Key]
    $Commands = @{}
    foreach ($ForgeCommand in $global:ForgeCommands) {
        $Verb, $Noun = $ForgeCommand -split '-', 2
        $MappedNoun = $Provider.Resource[$Noun]
        if (-not $MappedNoun) {
            throw "Forge command '$ForgeCommand' uses noun '$Noun' which is not mapped in the '$Key' provider. Add it to the Resource table in Init.psm1."
        }
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
