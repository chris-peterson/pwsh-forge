function Invoke-ForgeCommand {
    <#
    .SYNOPSIS
    Resolves the provider and invokes the target command.
    Used as a fallback for providers not in the known set.
    For known providers, each forge command has explicit inline mapping.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $TargetCommand,

        [Parameter()]
        [hashtable]
        $Parameters = @{}
    )

    $Cmd = Get-Command $TargetCommand -ErrorAction SilentlyContinue
    if (-not $Cmd) {
        throw "Command '$TargetCommand' is not available. Is the provider module loaded?"
    }

    # Pass through only parameters the target command accepts
    $ValidParams = @{}
    foreach ($Key in $Parameters.Keys) {
        if ($Cmd.Parameters.ContainsKey($Key)) {
            $ValidParams[$Key] = $Parameters[$Key]
        }
    }

    & $TargetCommand @ValidParams
}

function Resolve-ForgeCommand {
    <#
    .SYNOPSIS
    Resolves the provider and returns the target command name.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]
        $CommandName,

        [Parameter()]
        [string]
        $Provider
    )

    $Resolved = Resolve-ForgeProvider -Provider $Provider -CommandName $CommandName

    $TargetCommand = $Resolved.Commands[$CommandName]
    if (-not $TargetCommand) {
        $Available = ($Resolved.Commands.Keys | Sort-Object) -join ', '
        throw "Provider '$($Resolved.Name)' does not support '$CommandName'. Available: $Available"
    }

    [PSCustomObject]@{
        ProviderName = $Resolved.Name.ToLower()
        Command      = $TargetCommand
    }
}

# =============================================================================
# Unified Commands
# =============================================================================

function Get-Issue {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $Id,

        [Parameter()]
        [ValidateSet('open', 'closed', 'all')]
        [string]
        $State,

        [Parameter()]
        [switch]
        $Mine,

        [Parameter()]
        [string]
        $Group,

        [Parameter()]
        [string]
        $Assignee,

        [Parameter()]
        [string]
        $Author,

        [Parameter()]
        [string]
        $Labels,

        [Parameter()]
        [string]
        $Since,

        [Parameter()]
        [ValidateSet('created', 'updated', 'comments')]
        [string]
        $Sort,

        [Parameter()]
        [ValidateSet('asc', 'desc')]
        [string]
        $Direction,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-Issue' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Id)        { $Params.IssueNumber = $Id }
            if ($State)     { $Params.State        = $State }
            if ($Mine)      { $Params.Mine          = $true }
            if ($Group)     { $Params.Organization  = $Group }
            if ($Assignee)  { $Params.Assignee      = $Assignee }
            if ($Author)    { $Params.Creator        = $Author }
            if ($Labels)    { $Params.Labels         = $Labels }
            if ($Since)     { $Params.Since          = $Since }
            if ($Sort)      { $Params.Sort           = $Sort }
            if ($Direction) { $Params.Direction       = $Direction }
            if ($MaxPages)  { $Params.MaxPages       = $MaxPages }
            if ($All)       { $Params.All            = $true }
        }
        'gitlab' {
            if ($Id)        { $Params.IssueId          = $Id }
            if ($Mine)      { $Params.Mine              = $true }
            if ($Group)     { $Params.GroupId            = $Group }
            if ($Assignee)  { $Params.AssigneeUsername   = $Assignee }
            if ($Author)    { $Params.AuthorUsername     = $Author }
            if ($Since)     { $Params.CreatedAfter       = $Since }
            if ($MaxPages)  { $Params.MaxPages           = $MaxPages }
            if ($All)       { $Params.All                = $true }
            if ($State) {
                $Params.State = switch ($State) {
                    'open'   { 'opened' }
                    'closed' { 'closed' }
                    'all'    { $null }
                }
            }
            if ($Labels)    { Write-Warning "Get-Issue -Labels is not yet supported by the GitLab provider" }
            if ($Sort)      { Write-Warning "Get-Issue -Sort is not yet supported by the GitLab provider" }
            if ($Direction) { Write-Warning "Get-Issue -Direction is not yet supported by the GitLab provider" }
        }
        default {
            # Unknown provider: best-effort pass-through
            $AllParams = @{}
            if ($Id)        { $AllParams.Id        = $Id }
            if ($State)     { $AllParams.State     = $State }
            if ($Mine)      { $AllParams.Mine      = $true }
            if ($Group)     { $AllParams.Group     = $Group }
            if ($Assignee)  { $AllParams.Assignee  = $Assignee }
            if ($Author)    { $AllParams.Author    = $Author }
            if ($Labels)    { $AllParams.Labels    = $Labels }
            if ($Since)     { $AllParams.Since     = $Since }
            if ($Sort)      { $AllParams.Sort      = $Sort }
            if ($Direction) { $AllParams.Direction  = $Direction }
            if ($MaxPages)  { $AllParams.MaxPages  = $MaxPages }
            if ($All)       { $AllParams.All       = $true }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    & $Target.Command @Params
}

