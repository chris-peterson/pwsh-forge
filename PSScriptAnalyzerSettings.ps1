@{
    # PSScriptAnalyzer settings for pwsh-forge
    # https://learn.microsoft.com/en-us/powershell/utility-modules/psscriptanalyzer/rules/readme

    ExcludeRules = @(
        # Suggests putting $null on the left side of comparisons to avoid array coercion issues.
        # While technically valid, the right-side style ($var -eq $null) is more readable.
        'PSPossibleIncorrectComparisonWithNull'

        # Fires on functions with ValueFromPipelineByPropertyName but no process {} block.
        'PSUseProcessBlockForPipelineCommand'
    )
}
