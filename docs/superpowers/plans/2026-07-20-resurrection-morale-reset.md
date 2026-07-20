# Resurrection Morale Reset Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Return a resurrected player actor to Steady morale before the staged resurrection animation begins.

**Architecture:** Extend the existing successful restoration path with one call to the player actor's vanilla `setMoraleState` method. The existing static PowerShell validator prevents placement regressions without requiring the Battle Brothers engine.

**Tech Stack:** Squirrel, Battle Brothers tactical actor API, PowerShell, Git, ZIP release packaging.

## Global Constraints

- Use `_actor.setMoraleState(::Const.MoraleState.Steady);`; do not assign `m.MoraleState` directly.
- Reset morale only after successful resurrection state restoration.
- Reset morale before `startResurrectionSequence`.
- Preserve all existing resurrection, logging, and visual behavior.

---

### Task 1: Reset revived morale

**Files:**
- Modify: `scripts/mods/potion_resurrection_service.nut`
- Modify: `tools/test_potion_resurrection_layout.ps1`
- Modify: `test-results/potion-resurrection-manual-matrix.md`

**Interfaces:**
- Consumes: `_actor.setMoraleState(_m)` from `scripts/entity/tactical/player` and `::Const.MoraleState.Steady`.
- Produces: a revived player actor with normal Steady morale before the simulated resurrection sequence.

- [x] **Step 1: Add a failing static contract**

Add this required service token to `tools/test_potion_resurrection_layout.ps1`:

```powershell
'_actor.setMoraleState(::Const.MoraleState.Steady);'
```

Add an ordering assertion that requires the morale-reset token to occur after `_actor.setDirty(true);` and before `::PotionResurrection.startResurrectionSequence(_actor, _source);`.

- [x] **Step 2: Run the validator and confirm red state**

Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test_potion_resurrection_layout.ps1`.

Expected: FAIL because the restore path has no morale reset.

- [x] **Step 3: Implement the native morale reset**

In `scripts/mods/potion_resurrection_service.nut`, add this line immediately after the restored actor state is marked dirty and before the staged sequence starts:

```squirrel
_actor.setMoraleState(::Const.MoraleState.Steady);
```

- [x] **Step 4: Record manual coverage**

Add a manual-matrix row requiring a resurrected brother who was Fleeing before the lethal hit to display Steady morale and receive normal turns after the native rise completes.

- [x] **Step 5: Verify, build, inspect, and commit**

Run `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\test_potion_resurrection_layout.ps1`, `git diff --check`, and `powershell -NoProfile -ExecutionPolicy Bypass -File .\tools\build_release.ps1`. Inspect the packaged service for the morale-reset token, then commit:

```powershell
git add scripts/mods/potion_resurrection_service.nut tools/test_potion_resurrection_layout.ps1 test-results/potion-resurrection-manual-matrix.md docs/superpowers/plans/2026-07-20-resurrection-morale-reset.md
git commit -m "fix: reset morale after resurrection"
```
