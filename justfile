# https://just.systems/man/en/

default: test lint

test:
    #!/usr/bin/env pwsh
    Import-Module Pester
    $Config = New-PesterConfiguration
    $Config.Run.Exit = $true
    Invoke-Pester -Configuration $Config

lint:
    #!/usr/bin/env pwsh
    $Results = Invoke-ScriptAnalyzer -Path ./src -Recurse -Settings ./PSScriptAnalyzerSettings.ps1
    if ($Results) { $Results | Format-Table -AutoSize; exit 1 } else { Write-Host "No linting issues found." }
