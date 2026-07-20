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

function Assert-NotContains([string] $RelativePath, [string[]] $Tokens) {
    Assert-FileExists $RelativePath
    $content = Get-Content -Raw -LiteralPath (Join-Path $projectRoot $RelativePath)
    foreach ($token in $Tokens) {
        if ($content.Contains($token)) {
            throw "Unexpected token '$token' in $RelativePath"
        }
    }
}

Assert-Contains 'scripts/!mods_preload/mod_potion_resurrection.nut' @(
    'Hooks.register',
    'mod_msu >= 1.9.0',
    'PriceScalingPct',
    'EnableDebugLogging',
    'RestrictHighToLargeSettlements',
    'NormalHealthPct',
    'MediumHealthPct',
    'HighHealthPct',
    'NormalStock',
    'MediumStock',
    'HighStock',
    '::include("scripts/mods/potion_resurrection_service")',
    '::include("scripts/mods/potion_resurrection_market")',
    'Mod.Debug.setFlag("default"',
    'debugLogSetting.addCallback'
)
Assert-NotContains 'scripts/!mods_preload/mod_potion_resurrection.nut' @(
    '::include("mods/potion_resurrection_service")',
    '::include("mods/potion_resurrection_market")'
)

Assert-Contains 'scripts/skills/effects/resurrection_potion_effect.nut' @(
    'effects.resurrection_potion',
    'IsRemovedAfterBattle = false',
    'function setTier',
    'function getTier',
    'function isTriggering',
    'function setTriggering',
    'writeString',
    'readString',
    'function onCombatStarted',
    'Effect active at combat start'
)

Assert-Contains 'scripts/mods/potion_resurrection_service.nut' @(
    'canTrigger <- function',
    'FatalityType.Kraken',
    'FatalityType.Devoured',
    'isScenarioMode()',
    'isAutoRetreat()',
    '_killer == null && _skill == null',
    'isPlacedOnMap()',
    'restoreArmorSlot',
    'getBoundaryAverageLevel',
    'getScaledPrice',
    'debugLog',
    'Mod.Debug.printLog',
    'player.kill intercepted',
    'Resurrection eligibility rejected',
    'Resurrection restoration started',
    'Resurrection restoration succeeded',
    'scripts/entity/tactical/player',
    'q.kill = @(__original)',
    'return __original(_killer, _skill, _fatalityType, _silent)'
)

Assert-Contains 'scripts/items/misc/resurrection_potion_item.nut' @(
    'scripts/items/item',
    'Const.Items.ItemType.Usable',
    'function onUse',
    'effects.resurrection_potion',
    'removeByID',
    'setTier',
    'checkDrugEffect',
    'sounds/bottle_01.wav',
    'sounds/combat/drink_0',
    'Potion consumed'
)

$itemContracts = @{
    'scripts/items/misc/resurrection_potion_normal_item.nut' = @('misc.resurrection_potion_normal', 'Tier = "normal"', 'resurrection_potion_normal.png')
    'scripts/items/misc/resurrection_potion_medium_item.nut' = @('misc.resurrection_potion_medium', 'Tier = "medium"', 'resurrection_potion_medium.png')
    'scripts/items/misc/resurrection_potion_high_item.nut' = @('misc.resurrection_potion_high', 'Tier = "high"', 'resurrection_potion_high.png')
}
foreach ($entry in $itemContracts.GetEnumerator()) {
    Assert-Contains $entry.Key $entry.Value
}

Assert-Contains 'scripts/mods/potion_resurrection_market.nut' @(
    'scripts/entity/world/settlements/buildings/alchemist_building',
    'q.onAfterFillStash = @(__original)',
    'getSize() >= 3',
    'RestrictHighToLargeSettlements',
    'tier.SpawnChanceSetting',
    'tier.StockSetting',
    'misc/resurrection_potion_normal_item',
    'misc/resurrection_potion_medium_item',
    'misc/resurrection_potion_high_item',
    '_stash.sort()'
)

Assert-Contains 'compat/mod_spawn_item_addon_potion_resurrection/scripts/!mods_preload/register_potion_resurrection_for_item_spawner.nut' @(
    'mod_potion_resurrection_item_spawner_addon',
    'mod_item_spawner',
    'mod_potion_resurrection',
    'queryItemUIData',
    'misc.resurrection_potion_normal',
    'misc.resurrection_potion_medium',
    'misc.resurrection_potion_high',
    'ItemFilter.All',
    'ItemFilter.Usable'
)
Assert-NotContains 'compat/mod_spawn_item_addon_potion_resurrection/scripts/!mods_preload/register_potion_resurrection_for_item_spawner.nut' @(
    'function( _reset = false )',
    'originalQueryItemUIData(_reset)'
)

$assetPaths = @(
    'gfx/ui/items/consumables/resurrection_potion_normal.png',
    'gfx/ui/items/consumables/resurrection_potion_medium.png',
    'gfx/ui/items/consumables/resurrection_potion_high.png'
)
foreach ($assetPath in $assetPaths) {
    Assert-FileExists $assetPath
}

Add-Type -AssemblyName System.Drawing
$sourcePath = Join-Path (Split-Path -Parent $projectRoot) 'data_001/gfx/ui/items/consumables/potion_38.png'
$sourceImage = [System.Drawing.Bitmap]::new($sourcePath)
$assetHashes = @()
try {
    foreach ($assetPath in $assetPaths) {
        $fullPath = Join-Path $projectRoot $assetPath
        $image = [System.Drawing.Bitmap]::new($fullPath)
        try {
            if ($image.Width -ne $sourceImage.Width -or $image.Height -ne $sourceImage.Height) {
                throw "Asset dimensions differ from potion_38.png: $assetPath"
            }
        }
        finally {
            $image.Dispose()
        }
        $assetHashes += (Get-FileHash -Algorithm SHA256 -LiteralPath $fullPath).Hash
    }
}
finally {
    $sourceImage.Dispose()
}
if (($assetHashes | Select-Object -Unique).Count -ne 3) {
    throw 'The three potion assets must be visually distinct files.'
}

Assert-Contains 'tools/build_release.ps1' @(
    'mod_potion_resurrection.zip',
    'mod_spawn_item_addon_potion_resurrection.zip',
    'Compress-Archive',
    'scripts',
    'gfx'
)
Assert-Contains 'test-results/potion-resurrection-manual-matrix.md' @(
    'Consumption and replacement',
    'Save/load persistence',
    'Kraken exclusion',
    'Market distribution',
    'Item spawner compatibility'
)

$forbidden = Get-ChildItem -Recurse -File -LiteralPath $projectRoot | Where-Object {
    $_.Name -like '*.sublime-project' -or $_.FullName -like '*\data_001\*'
}
if ($forbidden) {
    throw "Forbidden packaged/reference file found: $($forbidden[0].FullName)"
}

$nutFiles = Get-ChildItem -Recurse -File -Filter '*.nut' -LiteralPath $projectRoot
foreach ($nutFile in $nutFiles) {
    $content = Get-Content -Raw -LiteralPath $nutFile.FullName
    $openBraces = ([regex]::Matches($content, '\{')).Count
    $closeBraces = ([regex]::Matches($content, '\}')).Count
    if ($openBraces -ne $closeBraces) {
        throw "Unbalanced braces in $($nutFile.FullName)"
    }
}

Write-Host 'Potion Resurrection layout validation passed.'
