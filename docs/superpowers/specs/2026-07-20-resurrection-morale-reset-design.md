# Resurrection Morale Reset Design

## Goal

Ensure a brother resurrected by Potion of Resurrection immediately returns to normal battlefield morale instead of remaining in the Fleeing state.

## Cause

The mod restores an actor after lethal damage by intercepting `player.kill`. This bypasses Battle Brothers' normal post-combat morale cleanup, which would otherwise reset a player actor to `Steady`. The restored actor can therefore retain the morale state established by the lethal-damage sequence.

## Design

In `::PotionResurrection.restore`, after the actor's alive and dying state, hitpoints, armor, skills, and appearance are refreshed, call:

```squirrel
_actor.setMoraleState(::Const.MoraleState.Steady);
```

The call must occur before `startResurrectionSequence`, so the fade and native rise run on a normal, non-fleeing actor. Use the player's native morale setter rather than assigning `m.MoraleState` directly, so morale UI, skill updates, flee state, and zone-of-control behavior are refreshed by vanilla logic.

## Verification

The static validator will require the morale reset call after restoration state refresh and before the staged animation call. The manual matrix will include a test that a brother revived while fleeing returns to Steady and can take normal turns. Build and archive inspection will verify the packaged service contains the reset.
