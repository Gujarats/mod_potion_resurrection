# Resurrection Potion Price Balance Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rebalance Potion of Resurrection default prices and availability so Normal is viable in early game, Medium is affordable in mid game, and High remains rare late-game insurance.

**Architecture:** Keep the existing MSU settings and item implementation. Change only the default setting values, README balance table, and static layout validator tokens; do not add new settings or alter runtime pricing logic.

**Tech Stack:** Battle Brothers Squirrel `.nut` scripts, Modern Hooks, MSU settings, PowerShell static layout validation.

## Global Constraints

- Normal default base price must be `200`.
- Medium default base price must be `600`.
- High default base price must be `1800`.
- Price scaling remains `5%` per averaged boundary roster level.
- Default availability: Normal `100%` chance and stock `2`, Medium `20%` chance and stock `1`, High `5%` chance and stock `1`.
- High potions remain restricted to size-3 settlements by default.
- Do not change resurrection mechanics, potion effects, item IDs, icons, marketplace hook behavior, or Item Spawner compatibility.

---

## File Structure

- `scripts/!mods_preload/mod_potion_resurrection.nut`: owns MSU setting defaults for price, restoration, availability, stock, and settlement restrictions.
- `README.md`: documents the default balance table visible to players.
- `tools/test_potion_resurrection_layout.ps1`: static validator that should lock the intended defaults into release checks.

### Task 1: Rebalance Defaults and Documentation

**Files:**
- Modify: `mod_potion_resurrection/scripts/!mods_preload/mod_potion_resurrection.nut`
- Modify: `mod_potion_resurrection/README.md`
- Modify: `mod_potion_resurrection/tools/test_potion_resurrection_layout.ps1`

**Interfaces:**
- Consumes: `general.addRangeSetting("PriceScalingPct", value, ...)`, tier `addRangeSetting("<Tier>BasePrice", value, ...)`, tier spawn chance and stock settings.
- Produces: updated default MSU values used by `::PotionResurrection.conf(...)` and `::PotionResurrection.getScaledPrice(_tier)`.

- [ ] **Step 1: Add failing layout assertions for the new balance**

In `mod_potion_resurrection/tools/test_potion_resurrection_layout.ps1`, extend the existing `Assert-Contains 'scripts/!mods_preload/mod_potion_resurrection.nut' @(...)` block with these required tokens:

```powershell
'general.addRangeSetting("PriceScalingPct", 5, 0, 100, 1, "Price Scaling per Level (%)"'
'normal.addRangeSetting("NormalBasePrice", 200, 0, 50000, 50, "Base Price"'
'normal.addRangeSetting("NormalSpawnChance", 100, 0, 100, 1, "Spawn Chance (%)"'
'normal.addRangeSetting("NormalStock", 2, 0, 10, 1, "Stock"'
'medium.addRangeSetting("MediumBasePrice", 600, 0, 50000, 50, "Base Price"'
'medium.addRangeSetting("MediumSpawnChance", 20, 0, 100, 1, "Spawn Chance (%)"'
'medium.addRangeSetting("MediumStock", 1, 0, 10, 1, "Stock"'
'high.addRangeSetting("HighBasePrice", 1800, 0, 50000, 50, "Base Price"'
'high.addRangeSetting("HighSpawnChance", 5, 0, 100, 1, "Spawn Chance (%)"'
'high.addRangeSetting("HighStock", 1, 0, 10, 1, "Stock"'
'general.addBooleanSetting("RestrictHighToLargeSettlements", true, "Restrict High Potions"'
```

- [ ] **Step 2: Run the layout validator and confirm it fails**

Run from `mod_potion_resurrection`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test_potion_resurrection_layout.ps1
```

Expected: failure mentioning missing tokens for `NormalBasePrice`, `MediumBasePrice`, `HighBasePrice`, and `PriceScalingPct`.

- [ ] **Step 3: Update the default MSU balance values**

In `mod_potion_resurrection/scripts/!mods_preload/mod_potion_resurrection.nut`, set these exact defaults:

```squirrel
general.addRangeSetting("PriceScalingPct", 5, 0, 100, 1, "Price Scaling per Level (%)", "Applied for each averaged boundary level of the active roster.");

normal.addRangeSetting("NormalBasePrice", 200, 0, 50000, 50, "Base Price", "Price before party-level and vanilla shop modifiers.");
normal.addRangeSetting("NormalSpawnChance", 100, 0, 100, 1, "Spawn Chance (%)", "Chance to add this tier during an alchemist refresh.");
normal.addRangeSetting("NormalStock", 2, 0, 10, 1, "Stock", "Copies added after a successful availability roll.");

medium.addRangeSetting("MediumBasePrice", 600, 0, 50000, 50, "Base Price", "Price before party-level and vanilla shop modifiers.");
medium.addRangeSetting("MediumSpawnChance", 20, 0, 100, 1, "Spawn Chance (%)", "Chance to add this tier during an alchemist refresh.");
medium.addRangeSetting("MediumStock", 1, 0, 10, 1, "Stock", "Copies added after a successful availability roll.");

high.addRangeSetting("HighBasePrice", 1800, 0, 50000, 50, "Base Price", "Price before party-level and vanilla shop modifiers.");
high.addRangeSetting("HighSpawnChance", 5, 0, 100, 1, "Spawn Chance (%)", "Chance to add this tier during an alchemist refresh.");
high.addRangeSetting("HighStock", 1, 0, 10, 1, "Stock", "Copies added after a successful availability roll.");
```

- [ ] **Step 4: Update player-facing balance documentation**

In `mod_potion_resurrection/README.md`, replace the default balance table with:

```markdown
| Tier | Health restored | Armor restored | Base price | Default availability | Default stock |
|---|---:|---:|---:|---:|---:|
| Normal | 50% | 25% | 200 crowns | 100% | 2 |
| Medium | 80% | 50% | 600 crowns | 20% | 1 |
| High | 100% | 100% | 1,800 crowns | 5% | 1 |
```

Keep the paragraph below the table, but ensure it says prices scale at `5%` per averaged level and High potions remain restricted to size-3 settlements by default.

- [ ] **Step 5: Run static validation**

Run from `mod_potion_resurrection`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test_potion_resurrection_layout.ps1
```

Expected: `Potion Resurrection layout validation passed.`

- [ ] **Step 6: Build release archives**

Run from `mod_potion_resurrection`:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_release.ps1
```

Expected: refreshed `release/mod_potion_resurrection.zip` and `release/mod_spawn_item_addon_potion_resurrection.zip`.

- [ ] **Step 7: Commit**

```powershell
git add scripts/!mods_preload/mod_potion_resurrection.nut README.md tools/test_potion_resurrection_layout.ps1 docs/superpowers/plans/2026-07-23-resurrection-potion-price-balance.md release/mod_potion_resurrection.zip release/mod_spawn_item_addon_potion_resurrection.zip
git commit -m "balance: adjust resurrection potion prices"
```

## Self-Review

- Spec coverage: the plan covers Normal `200`, Medium `600`, High `1800`, `5%` scaling, requested availability defaults, README documentation, validation, and release packaging.
- Placeholder scan: no placeholder terms are intentionally left for implementers.
- Type consistency: all setting keys match existing `::PotionResurrection.Tiers` entries and existing `::PotionResurrection.conf(...)` consumers.
