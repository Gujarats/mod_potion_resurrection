# README and Logging Default Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Rewrite the player-facing README, make Item Spawner explicitly optional, document the simulated-animation limitation, and hard-disable debug logging without removing diagnostic call sites.

**Architecture:** Follow the working `mod_aura_routing` pattern by calling the MSU logger's `disable()` method after mod initialization and removing toggle wiring that could re-enable it. Treat the README as the authoritative player-facing installation guide, and extend the existing PowerShell static validator to prevent dependency wording or logging behavior from regressing.

**Tech Stack:** Squirrel, MSU settings, Markdown, PowerShell, Git, ZIP release packaging.

## Global Constraints

- Modern Hooks and MSU 1.9.0 or newer remain required by the main mod.
- `mod_spawn_item_main` remains optional and is required only for the separate Item Spawner compatibility addon.
- Preserve all `[PotionResurrection]` diagnostic call sites and their prefix.
- Call `::PotionResurrection.Mod.Debug.disable();` during initialization.
- Remove the `EnableDebugLogging` setting and callback while logging is hard-disabled.
- Describe the visual sequence as simulated death, not real corpse resurrection.

---

### Task 1: Player documentation and logging default

**Files:**
- Modify: `README.md`
- Modify: `scripts/!mods_preload/mod_potion_resurrection.nut`
- Modify: `tools/test_potion_resurrection_layout.ps1`

**Interfaces:**
- Consumes: MSU's `Mod.Debug.disable()` logger API.
- Produces: hard-disabled debug output with preserved diagnostic call sites, plus player-facing dependency, installation, and limitation documentation.

- [x] **Step 1: Add failing static contracts**

Add README assertions for the headings `Required dependencies`, `Optional Item Spawner support`, `Installation`, `Configuration and logging`, and `Known visual limitation`. Assert the README names `mod_spawn_item_main` as optional and contains `simulated death`. Add this exact logger contract:

```powershell
'::PotionResurrection.Mod.Debug.disable();'
```

Keep these assertions so diagnostic code cannot be deleted:

```powershell
'Mod.Debug.printLog'
'[PotionResurrection]'
```

Add negative assertions for `EnableDebugLogging`, `debugLogSetting.addCallback`, and `Mod.Debug.setFlag("default"`.

- [x] **Step 2: Run the validator and confirm red state**

Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test_potion_resurrection_layout.ps1`.

Expected: FAIL because `Debug.disable()` is missing, the old toggle remains, and the README lacks the new structured headings.

- [x] **Step 3: Hard-disable logging without removing diagnostic calls**

In `scripts/!mods_preload/mod_potion_resurrection.nut`, remove the `EnableDebugLogging` setting, its callback, and its `setFlag` initialization. After creating the General settings page, add:

```squirrel
::PotionResurrection.Mod.Debug.disable(); // TODO: Replace with a user setting when configurable logging returns.
```

Do not remove `debugLog`, `printLog`, the `[PotionResurrection]` prefix, or any diagnostic call sites.

- [x] **Step 4: Rewrite the README**

Organize `README.md` into Overview, Features, Required dependencies, Optional Item Spawner support, Default balance, Installation, Configuration and logging, Known visual limitation, and Building and validation. State that the main archive does not require Item Spawner. Explain that installing the separate addon archive requires `mod_spawn_item_main`. Explain that diagnostic logging is currently hard-disabled while its code is retained. Explain the 250 ms fade, brief hidden interval, and native rise, and that this may look slightly unusual because no real corpse is created.

- [x] **Step 5: Run verification**

Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test_potion_resurrection_layout.ps1`, followed by `git diff --check`.

Expected: `Potion Resurrection layout validation passed.` and no whitespace errors.

- [x] **Step 6: Build and inspect release archives**

Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_release.ps1`.

Expected: both release ZIPs are created. Inspect the main archive and confirm its preload contains `::PotionResurrection.Mod.Debug.disable();` while `Mod.Debug.printLog` remains in the packaged service.

- [x] **Step 7: Commit**

```powershell
git add README.md scripts/!mods_preload/mod_potion_resurrection.nut tools/test_potion_resurrection_layout.ps1 docs/superpowers/plans/2026-07-20-readme-and-logging-default.md
git commit -m "docs: clarify optional addon and animation"
```
