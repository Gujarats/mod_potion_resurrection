# Potion of Resurrection

Potion of Resurrection adds Normal, Medium, and High consumable potions to Battle Brothers. Each potion gives one brother a permanent resurrection charge that is consumed on an eligible battlefield death.

## Features

- Uses the vanilla potion-consumption workflow.
- Drinking another tier replaces the brother's existing resurrection charge.
- Restores configured hitpoints and armor on an eligible battlefield death.
- Excludes Kraken devouring and scripted or cleanup deaths.
- Adds configurable stock, rarity, price, restoration values, and high-tier settlement restriction through MSU.

## Required dependencies

The main mod requires:

- Modern Hooks
- MSU 1.9.0 or newer

## Optional Item Spawner support

`mod_spawn_item_main` is optional. It is only required when you also install the separately packaged Item Spawner compatibility addon, which adds all three potions to Item Spawner search and spawn results.

The main Potion of Resurrection archive does not require Item Spawner.

## Default balance

| Tier | Health restored | Armor restored | Base price | Default availability | Default stock |
|---|---:|---:|---:|---:|---:|
| Normal | 50% | 25% | 200 crowns | 100% | 2 |
| Medium | 80% | 50% | 600 crowns | 20% | 1 |
| High | 100% | 100% | 1,800 crowns | 5% | 1 |

Prices scale from the averaged lowest and highest active roster levels, at 5% per averaged level by default. High potions are restricted to size-3 settlements by default.

## Installation

1. Install Modern Hooks and MSU 1.9.0 or newer.
2. Extract `mod_potion_resurrection.zip` into the Battle Brothers `data` directory.
3. Optional: if you use Item Spawner, install `mod_spawn_item_main` and extract `mod_spawn_item_addon_potion_resurrection.zip` into the same `data` directory.

Do not remove the main mod from a save while a brother has a resurrection effect.

## Configuration and logging

All gameplay and balance values are configurable through the MSU settings pages: health restoration, armor restoration, base price, level scaling, availability, stock, and High-potion settlement restriction.

The diagnostic `[PotionResurrection]` log code is retained for troubleshooting, but logging is currently hard-disabled. It will be exposed as a user setting in a future update.

## Known visual limitation

The mod uses a simulated death sequence rather than Battle Brothers' real corpse pipeline. On a lethal hit, the actor fades out over 250 ms, remains hidden briefly, then returns with the native rise animation.

This keeps resurrection safe and avoids corpse-side effects, but the simulated death transition can look slightly unusual. The actor does not first play the full vanilla death animation or become a real corpse.

## Building and validation

From this project directory, run:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test_potion_resurrection_layout.ps1
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_release.ps1
```

The build creates the main mod archive and the optional Item Spawner addon under `release/`. Automated checks do not run the Battle Brothers engine; complete `test-results/potion-resurrection-manual-matrix.md` before publishing a release.
