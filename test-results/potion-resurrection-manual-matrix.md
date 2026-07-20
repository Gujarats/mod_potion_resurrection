# Potion of Resurrection Manual Test Matrix

Automated static checks run in this repository. The following tests require Battle Brothers with Modern Hooks and MSU. `PENDING` means the case has not been executed in the game runtime and is not a pass claim.

| Area | Test | Status | Evidence |
|---|---|---|---|
| Consumption and replacement | Consume each tier through inventory; consume a second tier on the same brother | PENDING | Requires game runtime |
| Save/load persistence | Save and reload with each tier effect active | PENDING | Requires game runtime |
| Multi-battle persistence | Finish battles without triggering the effect | PENDING | Requires game runtime |
| Restoration | Trigger Normal, Medium, and High with body/head armor | PENDING | Requires game runtime |
| Resurrection animation | Confirm particles, overhead icon, camera shake, native rise, and temporary non-attackable state | PENDING | Requires game runtime |
| Simulated death sequence | Confirm 250 ms fade-out, 600 ms hidden interval, native rise, and restored visibility/targeting | PENDING | Requires game runtime |
| Resurrection morale | Trigger resurrection while the brother is Fleeing; confirm morale becomes Steady and normal turns resume after the rise | PENDING | Requires game runtime |
| Sequence recovery | End a battle during the delay and verify no brother remains invisible or untargetable; review lifecycle logs | PENDING | Requires game runtime |
| Armor edge cases | Trigger with empty and destroyed armor slots | PENDING | Requires game runtime |
| Fatalities | Trigger on ordinary, DOT, decapitation, and disembowelment deaths | PENDING | Requires game runtime |
| One charge | Die a second time after a successful resurrection | PENDING | Requires game runtime |
| Kraken exclusion | Test Kraken and Devoured fatality types | PENDING | Requires game runtime |
| Script exclusions | Test scripted cleanup, retreat, and scenario cleanup | PENDING | Requires game runtime |
| Death side effects | Check corpse, obituary, statistics, equipment, and morale | PENDING | Requires game runtime |
| MSU settings | Change every setting, reload, and verify persistence | PENDING | Requires game runtime |
| Dynamic pricing | Test empty, one-member, uniform, and mixed-level rosters | PENDING | Requires game runtime |
| Market distribution | Refresh size-1, size-2, and size-3 alchemists with deterministic settings | PENDING | Requires game runtime |
| Item spawner compatibility | Search, spawn, consume, and trigger all tiers | PENDING | Requires game runtime |
| Legends compatibility | Run consumption, resurrection, and market smoke tests with Legends | PENDING | Requires game runtime |
