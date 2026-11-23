function Format-MarkdownTable {
    param(
        [string[]]
        $Headers,

        # Each row is an array of cells, already formatted as markdown.
        [object[]]
        $Rows
    )

    $ColWidths = for ($i = 0; $i -lt $Headers.Count; $i++) {
        ($Rows | ForEach-Object { "$($_[$i])".Length }) + $Headers[$i].Length | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
    }

    $Lines = @()
    $Lines += '| {0} |' -f ((0..($Headers.Count - 1) | ForEach-Object { $Headers[$_].PadRight($ColWidths[$_]) }) -join ' | ')
    $Lines += '|{0}|' -f (($ColWidths | ForEach-Object { '-' * ($_ + 2) }) -join '|')
    foreach ($Row in $Rows) {
        $Lines += '| {0} |' -f ((0..($Headers.Count - 1) | ForEach-Object { "$($Row[$_])".PadRight($ColWidths[$_]) }) -join ' | ')
    }
    $Lines -join "`n"
}

$script:SchemaProviderKeys = @('github', 'gitlab')

# A property that references a shared definition inherits the definition's keys; its own keys win.
function Resolve-SchemaProperty {
    param($Schema, $Property)

    if (-not $Property.Contains('$ref')) { return $Property }
    $RefName = ($Property['$ref'] -split '/')[-1]
    $Resolved = [ordered]@{} + $Schema['$defs'][$RefName]
    foreach ($Key in $Property.Keys) { if ($Key -ne '$ref') { $Resolved[$Key] = $Property[$Key] } }
    $Resolved['x-ref'] = $RefName
    $Resolved
}

function Get-SchemaTypeName {
    param($Schema, $Property)

    $Resolved = Resolve-SchemaProperty $Schema $Property
    # A constrained definition (a pattern or an enumeration) is named; a plain one shows its JSON type.
    if ($Resolved.Contains('x-ref') -and ($Resolved.Contains('pattern') -or $Resolved.Contains('oneOf'))) { return $Resolved['x-ref'] }
    if ($Resolved.Contains('oneOf')) { return 'string' }
    if ($Resolved.Contains('anyOf')) { return ($Resolved.anyOf | ForEach-Object { Get-SchemaTypeName $Schema $_ }) -join ' \| ' }
    $Types = @($Resolved.type) | ForEach-Object {
        if ($_ -eq 'array') { "array of $(Get-SchemaTypeName $Schema $Resolved.items)" } else { "$_" }
    }
    $Types -join ' \| '
}

function ConvertTo-ValuesMarkdown {
    param($Name, $OneOf)

    $Mapped = [bool]($OneOf | Where-Object { $_.Contains("x-$($SchemaProviderKeys[0])") })
    $Headers = @('Value', 'Description')
    if ($Mapped) { $Headers += $SchemaProviderKeys | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) } }
    $Rows = foreach ($Option in $OneOf) {
        $Value = if ($Option.Contains('const')) { $Option.const } else { $Option.type }
        $Row = @("``$Value``", $Option.description)
        if ($Mapped) { $Row += $SchemaProviderKeys | ForEach-Object { $Option["x-$_"] } }
        , $Row
    }
    "#### ``$Name`` values`n`n" + (Format-MarkdownTable $Headers $Rows)
}

function ConvertTo-SchemaMarkdown {
    param([System.Collections.IDictionary] $Schema)

    $Headers = @('Field', 'Type', 'Description') + ($SchemaProviderKeys | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })
    $Rows = foreach ($Field in $Schema.properties.Keys) {
        $Property = Resolve-SchemaProperty $Schema $Schema.properties[$Field]
        , (@("``$Field``", (Get-SchemaTypeName $Schema $Schema.properties[$Field]), $Property.description) + ($SchemaProviderKeys | ForEach-Object { $Property["x-$_"] }))
    }

    $Blocks = @("### $($Schema.title)", $Schema.description, (Format-MarkdownTable $Headers $Rows))
    foreach ($Field in $Schema.properties.Keys) {
        $Property = $Schema.properties[$Field]
        $Values = if ($Property.Contains('oneOf')) { $Property.oneOf } elseif ($Property.items -and $Property.items.Contains('oneOf')) { $Property.items.oneOf }
        if ($Values) { $Blocks += ConvertTo-ValuesMarkdown $Field $Values }
    }
    $Blocks -join "`n`n"
}

function ConvertTo-CommonSchemaMarkdown {
    param([System.Collections.IDictionary] $Schema)

    $Headers = @('Definition', 'Type', 'Description') + ($SchemaProviderKeys | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })
    $Rows = foreach ($Name in $Schema['$defs'].Keys) {
        $Def = $Schema['$defs'][$Name]
        $Type = if ($Def.Contains('oneOf')) { 'string' } else { "$($Def.type)" }
        , (@("``$Name``", $Type, $Def.description) + ($SchemaProviderKeys | ForEach-Object { $Def["x-$_"] }))
    }

    $Blocks = @("### $($Schema.title)", $Schema.description, (Format-MarkdownTable $Headers $Rows))
    foreach ($Name in $Schema['$defs'].Keys) {
        if ($Schema['$defs'][$Name].Contains('oneOf')) { $Blocks += ConvertTo-ValuesMarkdown $Name $Schema['$defs'][$Name].oneOf }
    }
    $Blocks -join "`n`n"
}

function ConvertTo-ContractMarkdown {
    param([string] $SchemaDirectory)

    $Blocks = @(
        '## Detailed Property Mappings'
        "Each section is generated from a schema in [``$SchemaDirectory``]($SchemaDirectory). Edit the schema, then paste the section the contract test prints."
    )
    $Blocks += Get-ForgeSchemaNoun | ForEach-Object { ConvertTo-SchemaMarkdown (Get-ForgeSchema $_) }
    $Blocks += ConvertTo-CommonSchemaMarkdown (Get-ForgeSchema Common)
    $Blocks -join "`n`n"
}
