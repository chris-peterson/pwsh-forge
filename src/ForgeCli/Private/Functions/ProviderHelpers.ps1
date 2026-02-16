function Find-ForgeProviders {
    <#
    .SYNOPSIS
    Scans for loaded provider modules and registers them.

    .DESCRIPTION
    Checks each known provider's module name against loaded modules
    and registers any that are found. Handles the case where a
    provider was imported before ForgeCli.
    #>
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '', Justification = 'Discovers multiple providers')]
    [CmdletBinding()]
    [OutputType([void])]
    param()

    foreach ($Key in $global:ForgeKnownProviders.Keys) {
        if ($global:ForgeProviders.ContainsKey($Key)) {
            continue
        }

        $Known = $global:ForgeKnownProviders[$Key]
        $LoadedModule = Get-Module $Known.ModuleName -ErrorAction SilentlyContinue

        if ($LoadedModule) {
            Write-Verbose "ForgeCli: Discovered loaded module '$($Known.ModuleName)', registering..."
            $global:ForgeProviders[$Key] = @{
                Name         = $Known.Name
                HostPatterns = $Known.HostPatterns
                Commands     = $Known.Commands
            }
        }
    }
}

function Get-ForgeProvider {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param()

    Find-ForgeProviders

    if ($global:ForgeProviders.Count -eq 0) {
        Write-Warning "No forge providers are registered."
        Write-Warning "Install and import a provider module:"
        Write-Warning ""
        foreach ($Key in $global:ForgeKnownProviders.Keys) {
            $Known = $global:ForgeKnownProviders[$Key]
            Write-Warning "  $($Known.Name): $($Known.InstallHint)"
        }
        return
    }

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

    # Auto-discover any providers that loaded before forge did
    Find-ForgeProviders

    # Explicit provider override
    if ($Provider) {
        $Key = $Provider.ToLower()
        if ($global:ForgeProviders.ContainsKey($Key)) {
            return $global:ForgeProviders[$Key]
        }

        $Known = $global:ForgeKnownProviders[$Key]
        if ($Known) {
            throw @"
The $($Known.Name) provider is not loaded.
  $($Known.InstallHint)
  Import-Module $($Known.ModuleName)
"@
        }

        throw @"
Unknown provider: '$Provider'
Registered providers: $($global:ForgeProviders.Keys -join ', ')
Request support: https://github.com/chris-peterson/pwsh-forge/issues
"@
    }

    # Auto-detect from git remote
    $Context = Get-ForgeRemoteHost
    if (-not $Context.Host) {
        if ($global:ForgeProviders.Count -eq 0) {
            throw @"
Not in a git repository, and no forge providers are installed.
To get started, install a provider:

$($global:ForgeKnownProviders.Values | ForEach-Object { "  $($_.InstallHint)" } | Out-String)
"@
        }
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

    # Match against known (but not installed) providers
    foreach ($Key in $global:ForgeKnownProviders.Keys) {
        $Known = $global:ForgeKnownProviders[$Key]
        foreach ($Pattern in $Known.HostPatterns) {
            if ($Context.Host -match $Pattern) {
                throw @"
This is a $($Known.Name) repository, but the $($Known.Name) provider is not loaded.
  $($Known.InstallHint)
  Import-Module $($Known.ModuleName)
"@
            }
        }
    }

    # Truly unknown host
    $SupportedList = ($global:ForgeKnownProviders.Values | ForEach-Object { $_.Name }) -join ', '
    throw @"
Unrecognized forge host: '$($Context.Host)'
Currently supported: $SupportedList
Request support: https://github.com/chris-peterson/pwsh-forge/issues
"@
}
