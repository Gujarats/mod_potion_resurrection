$ErrorActionPreference = "Stop"

$root = Split-Path -Parent $PSScriptRoot
$preloadPath = Join-Path $root "scripts\!mods_preload\mod_potion_resurrection.nut"
$preload = Get-Content -Raw -LiteralPath $preloadPath

@(
	'DebugLogging',
	'addBooleanSetting("DebugLogging", true',
	'configureDebugLogging',
	'Debug.setFlag("default", enabled)',
	'debugLogging.addCallback'
) | ForEach-Object {
	if ($preload.IndexOf($_) -lt 0) {
		throw "Missing Potion Resurrection debug logging token: $_"
	}
}

if ($preload.IndexOf('Mod.Debug.disable()') -ge 0) {
	throw "Potion Resurrection still hard-disables debug logging."
}

Write-Output "Potion Resurrection debug logging configuration passed."
