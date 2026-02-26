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
  $CommandName -Provider github
  $CommandName -Provider gitlab
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
