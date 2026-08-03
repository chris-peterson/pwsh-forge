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

function Add-GithubChangeRequestBranch {
    <#
    .SYNOPSIS
    Adds the SourceBranch / TargetBranch contract properties to a Github change
    request.

    .DESCRIPTION
    TERMINOLOGY.md maps SourceBranch/TargetBranch to head.ref/base.ref, but a
    Github.PullRequest arrives in one of two shapes under the same type name:
    the pulls API supplies Head/Base, while the issues-search path behind -Mine
    does not. Resolving the missing refs costs one API call per pull request, so
    it happens on first read rather than for every result.
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
                if (-not `$this.PSObject.Properties['__ForgeDetail']) {
                    `$Detail = if (`$this.ProjectPath -and `$this.Number) {
                        Get-GithubPullRequest -RepositoryId `$this.ProjectPath -PullRequestId `$this.Number
                    }
                    `$this | Add-Member -MemberType NoteProperty -Name '__ForgeDetail' -Value `$Detail -Force
                }
                `$this.__ForgeDetail.$RefName.Ref
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
