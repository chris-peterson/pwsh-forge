@{
    # PSScriptAnalyzer settings for pwsh-forge
    # https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/rules/readme

    ExcludeRules = @(
        # This module intentionally uses global variables for shared module state
        # (known providers, live registry). $script: scope doesn't work across
        # module files, so $global: is the standard pattern.
        # All globals are namespaced with 'Forge' prefix to avoid collisions.
        'PSAvoidGlobalVars'

        # Suggests putting $null on the left side of comparisons to avoid array coercion issues.
        # While technically valid, the right-side style ($var -eq $null) is more readable.
        'PSPossibleIncorrectComparisonWithNull'

        # Fires on functions with ValueFromPipelineByPropertyName but no process {} block.
        'PSUseProcessBlockForPipelineCommand'
    )
}
