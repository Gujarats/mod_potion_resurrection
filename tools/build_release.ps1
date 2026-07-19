$ErrorActionPreference = 'Stop'

$projectRoot = Split-Path -Parent $PSScriptRoot
$releaseDir = Join-Path $projectRoot 'release'
$stagingRoot = Join-Path $projectRoot '.build-potion-resurrection'
$resolvedProject = [System.IO.Path]::GetFullPath($projectRoot)
$resolvedStaging = [System.IO.Path]::GetFullPath($stagingRoot)

if (-not $resolvedStaging.StartsWith($resolvedProject, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw 'Refusing to use a staging directory outside the project.'
}

if (Test-Path -LiteralPath $stagingRoot) {
    Remove-Item -Recurse -Force -LiteralPath $stagingRoot
}

$mainStage = Join-Path $stagingRoot 'main'
$addonStage = Join-Path $stagingRoot 'addon'
New-Item -ItemType Directory -Force -Path $mainStage, $addonStage, $releaseDir | Out-Null

Copy-Item -Recurse -LiteralPath (Join-Path $projectRoot 'scripts') -Destination $mainStage
Copy-Item -Recurse -LiteralPath (Join-Path $projectRoot 'gfx') -Destination $mainStage
Copy-Item -LiteralPath (Join-Path $projectRoot 'README.md') -Destination $mainStage

$addonSource = Join-Path $projectRoot 'compat/mod_spawn_item_addon_potion_resurrection/scripts'
Copy-Item -Recurse -LiteralPath $addonSource -Destination $addonStage

$mainArchive = Join-Path $releaseDir 'mod_potion_resurrection.zip'
$addonArchive = Join-Path $releaseDir 'mod_spawn_item_addon_potion_resurrection.zip'
Compress-Archive -Path (Join-Path $mainStage '*') -DestinationPath $mainArchive -CompressionLevel Optimal -Force
Compress-Archive -Path (Join-Path $addonStage '*') -DestinationPath $addonArchive -CompressionLevel Optimal -Force

Remove-Item -Recurse -Force -LiteralPath $stagingRoot

Write-Host "Created $mainArchive"
Write-Host "Created $addonArchive"
