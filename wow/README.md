# wow/

SuperMacro macros, addon configs, and Interface/WTF snippets for the vanilla 1.12 client.

## Action bar 1 layout (the contract with scripts/paladin-overlay.ahk)

Overlay button → F-key → AHK → in-game key → slot:

| Slot / key | Overlay button | Intended macro (draft — refine once in-game) |
|---|---|---|
| 1 | F1 | Attack: target nearest enemy if none, start auto-attack, keep seal up |
| 2 | F2 | Judgement |
| 3 | F3 | Re-apply Seal (Righteousness or Command) |
| 4 | F4 | Consecration (if trained) / AoE |
| 5 | F5 | Holy Light downrank self-heal (`/cast [target=player]`-style via SuperMacro scripting — vanilla has no [target=] syntax, use `CastSpellByName("Holy Light(Rank 3)", 1)` for self) |
| 6 | F6 | Flash of Light self-heal |
| 7 | F7 | Defensive: Divine Protection / Divine Shield |
| 8 | F8 | Utility: mount / Hammer of Justice / Lay on Hands (decide) |

The exact macro texts should be authored with **SuperMacro** in-game and then the
saved file committed back here:
`WTF\Account\<ACCOUNT>\SavedVariables\SuperMacro.lua` → copy into `wow/SuperMacro.lua`.

## 1.12 macro notes

- Vanilla has no `/cast [conditionals]` — that's TBC+. Conditional logic needs Lua via
  SuperMacro (`/script` lines or SuperMacro's extended macro body).
- Useful primitives: `CastSpellByName("Spell")`, `CastSpellByName("Spell", 1)` (self-cast),
  `TargetNearestEnemy()`, `AttackTarget()`, `IsCurrentAction(slot)`.
- Keep one macro = one button = one press. The overlay has no modifier keys.

## What to commit here

- `SuperMacro.lua` SavedVariables (the real macro source of truth)
- Any edited `Interface/AddOns/*/` config files worth preserving
- Relevant `WTF/Config.wtf` lines (resolution, sound, etc.) as a snippet, not the whole file
