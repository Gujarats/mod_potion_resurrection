$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot

function Assert-FileExists([string] $RelativePath) {
    $path = Join-Path $projectRoot $RelativePath
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Missing required mod file: $RelativePath"
    }
}

function Assert-Contains([string] $RelativePath, [string[]] $Tokens) {
    Assert-FileExists $RelativePath
    $content = Get-Content -Raw -LiteralPath (Join-Path $projectRoot $RelativePath)
    foreach ($token in $Tokens) {
        if (-not $content.Contains($token)) {
            throw "Missing token '$token' in $RelativePath"
        }
    }
}

Assert-Contains 'scripts/!mods_preload/mod_potion_resurrection.nut' @(
    'Hooks.register',
    'mod_msu >= 1.9.0',
    'PriceScalingPct',
    'RestrictHighToLargeSettlements',
    'NormalHealthPct',
    'MediumHealthPct',
    'HighHealthPct',
    'NormalStock',
    'MediumStock',
    'HighStock'
)

Write-Host 'Potion Resurrection layout validation passed.'
