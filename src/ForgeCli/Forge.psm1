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
        [ValidateSet([SupportedProvider])]
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
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-Issue' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Id)        { $Params.IssueId     = $Id }
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
            if ($Labels)    { Write-Warning "Get-Issue -Labels is not yet supported by the Gitlab provider" }
            if ($Sort)      { Write-Warning "Get-Issue -Sort is not yet supported by the Gitlab provider" }
            if ($Direction) { Write-Warning "Get-Issue -Direction is not yet supported by the Gitlab provider" }
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
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-ChangeRequest' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Id)           { $Params.PullRequestId     = $Id }
            if ($State) {
                $Params.State = switch ($State) {
                    'open'   { 'open' }
                    'closed' { 'closed' }
                    'all'    { 'all' }
                    'merged' { 'closed' }
                }
                if ($State -eq 'merged') {
                    Write-Warning "Github does not have a 'merged' state filter; using 'closed' instead"
                }
            }
            if ($Mine)         { $Params.Mine      = $true }
            if ($SourceBranch) { $Params.Head       = $SourceBranch }
            if ($TargetBranch) { $Params.Base        = $TargetBranch }
            if ($MaxPages)     { $Params.MaxPages    = $MaxPages }
            if ($All)          { $Params.All         = $true }
            if ($Author)       { Write-Warning "Get-ChangeRequest -Author is not yet supported by the Github provider" }
            if ($IsDraft)      { Write-Warning "Get-ChangeRequest -IsDraft is not yet supported by the Github provider" }
            if ($Since)        { Write-Warning "Get-ChangeRequest -Since is not yet supported by the Github provider" }
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
            if ($TargetBranch) { Write-Warning "Get-ChangeRequest -TargetBranch is not yet supported by the Gitlab provider" }
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

function Get-Branch {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $Name,

        [Parameter()]
        [switch]
        $Protected,

        [Parameter()]
        [string]
        $Search,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-Branch' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Name)      { $Params.Name      = $Name }
            if ($Protected) { $Params.Protected  = $true }
            if ($MaxPages)  { $Params.MaxPages   = $MaxPages }
            if ($All)       { $Params.All        = $true }
            if ($Search)    { Write-Warning "Get-Branch -Search is not supported by the Github provider; use -Name for exact match" }
        }
        'gitlab' {
            if ($Name)      { $Params.Ref        = $Name }
            if ($Search)    { $Params.Search     = $Search }
            if ($MaxPages)  { $Params.MaxPages   = $MaxPages }
            if ($All)       { $Params.All        = $true }
            if ($Protected) { Write-Warning "Get-Branch -Protected is not supported by the Gitlab provider; use Get-GitlabProtectedBranch" }
        }
        default {
            $AllParams = @{}
            if ($Name)      { $AllParams.Name      = $Name }
            if ($Protected) { $AllParams.Protected  = $true }
            if ($Search)    { $AllParams.Search     = $Search }
            if ($MaxPages)  { $AllParams.MaxPages   = $MaxPages }
            if ($All)       { $AllParams.All        = $true }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    & $Target.Command @Params
}

function Get-Release {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $Tag,

        [Parameter()]
        [switch]
        $Latest,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-Release' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Tag)      { $Params.Tag      = $Tag }
            if ($Latest)   { $Params.Latest   = $true }
            if ($MaxPages) { $Params.MaxPages = $MaxPages }
            if ($All)      { $Params.All      = $true }
        }
        'gitlab' {
            if ($Tag)      { $Params.Tag      = $Tag }
            if ($MaxPages) { $Params.MaxPages = $MaxPages }
            if ($All)      { $Params.All      = $true }
            if ($Latest)   { Write-Warning "Get-Release -Latest is not supported by the Gitlab provider" }
        }
        default {
            $AllParams = @{}
            if ($Tag)      { $AllParams.Tag      = $Tag }
            if ($Latest)   { $AllParams.Latest   = $true }
            if ($MaxPages) { $AllParams.MaxPages = $MaxPages }
            if ($All)      { $AllParams.All      = $true }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    & $Target.Command @Params
}

function Get-User {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $Username,

        [Parameter()]
        [switch]
        $Me,

        [Parameter()]
        [string]
        $Select,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-User' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Username) { $Params.Username = $Username }
            if ($Me)       { $Params.Me       = $true }
            if ($Select)   { $Params.Select   = $Select }
        }
        'gitlab' {
            if ($Username) { $Params.UserId   = $Username }
            if ($Me)       { $Params.Me       = $true }
            if ($Select)   { $Params.Select   = $Select }
        }
        default {
            $AllParams = @{}
            if ($Username) { $AllParams.Username = $Username }
            if ($Me)       { $AllParams.Me       = $true }
            if ($Select)   { $AllParams.Select   = $Select }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    & $Target.Command @Params
}

