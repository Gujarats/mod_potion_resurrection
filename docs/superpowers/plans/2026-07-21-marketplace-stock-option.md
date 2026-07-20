# Marketplace Stock Option Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a default-off MSU option that stocks resurrection potions in every northern and southern marketplace.

**Architecture:** Reuse the existing tier-stock helper and hook vanilla `marketplace_building.onAfterFillStash` after normal shop generation. One MSU General setting gates marketplace additions; the existing Alchemist hook remains unchanged.

**Tech Stack:** Squirrel, MSU settings, Battle Brothers settlement-building hooks, PowerShell, Git, ZIP release packaging.

## Global Constraints

- `AddPotionsToAllMarketplaces` defaults to `false`.
- The option does not alter Alchemist inventory behavior.
- Marketplace tiers reuse existing chance, stock, price, and High-tier size settings.
- High marketplace stock requires `isHighTierSettlement(this.getSettlement())`.
- Hook `marketplace_building` only; southern marketplaces inherit that class.

---

### Task 1: Optional marketplace inventory

**Files:**
- Modify: `scripts/!mods_preload/mod_potion_resurrection.nut`
- Modify: `scripts/mods/potion_resurrection_market.nut`
- Modify: `tools/test_potion_resurrection_layout.ps1`
- Modify: `test-results/potion-resurrection-manual-matrix.md`

**Interfaces:**
- Consumes: `::PotionResurrection.conf("AddPotionsToAllMarketplaces")`, the existing `addTierToAlchemist` helper, and vanilla `marketplace_building.onAfterFillStash(_stash)`.
- Produces: default-off marketplace potion stocking that uses existing tier configuration.

- [x] **Step 1: Add failing static contracts**

Add `AddPotionsToAllMarketplaces` to the preload required tokens. Add marketplace service contracts:

```powershell
'scripts/entity/world/settlements/buildings/marketplace_building'
'::PotionResurrection.conf("AddPotionsToAllMarketplaces")'
'q.onAfterFillStash = @(__original)'
'misc/resurrection_potion_normal_item'
'misc/resurrection_potion_medium_item'
'misc/resurrection_potion_high_item'
'isHighTierSettlement(this.getSettlement())'
'_stash.sort()'
```

- [x] **Step 2: Confirm red state**

Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test_potion_resurrection_layout.ps1`.

Expected: FAIL because the General setting and marketplace hook do not exist.

- [x] **Step 3: Add the default-off General setting**

In `scripts/!mods_preload/mod_potion_resurrection.nut`, add this setting to the existing General page:

```squirrel
general.addBooleanSetting("AddPotionsToAllMarketplaces", false, "Add Potions to All Marketplaces", "When enabled, add resurrection potions to northern and southern marketplace inventories using the configured tier chances and stock values.");
```

- [x] **Step 4: Hook marketplace inventory generation**

In `scripts/mods/potion_resurrection_market.nut`, add an `onAfterFillStash` hook for `marketplace_building`. Call the original method first. Return without additions unless `AddPotionsToAllMarketplaces` is enabled. Then call `addTierToAlchemist` for Normal and Medium; add High only behind `isHighTierSettlement(this.getSettlement())`; sort the stash once.

- [x] **Step 5: Add manual coverage**

Add matrix rows for northern and southern marketplace refreshes with the option disabled and enabled. Verify disabled marketplaces contain no added potions and enabled marketplaces honor tier chance, stock, and High-tier settlement restrictions.

- [x] **Step 6: Verify, build, inspect, and commit**

Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test_potion_resurrection_layout.ps1`, `git diff --check`, and `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_release.ps1`. Inspect the packaged preload and market service for the setting and hook. Commit:

```powershell
git add scripts/!mods_preload/mod_potion_resurrection.nut scripts/mods/potion_resurrection_market.nut tools/test_potion_resurrection_layout.ps1 test-results/potion-resurrection-manual-matrix.md docs/superpowers/plans/2026-07-21-marketplace-stock-option.md
git commit -m "feat: add optional marketplace potion stock"
```
