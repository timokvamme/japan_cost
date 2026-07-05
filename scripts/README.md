# scripts/

AutoHotkey scripts, install helpers, and key-remapping configs for the Shadow PC.

| File | What it does |
|---|---|
| `paladin-overlay.ahk` | Maps F1–F8 (sent by the phone touch overlay) to action-bar keys 1–8, only while the WoW window is focused. AutoHotkey **v2**. |

Conventions:
- AutoHotkey v2 syntax unless the file header says otherwise.
- Any script actually running on the Shadow PC must be committed here AND noted in
  `docs/machine-log.md` (including how it's started — manual vs shell:startup).
