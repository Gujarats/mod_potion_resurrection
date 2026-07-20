# README and Logging Default Design

## Goal

Make installation and dependency requirements easy for players to understand, disclose the simulated resurrection animation's visual limitation, and disable debug logging by default without removing diagnostic code.

## README structure

The README will contain concise sections for features, required dependencies, optional Item Spawner support, default balance, installation, configuration and logging, known visual limitations, and contributor release notes.

Modern Hooks and MSU 1.9.0 or newer are the only dependencies of the main mod. Item Spawner (`mod_spawn_item_main`) is optional and is required only when the separately packaged Item Spawner compatibility addon is installed. Installation instructions will keep the main archive and compatibility addon distinct.

## Animation note

The known-limitations section will explain that the mod intercepts lethal damage before Battle Brothers creates a real corpse. It simulates death by fading the actor out, briefly hiding them, and then playing the native rise animation. This safe approach avoids the vanilla corpse pipeline but can make the transition look slightly unusual.

## Logging behavior

The `EnableDebugLogging` MSU setting will default to `false`. Existing `[PotionResurrection]` log statements, their prefix, setting callback, and runtime behavior will remain intact. Players can re-enable diagnostic logging from the MSU General settings page when troubleshooting.

## Verification

Repository validation will assert that debug logging defaults to disabled while the callback and logging code remain present. README validation will assert the optional Item Spawner dependency and simulated-animation limitation are documented. The release archives will then be rebuilt and inspected.
