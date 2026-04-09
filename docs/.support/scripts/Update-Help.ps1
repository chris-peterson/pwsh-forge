# Usage:
#   ./Update-Help.ps1                 # Update markdown files
#   ./Update-Help.ps1 -ThrowOnChanges # Update and fail if changes were made (for CI)

param(
    [switch]
    $ThrowOnChanges
)

$ScriptDir  = Split-Path -Parent $MyInvocation.MyCommand.Path
$DocsFolder = Join-Path $ScriptDir '../..'
$ModulePath = Join-Path $ScriptDir '../../../src/ForgeCli'
$RepoRoot   = Resolve-Path (Join-Path $ScriptDir '../../..')

# Remove existing help XML to avoid duplicate documentation
$HelpXmlPath = Join-Path $ModulePath 'en-US/ForgeCli-Help.xml'
if (Test-Path $HelpXmlPath) {
    Remove-Item $HelpXmlPath -Force
    Write-Host "Removed existing help XML file" -ForegroundColor Cyan
}

Import-Module Microsoft.PowerShell.PlatyPS
Import-Module $ModulePath -Force

$Module = Get-Module ForgeCli

$MdFiles = Measure-PlatyPSMarkdown -Path (Join-Path $DocsFolder '*/*.md') -ErrorAction SilentlyContinue

Write-Host "Checking for new commands without documentation..." -ForegroundColor Cyan
$ExistingDocs = if ($MdFiles) {
    $MdFiles | Where-Object Filetype -match 'CommandHelp' | ForEach-Object {
        (Import-MarkdownCommandHelp -Path $_.FilePath).Title
    }
} else { @() }
$AllCommands = $Module.ExportedFunctions.Keys
$UndocumentedCommands = $AllCommands | Where-Object { $_ -notin $ExistingDocs }

if ($UndocumentedCommands) {
    Write-Host "  Generating docs for: $($UndocumentedCommands -join ', ')" -ForegroundColor Yellow
    $NewFiles = New-MarkdownCommandHelp -Module $Module -OutputFolder $DocsFolder -WarningAction SilentlyContinue

    foreach ($File in $NewFiles) {
        $RelativePath = $File.FullName -replace [regex]::Escape((Resolve-Path $DocsFolder).Path + '/'), ''
        $UrlPath = $RelativePath -replace '\.md$', ''
        $Help = Import-MarkdownCommandHelp -Path $File.FullName
        $Help.OnlineVersionUrl = "https://chris-peterson.github.io/pwsh-forge/#/$UrlPath"
        $Help.ModuleName = 'ForgeCli'
        $Help | Export-MarkdownCommandHelp -OutputFolder $DocsFolder -Force
    }
} else {
    Write-Host "  All $($AllCommands.Count) commands are documented" -ForegroundColor Green
}

Write-Host "Documented cmdlets: $($ExistingDocs.Count)/$($AllCommands.Count)" -ForegroundColor Cyan

Write-Host "Filtering out unimportant changes..." -ForegroundColor Cyan
Push-Location $RepoRoot
$ModifiedFiles = git diff --name-only -- docs/
foreach ($File in $ModifiedFiles) {
    if ($File) {
        $DiffContent = git diff --unified=0 -- $File
        $SignificantChanges = $DiffContent | Where-Object {
            $_ -match '^[+-]' -and
            $_ -notmatch '^[+-]{3}' -and      # Ignore diff headers
            $_ -notmatch '^[+-]ms\.date:'     # Ignore ms.date changes
        }
        if (-not $SignificantChanges) {
            git checkout -- $File 2>$null
            Write-Debug "  Reverted unimportant changes in: $File"
        }
    }
}
Pop-Location

Write-Host "Checking for placeholder text..." -ForegroundColor Cyan
$PlaceholderPattern = '\{\{\s*Fill\s'
$PlaceholderMatches = Get-ChildItem -Path $DocsFolder -Filter '*.md' -Recurse |
    Select-String -Pattern $PlaceholderPattern

if ($PlaceholderMatches) {
    Write-Host "`nFound placeholder text that needs to be filled in:" -ForegroundColor Red
    $PlaceholderMatches | ForEach-Object {
        $RelativePath = $_.Path -replace [regex]::Escape((Resolve-Path $DocsFolder).Path + '/'), ''
        Write-Host "  - $RelativePath`:$($_.LineNumber): $($_.Line.Trim())" -ForegroundColor Yellow
    }
    throw "Documentation contains placeholder text. Please fill in the descriptions above."
}

$CategoryDescriptions = @{
    'Branches'       = 'Create, list, and delete branches'
    'ChangeRequests' = 'Manage pull requests and merge requests'
    'Commits'        = 'View commit information'
    'Groups'         = 'Manage organizations and groups'
    'Issues'         = 'Create, update, and close issues'
    'Members'        = 'Manage group and organization members'
    'Milestones'     = 'Track milestones'
    'Releases'       = 'View releases'
    'Repos'          = 'Manage repositories and projects'
    'Search'         = 'Search across forges'
    'Users'          = 'User information and activity'
}

$Categories = Get-ChildItem -Path $DocsFolder -Directory |
    Sort-Object Name

