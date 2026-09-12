BeforeAll {
    $Script = "$PSScriptRoot/../build/Update-ReleaseArtifacts.ps1"

    # A literal '$' in the body guards the verbatim-notes path through both writes.
    $DefaultUnreleased = "### Features`n- Added `$special"

    function New-Fixtures($Unreleased = $DefaultUnreleased) {
        $Dir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
        New-Item -ItemType Directory -Path $Dir | Out-Null

        $Manifest = @"
@{
    ModuleVersion = '0.12.0'

    PrivateData = @{
        PSData = @{
            ReleaseNotes =
@'
### Features
* ``Get-ChangeRequest`` gains ``-MergedAfter`` / ``-MergedBefore``.
'@
        }
    }

    GUID = 'f0f1f2f3-a4b5-c6d7-e8f9-0a1b2c3d4e5f'
}
"@
        $ManifestPath = Join-Path $Dir 'ForgeCli.psd1'
        [System.IO.File]::WriteAllText($ManifestPath, $Manifest)

        $ChangelogPath = Join-Path $Dir 'CHANGELOG.md'
        [System.IO.File]::WriteAllText($ChangelogPath, @"
# Changelog

All notable changes to ForgeCli are recorded here, newest first.

## [Unreleased]

$Unreleased

## [0.12.0] - 2026-04-21

### Features
* ``Get-ChangeRequest`` gains ``-MergedAfter`` / ``-MergedBefore``.
"@)

        [pscustomobject]@{
            Dir           = $Dir
            ManifestPath  = $ManifestPath
            ChangelogPath = $ChangelogPath
        }
    }

    function Remove-Fixtures($Fixtures) {
        [System.IO.Directory]::Delete($Fixtures.Dir, $true)
    }
}

Describe 'Update-ReleaseArtifacts' {

    Context 'Manifest updates' {
        BeforeEach { $Fixtures = New-Fixtures }
        AfterEach { Remove-Fixtures $Fixtures }

        It 'Sets ModuleVersion, stripping a leading v' {
            & $Script -Version 'v0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12'
            (Import-PowerShellDataFile -Path $Fixtures.ManifestPath).ModuleVersion | Should -Be '0.13.0'
        }

        It 'Takes its ReleaseNotes from Unreleased, verbatim, including literal dollar signs' {
            & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12'
            $Notes = (Import-PowerShellDataFile -Path $Fixtures.ManifestPath).PrivateData.PSData.ReleaseNotes
            $Notes | Should -Be $DefaultUnreleased
        }

        It 'Stores the same text the promoted changelog section gets' {
            & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12'
            $Notes = (Import-PowerShellDataFile -Path $Fixtures.ManifestPath).PrivateData.PSData.ReleaseNotes
            $Section = [regex]::Match(
                (Get-Content $Fixtures.ChangelogPath -Raw),
                '(?s)## \[0\.13\.0\] - 2026-09-12\n\n(?<body>.*?)\n\n## \[0\.12\.0\]')
            $Section.Groups['body'].Value | Should -Be $Notes
        }

        It 'Leaves a manifest PowerShell can still parse' {
            & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12'
            (Import-PowerShellDataFile -Path $Fixtures.ManifestPath).GUID | Should -Be 'f0f1f2f3-a4b5-c6d7-e8f9-0a1b2c3d4e5f'
        }
    }

    Context 'CHANGELOG promotion' {
        BeforeEach { $Fixtures = New-Fixtures }
        AfterEach { Remove-Fixtures $Fixtures }

        It 'Moves the Unreleased body under a dated version heading' {
            & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12'
            Get-Content $Fixtures.ChangelogPath -Raw |
                Should -Match ([regex]::Escape("## [0.13.0] - 2026-09-12`n`n$DefaultUnreleased"))
        }

        It 'Leaves a fresh, empty Unreleased behind' {
            & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12'
            Get-Content $Fixtures.ChangelogPath -Raw |
                Should -Match ([regex]::Escape("## [Unreleased]`n`n## [0.13.0]"))
        }

        It 'Prepends the new entry above existing entries' {
            & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12'
            $Content = Get-Content $Fixtures.ChangelogPath -Raw
            $New = $Content.IndexOf('## [0.13.0]')
            $Old = $Content.IndexOf('## [0.12.0]')
            $New | Should -BeGreaterThan 0
            $New | Should -BeLessThan $Old
        }

        It 'Keeps the changelog header intact' {
            & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12'
            Get-Content $Fixtures.ChangelogPath -Raw | Should -BeLike '# Changelog*'
        }
    }

    Context '-NotesOutputPath' {
        BeforeEach { $Fixtures = New-Fixtures }
        AfterEach { Remove-Fixtures $Fixtures }

        It 'Writes the promoted notes on their own' {
            $NotesPath = Join-Path $Fixtures.Dir 'release-notes.md'
            & $Script -Version '0.13.0' -NotesOutputPath $NotesPath `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12'
            Get-Content $NotesPath -Raw | Should -Be "$DefaultUnreleased`n"
        }

        It 'Writes nothing under -WhatIf' {
            $NotesPath = Join-Path $Fixtures.Dir 'release-notes.md'
            & $Script -Version '0.13.0' -NotesOutputPath $NotesPath -WhatIf `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12'
            Test-Path $NotesPath | Should -BeFalse
        }
    }

    Context 'Validation' {
        BeforeEach { $Fixtures = New-Fixtures }
        AfterEach { Remove-Fixtures $Fixtures }

        It 'Throws for a non-three-part version' {
            { & $Script -Version '0.13' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath } |
                Should -Throw '*three-part version*'
        }

        It 'Throws when there is no Unreleased section, naming the file' {
            [System.IO.File]::WriteAllText($Fixtures.ChangelogPath, "# Changelog`n`n## [0.12.0] - 2026-04-21`n`nnotes`n")
            { & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath } |
                Should -Throw "*No *Unreleased* section in $($Fixtures.ChangelogPath)*"
        }

        It 'Throws when the changelog is missing' {
            [System.IO.File]::Delete($Fixtures.ChangelogPath)
            { & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath } |
                Should -Throw '*No changelog at*'
        }
    }

    Context 'Validation with an empty Unreleased' {
        BeforeEach { $Fixtures = New-Fixtures '' }
        AfterEach { Remove-Fixtures $Fixtures }

        It 'Throws, naming the section and the file' {
            { & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath } |
                Should -Throw "*Unreleased* section in $($Fixtures.ChangelogPath) is empty*"
        }

        It 'Leaves the manifest untouched' {
            $ManifestBefore = Get-Content $Fixtures.ManifestPath -Raw
            { & $Script -Version '0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath } | Should -Throw
            Get-Content $Fixtures.ManifestPath -Raw | Should -Be $ManifestBefore
        }
    }

    Context '-WhatIf' {
        BeforeEach { $Fixtures = New-Fixtures }
        AfterEach { Remove-Fixtures $Fixtures }

        It 'Leaves the manifest and changelog untouched' {
            $ManifestBefore = Get-Content $Fixtures.ManifestPath -Raw
            $ChangelogBefore = Get-Content $Fixtures.ChangelogPath -Raw

            & $Script -Version 'v0.13.0' `
                -ManifestPath $Fixtures.ManifestPath -ChangelogPath $Fixtures.ChangelogPath -Date '2026-09-12' -WhatIf

            Get-Content $Fixtures.ManifestPath -Raw | Should -Be $ManifestBefore
            Get-Content $Fixtures.ChangelogPath -Raw | Should -Be $ChangelogBefore
        }
    }
}
