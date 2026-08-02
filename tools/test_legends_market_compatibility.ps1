$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot

function Assert-Contains([string]$RelativePath, [string]$Token)
{
	$path = Join-Path $root $RelativePath
	if (!(Test-Path -LiteralPath $path) -or (Get-Content -Raw -LiteralPath $path).IndexOf($Token) -lt 0)
	{
		throw "Missing '$Token' in $RelativePath"
	}
}

Assert-Contains "scripts/mods/potion_resurrection/compatibility/legends_market_patch.nut" "scripts/entity/world/settlements/buildings/building"
Assert-Contains "scripts/mods/potion_resurrection/compatibility/legends_market_patch.nut" "q.fillStash"
Assert-Contains "scripts/mods/potion_resurrection/compatibility/legends_market_patch.nut" "building.marketplace"
Assert-Contains "scripts/mods/potion_resurrection/compatibility/legends_market_patch.nut" "building.alchemist"
Assert-Contains "scripts/mods/potion_resurrection/compatibility/legends_market_patch.nut" "::PotionResurrection.addMarketStock"
Assert-Contains "scripts/mods/potion_resurrection_market.nut" "registerVanillaMarketHooks"
Assert-Contains "scripts/!mods_preload/mod_potion_resurrection.nut" "legends_market_patch"
Assert-Contains "scripts/!mods_preload/mod_potion_resurrection.nut" "registerVanillaMarketHooks"

$preload = Get-Content -Raw -LiteralPath (Join-Path $root "scripts/!mods_preload/mod_potion_resurrection.nut")
$includeIndex = $preload.IndexOf('::include("scripts/mods/potion_resurrection/compatibility/legends_market_patch");')
$queueIndex = $preload.IndexOf('::PotionResurrection.HooksMod.queue')
if ($includeIndex -lt 0 -or $includeIndex -gt $queueIndex)
{
	throw "The Legends market compatibility module must load before Potion Resurrection registers its queue callback"
}

Write-Output "Potion Resurrection Legends market compatibility contract passed."
