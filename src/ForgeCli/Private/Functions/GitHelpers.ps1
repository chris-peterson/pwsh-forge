function Get-ForgeRemoteHost {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param (
        [string]
        [Parameter()]
        $Path = '.'
    )

    $Context = [PSCustomObject]@{
        Host   = ''
        Branch = ''
    }
    if($(Get-Location).Provider.Name -ne 'FileSystem') {
        return $Context
    }

    Push-Location

    try {
        Set-Location $Path
        $GitDir = git rev-parse --git-dir 2>$null
        if ($GitDir -and (Test-Path -Path $GitDir)) {
            $OriginUrl = git config --get remote.origin.url
            if (-not $OriginUrl) {
                return $Context
            }

            # Extract host from remote URL
            # https://github.com/owner/repo.git
            # git@github.com:owner/repo.git
            try {
                $Uri = [Uri]::new($OriginUrl)
                $Context.Host = $Uri.Host
            }
            catch {
                if ($OriginUrl -match '@(?<Host>[^:/]+)[:/]') {
                    $Context.Host = $Matches.Host
                }
            }

            $Ref = git status | Select-String "^HEAD detached at (?<sha>.{7,40})|^On branch (?<branch>.*)"
            if ($Ref -and $Ref.Matches) {
                if ($Ref.Matches[0].Groups["branch"].Success) {
                    $Context.Branch = $Ref.Matches[0].Groups["branch"].Value
                } else {
                    $Context.Branch = "Detached HEAD"
                }
            }
        }
    }
    finally {
        Pop-Location
    }

    $Context
}
