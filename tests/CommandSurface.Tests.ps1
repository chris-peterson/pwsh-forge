BeforeAll {
    # A dot-sourced script resets $PSScriptRoot, so resolve the source root first
    $Src = "$PSScriptRoot/../src/ForgeCli"
    . $PSScriptRoot/Support/Markdown.ps1
    . $Src/Private/Init.ps1

    function Build-CommandSurfaceTable {
        $ProviderKeys = $script:ForgeProviders.Keys | Sort-Object
        $Headers = @('ForgeCli Command') + ($ProviderKeys | ForEach-Object {
            "$((Get-Culture).TextInfo.ToTitleCase($_)) Provider"
        })

        $Rows = foreach ($Command in ($script:ForgeCommands | Sort-Object)) {
            $Cells = @("``$Command``")
            foreach ($Key in $ProviderKeys) {
                $Cells += "``$($script:ForgeProviders[$Key].Commands[$Command])``"
            }
            , $Cells
        }

        Format-MarkdownTable $Headers $Rows
    }
}

Describe "Command Surface" {

    It "Every provider should have identical Resource keys" {
        $ExpectedKeys = $script:ForgeProviders.Values.Resource.Keys | Sort-Object -Unique
        foreach ($Key in $script:ForgeProviders.Keys) {
            $ActualKeys = $script:ForgeProviders[$Key].Resource.Keys | Sort-Object
            $ActualKeys | Should -Be $ExpectedKeys -Because "provider '$Key' Resource keys should be consistent"
        }
    }

    It "Every provider should map every forge command" {
        $Missing = @()
        foreach ($ProviderKey in $script:ForgeProviders.Keys) {
            $Provider = $script:ForgeProviders[$ProviderKey]
            foreach ($Command in $script:ForgeCommands) {
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
