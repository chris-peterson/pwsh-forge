function Get-ForgeSchemaPath {
    [CmdletBinding()]
    [OutputType([string])]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Noun
    )

    $FileName = ($Noun -creplace '(?<=[a-z])(?=[A-Z])', '-').ToLowerInvariant()
    [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../../Schemas/$FileName.schema.yml"))
}

function Get-ForgeSchemaNoun {
    [CmdletBinding()]
    [OutputType([string])]
    param()

    Get-ChildItem (Join-Path $PSScriptRoot '../../Schemas') -Filter '*.schema.yml' |
        ForEach-Object { ($_.Name -replace '\.schema\.yml$' -split '-' | ForEach-Object { $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1) }) -join '' } |
        Where-Object { $_ -ne 'Common' } |
        Sort-Object
}

function Get-ForgeSchema {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Noun
    )

    $Path = Get-ForgeSchemaPath $Noun
    if (-not (Test-Path $Path)) {
        throw "No contract schema for '$Noun' (expected $Path)"
    }
    $Schema = Get-Content $Path -Raw | ConvertFrom-Yaml -Ordered
    if ($Noun -eq 'Common') { return $Schema }

    $Defs = [ordered]@{}
    $Common = Get-ForgeSchema Common
    foreach ($Name in $Common['$defs'].Keys) { $Defs[$Name] = $Common['$defs'][$Name] }
    if ($Schema.Contains('$defs')) {
        foreach ($Name in $Schema['$defs'].Keys) { $Defs[$Name] = $Schema['$defs'][$Name] }
    }
    $Schema['$defs'] = $Defs
    $Schema
}

function ConvertTo-ForgeRecord {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(Mandatory, Position=0)]
        [string]
        $Noun,

        [Parameter(Mandatory, ValueFromPipeline)]
        $InputObject
    )

    begin {
        $Fields = (Get-ForgeSchema $Noun).properties.Keys
    }

    process {
        $Record = [ordered]@{}
        foreach ($Field in $Fields) {
            $PropertyName = ($Field -split '_' | ForEach-Object { $_.Substring(0, 1).ToUpperInvariant() + $_.Substring(1) }) -join ''
            $Property = $InputObject.PSObject.Properties[$PropertyName]
            # An absent property stays absent so schema validation names the missing field.
            if (-not $Property) { continue }
            $Value = $Property.Value
            if ($Value -is [datetime]) {
                $Value = $Value.ToUniversalTime().ToString("yyyy-MM-dd'T'HH:mm:ss'Z'", [cultureinfo]::InvariantCulture)
            }
            $Record[$Field] = $Value
        }
        [PSCustomObject]$Record
    }
}
