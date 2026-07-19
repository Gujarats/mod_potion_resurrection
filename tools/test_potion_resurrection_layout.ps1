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

Assert-Contains 'scripts/skills/effects/resurrection_potion_effect.nut' @(
    'effects.resurrection_potion',
    'IsRemovedAfterBattle = false',
    'function setTier',
    'function getTier',
    'function isTriggering',
    'function setTriggering',
    'writeString',
    'readString'
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
    'sounds/combat/drink_0'
)

$itemContracts = @{
    'scripts/items/misc/resurrection_potion_normal_item.nut' = @('misc.resurrection_potion_normal', 'Tier = "normal"', 'resurrection_potion_normal.png')
    'scripts/items/misc/resurrection_potion_medium_item.nut' = @('misc.resurrection_potion_medium', 'Tier = "medium"', 'resurrection_potion_medium.png')
    'scripts/items/misc/resurrection_potion_high_item.nut' = @('misc.resurrection_potion_high', 'Tier = "high"', 'resurrection_potion_high.png')
}
foreach ($entry in $itemContracts.GetEnumerator()) {
    Assert-Contains $entry.Key $entry.Value
}

Write-Host 'Potion Resurrection layout validation passed.'
