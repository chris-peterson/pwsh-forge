function Get-ForgeProvider {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    foreach ($Key in $global:ForgeProviders.Keys) {
        $Provider = $global:ForgeProviders[$Key]
        [PSCustomObject]@{
            Name         = $Provider.Name
            HostPatterns = $Provider.HostPatterns -join ', '
            Commands     = ($Provider.Commands.Keys | Sort-Object) -join ', '
        }
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

    # Explicit provider override
    if ($Provider) {
        $Key = $Provider.ToLower()
        if ($global:ForgeProviders.ContainsKey($Key)) {
            return $global:ForgeProviders[$Key]
        }
        throw "Unknown provider: '$Provider'"
    }

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
                return $Registered
            }
        }
    }

    $SupportedList = ($global:ForgeProviders.Values | ForEach-Object { $_.Name }) -join ', '
    throw @"
Unrecognized forge host: '$($Context.Host)'
Currently supported: $SupportedList
"@
}
