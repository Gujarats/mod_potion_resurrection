# Marketplace Stock Option Design

## Goal

Allow players to optionally stock Potion of Resurrection tiers in every town marketplace while preserving the current Alchemist distribution by default.

## Configuration

Add the Boolean MSU General setting `AddPotionsToAllMarketplaces`. Its default is `false`, so existing saves and new installations continue to stock potions only through the Alchemist unless the player opts in.

## Marketplace behavior

Hook `scripts/entity/world/settlements/buildings/marketplace_building.onAfterFillStash`. The southern marketplace inherits this class and therefore receives the same behavior. When the option is enabled, add Normal and Medium tiers to the shop stash through the existing configured spawn chance, stock, and price multiplier behavior. Add High only when `isHighTierSettlement(this.getSettlement())` permits it.

The existing Alchemist hook remains unchanged. Marketplace additions reuse the same per-tier chance, stock, base price, level scaling, and High-tier settlement restriction settings; no duplicate marketplace-specific balance settings are added. Sort the marketplace stash after additions.

## Compatibility and verification

The hook uses the vanilla `onAfterFillStash` extension point after the marketplace has generated its normal inventory. The validator will require the default-off setting, the marketplace hook, the enabled-setting guard, all three item scripts, the High-tier restriction, and stash sorting. Manual coverage will test northern and southern towns with the option both disabled and enabled.
