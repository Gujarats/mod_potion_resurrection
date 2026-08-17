# Potion of Resurrection

Potion of Resurrection adds Normal, Rare, and Legendary consumable potions to Battle Brothers. Each potion gives one brother a permanent resurrection charge that is consumed on an eligible battlefield death.

## Features

- Uses the vanilla potion-consumption workflow.
- Drinking another tier replaces the brother's existing resurrection charge.
- Restores configured hitpoints and armor on an eligible battlefield death.
- Excludes Kraken devouring and scripted or cleanup deaths.
- Adds configurable stock, rarity, price, restoration values, and Legendary-potion settlement restriction through MSU.

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
| Rare | 80% | 50% | 600 crowns | 20% | 1 |
| Legendary | 100% | 100% | 1,800 crowns | 5% | 1 |

Prices scale from the averaged lowest and highest active roster levels, at 5% per averaged level by default. Legendary potions are restricted to size-3 settlements by default.

## Installation

1. Install Modern Hooks and MSU 1.9.0 or newer.
2. Extract `mod_potion_resurrection.zip` into the Battle Brothers `data` directory.
3. Optional: if you use Item Spawner, install `mod_spawn_item_main` and extract `mod_spawn_item_addon_potion_resurrection.zip` into the same `data` directory.

Do not remove the main mod from a save while a brother has a resurrection effect.

## Configuration and logging

All gameplay and balance values are configurable through the MSU settings pages: health restoration, armor restoration, base price, level scaling, availability, stock, and Legendary-potion settlement restriction.

`Debug Logging` is also available on the MSU General page and defaults to enabled. Global Developer Test overrides this value while installed. `[PotionResurrection]` diagnostic output is written to `C:\Users\gujar\Documents\Battle Brothers\log.html`.

## Legends Compatibility

Legends is supported. Potion of Resurrection adds stock after Legends finishes filling marketplace and alchemist stashes. Existing shop stashes receive the new items on their next stock refresh.

## Known Issues
 - after death animation the character became invincible but can be controlled , moving the character do different tile would make them re-appear