function Get-Group {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $Name,

        [Parameter()]
        [switch]
        $Mine,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-Group' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Name)     { $Params.Name     = $Name }
            if ($Mine)     { $Params.Mine     = $true }
            if ($MaxPages) { $Params.MaxPages = $MaxPages }
            if ($All)      { $Params.All      = $true }
        }
        'gitlab' {
            if ($Name)     { $Params.GroupId  = $Name }
            if ($MaxPages) { $Params.MaxPages = $MaxPages }
            if ($All)      { $Params.All      = $true }
            if ($Mine)     { Write-Warning "Get-Group -Mine is not directly supported by the Gitlab provider" }
        }
        default {
            $AllParams = @{}
            if ($Name)     { $AllParams.Name     = $Name }
            if ($Mine)     { $AllParams.Mine     = $true }
            if ($MaxPages) { $AllParams.MaxPages = $MaxPages }
            if ($All)      { $AllParams.All      = $true }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    & $Target.Command @Params
}

function New-Issue {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]
        $Title,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [string[]]
        $Assignees,

        [Parameter()]
        [string[]]
        $Labels,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'New-Issue' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            $Params.Title = $Title
            if ($Description) { $Params.Description = $Description }
            if ($Assignees)   { $Params.Assignees   = $Assignees }
            if ($Labels)      { $Params.Labels      = $Labels }
        }
        'gitlab' {
            $Params.Title = $Title
            if ($Description) { $Params.Description = $Description }
            if ($Assignees)   { Write-Warning "New-Issue -Assignees is not yet supported by the Gitlab provider" }
            if ($Labels)      { $Params.Labels      = $Labels -join ',' }
        }
        default {
            $AllParams = @{ Title = $Title }
            if ($Description) { $AllParams.Description = $Description }
            if ($Assignees)   { $AllParams.Assignees   = $Assignees }
            if ($Labels)      { $AllParams.Labels      = $Labels }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    if ($PSCmdlet.ShouldProcess($Title, 'Create Issue')) {
        & $Target.Command @Params
    }
}

function Update-Issue {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Id,

        [Parameter()]
        [string]
        $Title,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [ValidateSet('open', 'closed')]
        [string]
        $State,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Update-Issue' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            $Params.IssueId = $Id
            if ($Title)       { $Params.Title       = $Title }
            if ($Description) { $Params.Description = $Description }
            if ($State)       { $Params.State       = $State }
        }
        'gitlab' {
            $Params.IssueId = $Id
            if ($Title)       { $Params.Title       = $Title }
            if ($Description) { $Params.Description = $Description }
            if ($State) {
                $Params.StateEvent = switch ($State) {
                    'open'   { 'reopen' }
                    'closed' { 'close' }
                }
            }
        }
        default {
            $AllParams = @{ Id = $Id }
            if ($Title)       { $AllParams.Title       = $Title }
            if ($Description) { $AllParams.Description = $Description }
            if ($State)       { $AllParams.State       = $State }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    if ($PSCmdlet.ShouldProcess($Id, 'Update Issue')) {
        & $Target.Command @Params
    }
}

function Close-Issue {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Id,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Close-Issue' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            $Params.IssueId = $Id
        }
        'gitlab' {
            $Params.IssueId = $Id
        }
        default {
            $AllParams = @{ Id = $Id }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    if ($PSCmdlet.ShouldProcess("Issue #$Id", 'Close')) {
        & $Target.Command @Params
    }
}

function New-ChangeRequest {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]
        $Title,

        [Parameter(Mandatory)]
        [Alias('Branch', 'Head')]
        [string]
        $SourceBranch,

        [Parameter()]
        [Alias('Base')]
        [string]
        $TargetBranch,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [switch]
        $Draft,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'New-ChangeRequest' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            $Params.Title        = $Title
            $Params.SourceBranch = $SourceBranch
            if ($TargetBranch) { $Params.TargetBranch = $TargetBranch }
            if ($Description)  { $Params.Description  = $Description }
            if ($Draft)        { $Params.Draft        = $true }
        }
        'gitlab' {
            $Params.Title        = $Title
            $Params.SourceBranch = $SourceBranch
            if ($TargetBranch) { $Params.TargetBranch = $TargetBranch }
            if ($Description)  { $Params.Description  = $Description }
            if ($Draft)        { Write-Warning "New-ChangeRequest -Draft is not yet supported by the Gitlab provider" }
        }
        default {
            $AllParams = @{
                Title        = $Title
                SourceBranch = $SourceBranch
            }
            if ($TargetBranch) { $AllParams.TargetBranch = $TargetBranch }
            if ($Description)  { $AllParams.Description  = $Description }
            if ($Draft)        { $AllParams.Draft        = $true }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    if ($PSCmdlet.ShouldProcess("$SourceBranch -> $TargetBranch", 'Create Change Request')) {
        & $Target.Command @Params
    }
}

function Merge-ChangeRequest {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Id,

        [Parameter()]
        [switch]
        $Squash,

        [Parameter()]
        [switch]
        $DeleteSourceBranch,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Merge-ChangeRequest' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            $Params.PullRequestId = $Id
            if ($Squash)             { $Params.MergeMethod        = 'squash' }
            if ($DeleteSourceBranch) { $Params.DeleteSourceBranch = $true }
        }
        'gitlab' {
            $Params.MergeRequestId = $Id
            if ($Squash)             { $Params.Squash                   = $true }
            if ($DeleteSourceBranch) { $Params.ShouldRemoveSourceBranch = $true }
        }
        default {
            $AllParams = @{ Id = $Id }
            if ($Squash)             { $AllParams.Squash             = $true }
            if ($DeleteSourceBranch) { $AllParams.DeleteSourceBranch = $true }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    if ($PSCmdlet.ShouldProcess("Change Request #$Id", 'Merge')) {
        & $Target.Command @Params
    }
}