Write-Host "Validating category landing pages..." -ForegroundColor Cyan
foreach ($Category in $Categories) {
    $CmdletFiles = Get-ChildItem -Path $Category.FullName -Filter '*.md' |
        Where-Object { $_.Name -ne 'README.md' } |
        Sort-Object BaseName

    if ($CmdletFiles) {
        $LandingPath = Join-Path $Category.FullName 'README.md'

        if (-not (Test-Path $LandingPath)) {
            $Description = $CategoryDescriptions[$Category.Name]
            if (-not $Description) { $Description = "Manage $($Category.Name)" }

            $LandingContent = @()
            $LandingContent += "# $($Category.Name)"
            $LandingContent += ''
            $LandingContent += $Description
            $LandingContent += ''
            $LandingContent += '## Cmdlets'
            $LandingContent += ''
            $LandingContent += '| Cmdlet | Description |'
            $LandingContent += '|--------|-------------|'
            foreach ($CmdletFile in $CmdletFiles) {
                $LandingContent += "| [$($CmdletFile.BaseName)](/$($Category.Name)/$($CmdletFile.Name)) | |"
            }
            $LandingContent += ''

            Set-Content $LandingPath -Value ($LandingContent -join "`n") -NoNewline
            Write-Host "  Created $($Category.Name)/README.md (please add descriptions)" -ForegroundColor Yellow
        }
        else {
            $ReadmeContent = Get-Content $LandingPath -Raw
            $MissingCmdlets = @()
            foreach ($CmdletFile in $CmdletFiles) {
                if ($ReadmeContent -notmatch [regex]::Escape($CmdletFile.BaseName)) {
                    $MissingCmdlets += $CmdletFile.BaseName
                }
            }
            if ($MissingCmdlets) {
                Write-Host "  WARNING: $($Category.Name)/README.md is missing cmdlets: $($MissingCmdlets -join ', ')" -ForegroundColor Yellow
            }
        }
    }
}

Write-Host "Updating _sidebar.md from folder structure..." -ForegroundColor Cyan
$SidebarPath = Join-Path $DocsFolder '_sidebar.md'
$SidebarContent = @()
$SidebarContent += '<!-- docs/_sidebar.md -->'
$SidebarContent += '<!-- This file is auto-generated by Update-Help.ps1 -->'
$SidebarContent += ''
$SidebarContent += '* [Home](/)'
$SidebarContent += ''

foreach ($Category in $Categories) {
    $CmdletFiles = Get-ChildItem -Path $Category.FullName -Filter '*.md' |
        Where-Object { $_.Name -ne 'README.md' } |
        Sort-Object BaseName

    if ($CmdletFiles) {
        $SidebarContent += "* [$($Category.Name)](/$($Category.Name)/)"

        foreach ($CmdletFile in $CmdletFiles) {
            $CmdletName = $CmdletFile.BaseName
            $AbsolutePath = "/$($Category.Name)/$($CmdletFile.Name)"
            $SidebarContent += "  * [$CmdletName]($AbsolutePath)"
        }

        $SidebarContent += ''
    }
}

$SidebarContent += '---'
$SidebarContent += ''
$SidebarContent += '* [GitHub](https://github.com/chris-peterson/pwsh-forge)'
$SidebarContent += '* [PowerShell Gallery](https://www.powershellgallery.com/packages/ForgeCli)'
$SidebarContent += ''

$NewSidebarContent = $SidebarContent -join "`n"
$ExistingSidebarContent = if (Test-Path $SidebarPath) { Get-Content $SidebarPath -Raw } else { '' }

if ($NewSidebarContent.TrimEnd() -ne $ExistingSidebarContent.TrimEnd()) {
    Set-Content $SidebarPath -Value $NewSidebarContent -NoNewline
    Write-Host "  Updated _sidebar.md" -ForegroundColor Yellow
}

Write-Host "Updating README.md categories section..." -ForegroundColor Cyan
$ReadmePath = Join-Path $DocsFolder 'README.md'
$ReadmeContent = Get-Content $ReadmePath -Raw

$CategoriesList = @()
foreach ($Category in $Categories) {
    $Description = $CategoryDescriptions[$Category.Name]
    if (-not $Description) { $Description = "Manage $($Category.Name)" }

    $CategoriesList += "- [$($Category.Name)](/$($Category.Name)/) - $Description"
}
$CategoriesText = $CategoriesList -join "`n"

$Pattern = '(?s)(## Cmdlet Categories\s+Browse the sidebar to find cmdlets organized by category:\s+)(- \[.*?)(## Ecosystem)'
$Replacement = "`$1$CategoriesText`n`n`$3"
$UpdatedReadme = $ReadmeContent -replace $Pattern, $Replacement

if ($UpdatedReadme -ne $ReadmeContent) {
    Set-Content $ReadmePath -Value $UpdatedReadme -NoNewline
    Write-Host "  Updated README.md categories" -ForegroundColor Yellow
}

if ($ThrowOnChanges) {
    Push-Location $RepoRoot
    $ModifiedFiles = git diff --name-only -- docs/
    $UntrackedFiles = git ls-files --others --exclude-standard -- docs/
    Pop-Location

    $PendingChanges = @($ModifiedFiles) + @($UntrackedFiles) | Where-Object { $_ }

    if ($PendingChanges) {
        Write-Host "`nThe following markdown help files are out of sync:" -ForegroundColor Red
        $PendingChanges | ForEach-Object {
            Write-Host "  - $_" -ForegroundColor Yellow
        }
        throw "Markdown help is out of sync. Run 'just help-update' locally and commit the changes."
    }
    else {
        Write-Host "Markdown help is up to date." -ForegroundColor Green
    }
}
else {
    Push-Location $RepoRoot
    $ModifiedFiles = git diff --name-only -- docs/
    $UntrackedFiles = git ls-files --others --exclude-standard -- docs/
    Pop-Location

    $PendingChanges = @($ModifiedFiles) + @($UntrackedFiles) | Where-Object { $_ }

    if ($PendingChanges) {
        Write-Host "Help files updated. Review changes and commit." -ForegroundColor Yellow
    }
    else {
        Write-Host "Help files are up to date." -ForegroundColor Green
    }
}