function Get-ChangeRequest {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $Id,

        [Parameter()]
        [ValidateSet('open', 'closed', 'all', 'merged')]
        [string]
        $State,

        [Parameter()]
        [switch]
        $Mine,

        [Parameter()]
        [string]
        $Group,

        [Parameter()]
        [Alias('Branch')]
        [string]
        $SourceBranch,

        [Parameter()]
        [string]
        $TargetBranch,

        [Parameter()]
        [string]
        $Author,

        [Parameter()]
        [switch]
        $IsDraft,

        [Parameter()]
        [string]
        $Since,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-ChangeRequest' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Id)           { $Params.PullRequestNumber = $Id }
            if ($State) {
                $Params.State = switch ($State) {
                    'open'   { 'open' }
                    'closed' { 'closed' }
                    'all'    { 'all' }
                    'merged' { 'closed' }
                }
                if ($State -eq 'merged') {
                    Write-Warning "GitHub does not have a 'merged' state filter; using 'closed' instead"
                }
            }
            if ($Mine)         { $Params.Mine      = $true }
            if ($SourceBranch) { $Params.Head       = $SourceBranch }
            if ($TargetBranch) { $Params.Base        = $TargetBranch }
            if ($MaxPages)     { $Params.MaxPages    = $MaxPages }
            if ($All)          { $Params.All         = $true }
            if ($Author)       { Write-Warning "Get-ChangeRequest -Author is not yet supported by the GitHub provider" }
            if ($IsDraft)      { Write-Warning "Get-ChangeRequest -IsDraft is not yet supported by the GitHub provider" }
            if ($Since)        { Write-Warning "Get-ChangeRequest -Since is not yet supported by the GitHub provider" }
        }
        'gitlab' {
            if ($Id)           { $Params.MergeRequestId = $Id }
            if ($Mine)         { $Params.Mine            = $true }
            if ($Group)        { $Params.GroupId          = $Group }
            if ($SourceBranch) { $Params.SourceBranch     = $SourceBranch }
            if ($Author)       { $Params.Username         = $Author }
            if ($IsDraft)      { $Params.IsDraft          = $true }
            if ($Since)        { $Params.CreatedAfter     = $Since }
            if ($MaxPages)     { $Params.MaxPages         = $MaxPages }
            if ($All)          { $Params.All              = $true }
            if ($State) {
                $Params.State = switch ($State) {
                    'open'   { 'opened' }
                    'closed' { 'closed' }
                    'all'    { 'all' }
                    'merged' { 'merged' }
                }
            }
            if ($TargetBranch) { Write-Warning "Get-ChangeRequest -TargetBranch is not yet supported by the GitLab provider" }
        }
        default {
            $AllParams = @{}
            if ($Id)           { $AllParams.Id           = $Id }
            if ($State)        { $AllParams.State        = $State }
            if ($Mine)         { $AllParams.Mine         = $true }
            if ($Group)        { $AllParams.Group        = $Group }
            if ($SourceBranch) { $AllParams.SourceBranch = $SourceBranch }
            if ($TargetBranch) { $AllParams.TargetBranch = $TargetBranch }
            if ($Author)       { $AllParams.Author       = $Author }
            if ($IsDraft)      { $AllParams.IsDraft      = $true }
            if ($Since)        { $AllParams.Since        = $Since }
            if ($MaxPages)     { $AllParams.MaxPages     = $MaxPages }
            if ($All)          { $AllParams.All          = $true }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    & $Target.Command @Params
}

function Get-Repo {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $Id,

        [Parameter()]
        [switch]
        $Mine,

        [Parameter()]
        [string]
        $Group,

        [Parameter()]
        [string]
        $Select,

        [Parameter()]
        [switch]
        $IncludeArchived,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-Repo' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Id)       { $Params.Repository   = $Id }
            if ($Mine)     { $Params.Mine          = $true }
            if ($Group)    { $Params.Organization  = $Group }
            if ($Select)   { $Params.Select        = $Select }
            if ($MaxPages) { $Params.MaxPages      = $MaxPages }
            if ($All)      { $Params.All           = $true }
            if ($IncludeArchived) { Write-Warning "Get-Repo -IncludeArchived is not applicable to GitHub" }
        }
        'gitlab' {
            if ($Id)       { $Params.ProjectId      = $Id }
            if ($Mine)     { $Params.Mine            = $true }
            if ($Group)    { $Params.GroupId          = $Group }
            if ($Select)   { $Params.Select          = $Select }
            if ($MaxPages) { $Params.MaxPages        = $MaxPages }
            if ($All)      { $Params.All             = $true }
            if ($IncludeArchived) { $Params.IncludeArchived = $true }
        }
        default {
            $AllParams = @{}
            if ($Id)              { $AllParams.Id              = $Id }
            if ($Mine)            { $AllParams.Mine            = $true }
            if ($Group)           { $AllParams.Group           = $Group }
            if ($Select)          { $AllParams.Select          = $Select }
            if ($IncludeArchived) { $AllParams.IncludeArchived = $true }
            if ($MaxPages)        { $AllParams.MaxPages        = $MaxPages }
            if ($All)             { $AllParams.All             = $true }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    & $Target.Command @Params
}