function New-Repo {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Name,

        [Parameter()]
        [string]
        $Description,

        [Parameter()]
        [ValidateSet('public', 'private')]
        [string]
        $Visibility,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'New-Repo' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            $Params.Name = $Name
            if ($Description) { $Params.Description = $Description }
            if ($Visibility)  { $Params.Visibility  = $Visibility }
        }
        'gitlab' {
            $Params.Name = $Name
            if ($Description) { $Params.Description = $Description }
            if ($Visibility)  { $Params.Visibility  = $Visibility }
        }
        default {
            $AllParams = @{ Name = $Name }
            if ($Description) { $AllParams.Description = $Description }
            if ($Visibility)  { $AllParams.Visibility  = $Visibility }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    if ($PSCmdlet.ShouldProcess($Name, 'Create Repository')) {
        & $Target.Command @Params
    }
}

function Get-Commit {
    [CmdletBinding()]
    param(
        [Parameter(Position=0)]
        [string]
        $Ref,

        [Parameter()]
        [string]
        $Branch,

        [Parameter()]
        [string]
        $Author,

        [Parameter()]
        [string]
        $Since,

        [Parameter()]
        [string]
        $Until,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-Commit' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Ref)      { $Params.Sha      = $Ref }
            if ($Branch)   { $Params.Branch   = $Branch }
            if ($Author)   { $Params.Author   = $Author }
            if ($Since)    { $Params.Since    = $Since }
            if ($Until)    { $Params.Until    = $Until }
            if ($MaxPages) { $Params.MaxPages = $MaxPages }
            if ($All)      { $Params.All      = $true }
        }
        'gitlab' {
            if ($Ref)      { $Params.Sha      = $Ref }
            if ($Branch)   { $Params.Ref      = $Branch }
            if ($MaxPages) { $Params.MaxPages = $MaxPages }
            if ($All)      { $Params.All      = $true }
            if ($Author)   { Write-Warning "Get-Commit -Author is not yet supported by the Gitlab provider" }
            if ($Since)    { Write-Warning "Get-Commit -Since is not yet supported by the Gitlab provider" }
            if ($Until)    { Write-Warning "Get-Commit -Until is not yet supported by the Gitlab provider" }
        }
        default {
            $AllParams = @{}
            if ($Ref)      { $AllParams.Ref      = $Ref }
            if ($Branch)   { $AllParams.Branch   = $Branch }
            if ($Author)   { $AllParams.Author   = $Author }
            if ($Since)    { $AllParams.Since    = $Since }
            if ($Until)    { $AllParams.Until    = $Until }
            if ($MaxPages) { $AllParams.MaxPages = $MaxPages }
            if ($All)      { $AllParams.All      = $true }
            Invoke-ForgeCommand -TargetCommand $Target.Command -Parameters $AllParams
            return
        }
    }

    & $Target.Command @Params
}

function Search-Repo {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Query,

        [Parameter()]
        [ValidateSet('code', 'commits', 'issues')]
        [string]
        $Scope,

        [Parameter()]
        [uint]
        $MaxPages,

        [switch]
        [Parameter()]
        $All,

        [Parameter()]
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Search-Repo' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            $Params.Query = $Query
            if ($Scope)    { $Params.Scope    = $Scope }
            if ($MaxPages) { $Params.MaxPages = $MaxPages }
            if ($All)      { $Params.All      = $true }
        }
        'gitlab' {
            $Params.Search = $Query
            if ($MaxPages) { $Params.MaxPages = $MaxPages }
            if ($All)      { $Params.All      = $true }
            if ($Scope)    { Write-Warning "Search-Repo -Scope is not yet supported by the Gitlab provider" }
        }
        default {
            $AllParams = @{ Query = $Query }
            if ($Scope)    { $AllParams.Scope    = $Scope }
            if ($MaxPages) { $AllParams.MaxPages = $MaxPages }
            if ($All)      { $AllParams.All      = $true }
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
        [ValidateSet([SupportedProvider])]
        [string]
        $Provider
    )

    $Target = Resolve-ForgeCommand -CommandName 'Get-Repo' -Provider $Provider
    $Params = @{}

    switch ($Target.ProviderName) {
        'github' {
            if ($Id)       { $Params.RepositoryId  = $Id }
            if ($Mine)     { $Params.Mine          = $true }
            if ($Group)    { $Params.Organization  = $Group }
            if ($Select)   { $Params.Select        = $Select }
            if ($MaxPages) { $Params.MaxPages      = $MaxPages }
            if ($All)      { $Params.All           = $true }
            if ($IncludeArchived) { Write-Warning "Get-Repo -IncludeArchived is not applicable to Github" }
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
