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
        # [ValidateSet([SupportedProvider])] <-- omitted on purpose, this is a key internal function
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
        Provider = $Resolved.Name
        Command  = $TargetCommand
    }
}

function Add-ChangeRequestBranchContract {
    <#
    .SYNOPSIS
    Applies the SourceBranch / TargetBranch contract to a change request from the
    named provider.

    .DESCRIPTION
    Gitlab merge requests already carry both properties, so this is a
    pass-through for every provider but Github.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject]
        $ChangeRequest,

        [Parameter(Mandatory)]
        [string]
        $Provider
    )

    process {
        if ($Provider -eq 'github') {
            $ChangeRequest | Add-GithubChangeRequestBranch
        } else {
            $ChangeRequest
        }
    }
}

# Weak keys, so an entry is collected along with the change request it describes.
$script:ForgeChangeRequestDetail = [System.Runtime.CompilerServices.ConditionalWeakTable[psobject, hashtable]]::new()

function Add-GithubChangeRequestBranch {
    <#
    .SYNOPSIS
    Adds the SourceBranch / TargetBranch contract properties to a Github change
    request.

    .DESCRIPTION
    TERMINOLOGY.md maps SourceBranch/TargetBranch to head.ref/base.ref, but a
    Github.PullRequest arrives in one of two shapes under the same type name. The
    pulls API supplies Head/Base; the search/issues API does not, and GithubCli
    switches to search for -Mine, for the cross-repo -Search set, and for the
    -Author, -IsDraft, -CreatedAfter/Before, -MergedAfter/Before, -ReviewedBy and
    -State merged filters. Resolving the missing refs costs one API call per pull
    request, so it happens on first read rather than for every result. The default
    table view does not read these properties, but Format-List, Select-Object *
    and ConvertTo-Json read both, and pay one serial call per request.

    The resolved detail is held in $script:ForgeChangeRequestDetail rather than on
    the change request itself, so it stays out of ConvertTo-Json and Export-Csv
    output. A refusal is recorded there too and reported as a warning: PowerShell
    discards an exception thrown from a ScriptProperty getter, so a failed resolve
    would otherwise be indistinguishable from a request with no branch, and would
    be retried on every read.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject]
        $ChangeRequest
    )

    process {
        foreach ($Pair in @(
            @{ Name = 'SourceBranch'; Ref = 'Head' },
            @{ Name = 'TargetBranch'; Ref = 'Base' }
        )) {
            $RefName = $Pair.Ref
            $ChangeRequest | Add-Member -MemberType ScriptProperty -Name $Pair.Name -Force -Value ([scriptblock]::Create(@"
                if (`$this.$RefName) { return `$this.$RefName.Ref }
                `$Entry = `$script:ForgeChangeRequestDetail.GetValue(`$this, { @{ Resolved = `$false; Detail = `$null; Failure = `$null } })
                if (-not `$Entry.Resolved) {
                    `$Entry.Resolved = `$true
                    if (`$this.ProjectPath -and `$this.Number) {
                        try {
                            `$Entry.Detail = Get-GithubPullRequest -RepositoryId `$this.ProjectPath -PullRequestId `$this.Number -ErrorAction Stop
                        } catch {
                            `$Entry.Failure = "Could not resolve branch refs for `$(`$this.ProjectPath)#`$(`$this.Number): `$(`$_.Exception.Message)"
                        }
                    }
                }
                if (`$Entry.Failure) {
                    Write-Warning `$Entry.Failure
                    return
                }
                `$Entry.Detail.$RefName.Ref
"@))
        }
        $ChangeRequest
    }
}

function Resolve-ForgeProvider {
    [CmdletBinding()]
    param(
        [Parameter()]
        [string]
        $Provider,

        [Parameter()]
        [string]
        $CommandName
    )

    $Resolved = $null

    # '.' means explicitly infer from git remote
    if ($Provider -eq '.') { $Provider = '' }

    # Explicit provider override
    if ($Provider) {
        $Key = $Provider.ToLower()
        if ($global:ForgeProviders.ContainsKey($Key)) {
            $Resolved = $global:ForgeProviders[$Key]
        } else {
            throw "Unknown provider: '$Provider'"
        }
    } else {
        # Auto-detect from git remote
        $Context = Get-ForgeRemoteHost
        if (-not $Context.Host) {
            throw @"
Could not detect a forge provider from the current directory.
Either cd into a git repository, or specify a provider:
  $CommandName -Forge github
  $CommandName -Forge gitlab
"@
        }

        # Match against registered providers
        foreach ($Key in $global:ForgeProviders.Keys) {
            $Registered = $global:ForgeProviders[$Key]
            foreach ($Pattern in $Registered.HostPatterns) {
                if ($Context.Host -match $Pattern) {
                    $Resolved = $Registered
                    break
                }
            }
            if ($Resolved) { break }
        }

        if (-not $Resolved) {
            $SupportedList = ($global:ForgeProviders.Keys) -join ', '
            throw @"
Unrecognized forge host: '$($Context.Host)'
Currently supported: $SupportedList
"@
        }
    }

    $Resolved.Name = $Key
    return $Resolved
}
