# README and Logging Default Design

## Goal

Make installation and dependency requirements easy for players to understand, disclose the simulated resurrection animation's visual limitation, and disable debug logging by default without removing diagnostic code.

## README structure

The README will contain concise sections for features, required dependencies, optional Item Spawner support, default balance, installation, configuration and logging, known visual limitations, and contributor release notes.

Modern Hooks and MSU 1.9.0 or newer are the only dependencies of the main mod. Item Spawner (`mod_spawn_item_main`) is optional and is required only when the separately packaged Item Spawner compatibility addon is installed. Installation instructions will keep the main archive and compatibility addon distinct.

## Animation note

The known-limitations section will explain that the mod intercepts lethal damage before Battle Brothers creates a real corpse. It simulates death by fading the actor out, briefly hiding them, and then playing the native rise animation. This safe approach avoids the vanilla corpse pipeline but can make the transition look slightly unusual.

## Logging behavior

Debug output will be disabled with `::PotionResurrection.Mod.Debug.disable();`, following the working `mod_aura_routing` pattern. The current `EnableDebugLogging` setting and callback will be removed so they cannot re-enable output after the hard-coded disable. Existing `[PotionResurrection]` log statements and their prefix will remain intact for a future configurable logging option.

## Verification

Repository validation will assert that `Debug.disable()` is called, the obsolete toggle wiring is absent, and the underlying logging code remains present. README validation will assert the optional Item Spawner dependency and simulated-animation limitation are documented. The release archives will then be rebuilt and inspected.
