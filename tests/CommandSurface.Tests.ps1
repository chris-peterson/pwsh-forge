BeforeAll {
    . $PSScriptRoot/../src/ForgeCli/Private/Validations.ps1
    Import-Module $PSScriptRoot/../src/ForgeCli/Private/Init.psm1 -Force
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/GitHelpers.ps1
    . $PSScriptRoot/../src/ForgeCli/Private/Functions/ProviderHelpers.ps1

    function Build-CommandSurfaceTable {
        $ProviderKeys = $global:ForgeProviders.Keys | Sort-Object
        $Headers = @('ForgeCli Command') + ($ProviderKeys | ForEach-Object {
            "$((Get-Culture).TextInfo.ToTitleCase($_)) Provider"
        })

        # Compute column widths from headers and data
        $Rows = foreach ($Command in ($global:ForgeCommands | Sort-Object)) {
            $Cells = @($Command)
            foreach ($Key in $ProviderKeys) {
                $Cells += $global:ForgeProviders[$Key].Commands[$Command]
            }
            , $Cells
        }
        $ColWidths = @()
        for ($i = 0; $i -lt $Headers.Count; $i++) {
            $Max = ($Headers[$i]).Length
            foreach ($Row in $Rows) {
                $Len = "``$($Row[$i])``".Length
                if ($Len -gt $Max) { $Max = $Len }
            }
            $ColWidths += $Max
        }

        $Lines = @()

        # Header
        $HeaderCells = for ($i = 0; $i -lt $Headers.Count; $i++) {
            $Headers[$i].PadRight($ColWidths[$i])
        }
        $Lines += '| {0} |' -f ($HeaderCells -join ' | ')

        # Separator
        $SepCells = for ($i = 0; $i -lt $Headers.Count; $i++) {
            '-' * $ColWidths[$i]
        }
        $Lines += '|{0}|' -f (($SepCells | ForEach-Object { "-$_-" }) -join '|')

        # Data rows
        foreach ($Row in $Rows) {
            $DataCells = for ($i = 0; $i -lt $Row.Count; $i++) {
                "``$($Row[$i])``".PadRight($ColWidths[$i])
            }
            $Lines += '| {0} |' -f ($DataCells -join ' | ')
        }

        $Lines -join "`n"
    }
}

Describe "Command Surface" {

    It "Every provider should map every forge command" {
        $Missing = @()
        foreach ($ProviderKey in $global:ForgeProviders.Keys) {
            $Provider = $global:ForgeProviders[$ProviderKey]
            foreach ($Command in $global:ForgeCommands) {
                if (-not $Provider.Commands[$Command]) {
                    $Missing += "$ProviderKey`: $Command"
                }
            }
        }
        $Missing | Should -BeNullOrEmpty
    }

    It "TERMINOLOGY.md command surface table should match generated mappings" {
        $Expected = Build-CommandSurfaceTable

        $DocPath = "$PSScriptRoot/../TERMINOLOGY.md"
        $DocContent = Get-Content $DocPath -Raw

        # Extract consecutive pipe-delimited lines from the Unified Command Surface section
        if ($DocContent -match '(?m)## Unified Command Surface[\s\S]*?(?<table>\|[^\r\n]+\|(\r?\n\|[^\r\n]+\|)*)') {
            $Actual = $Matches['table'].TrimEnd()
        } else {
            $Actual = ''
        }

        if ($Actual -ne $Expected) {
            Write-Host "`nGenerated table (copy to TERMINOLOGY.md):`n" -ForegroundColor Yellow
            Write-Host $Expected
            Write-Host ""
        }

        $Actual | Should -Be $Expected
    }
}
