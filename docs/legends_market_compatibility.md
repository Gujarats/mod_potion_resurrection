# Legends Market Compatibility Plan

## Goal

Make Potion of Resurrection stock its existing Normal, Medium, and High potions in Legends marketplaces and alchemists without changing vanilla behavior.

## Root Cause

Legends replaces `building.fillStash` and does not call vanilla `onAfterFillStash`. Potion of Resurrection loads, but its existing market hooks never receive a stock-generation callback.

## Implementation

1. Consolidate the existing market and alchemist stock code in `addMarketStock(_building, _stash, _isAlchemist)`.
2. Move the current `onAfterFillStash` registrations into `registerVanillaMarketHooks()`.
3. In non-Legends games, call `registerVanillaMarketHooks()`.
4. In Legends games, load a dedicated compatibility module after `mod_legends`.
5. Hook `building.fillStash`, call the original implementation, then add stock only for `building.marketplace` and `building.alchemist`.
6. Preserve spawn chances, stock settings, high-tier settlement restriction, price multiplier, and sorting.

## Verification

Confirm debug output in `C:\Users\gujar\Documents\Battle Brothers\log.html` reports the Legends post-fill injection. Refresh a shop stash or visit a newly generated settlement; existing saved stock is not retroactively changed.
