# Potion of Resurrection

Battle Brothers mod adding Normal, Medium, and High resurrection potions.

## Requirements

- Modern Hooks
- MSU 1.9.0 or newer
- `mod_spawn_item_main` only when using the separately packaged compatibility addon

Drinking a potion uses the vanilla consumable workflow and applies one permanent resurrection charge. Drinking another tier replaces the existing charge. Eligible battlefield deaths restore configured health and armor; Kraken devouring and scripted or cleanup deaths are excluded.

Default restoration is 50% health/25% armor for Normal, 80%/50% for Medium, and 100%/100% for High. Every tier starts at 750 crowns. Price scaling uses `(highest active level + lowest active level) / 2` and defaults to 5% per averaged level.

Normal, Medium, and High default to 100%/20%/5% availability and stock 2/1/1. High is restricted to size-3 settlements by default. All balance values are configurable through MSU.

`Enable Debug Logging` is enabled by default in the MSU General page. Diagnostic lines begin with `[PotionResurrection]` and report consumption, effect presence at combat start, lethal interception, eligibility decisions, and restoration results.

Install the contents of the main release archive into the Battle Brothers `data` directory. Do not remove the mod from a save while a brother carries its resurrection effect.

## Release archives

Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_release.ps1` from this project directory. It creates the main mod and the optional item-spawner addon as separate archives under `release/`.

Automated repository validation does not execute the Battle Brothers engine. Complete the checklist in `test-results/potion-resurrection-manual-matrix.md` before publishing a release.
