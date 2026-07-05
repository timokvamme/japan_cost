# Shadow PC setup checklist — OctoWoW 1.12 + phone touch overlay

Status legend: `[ ]` todo · `[x]` done (add date + note in `docs/machine-log.md` when checking off)

## 1. OctoWoW client install

- [ ] Download the client from the official site: https://octowow.st (client or launcher —
      prefer whatever the site currently recommends; log the exact download used).
- [ ] Install location: **`C:\Games\OctoWoW\`** (proposed convention — keep it short,
      outside `Program Files` to avoid UAC/permission issues with addons and WTF writes).
- [ ] Verify the client runs and reaches the login screen before any tweaking.
- [ ] Note client version/build in `docs/machine-log.md`.

## 2. Realmlist configuration

- [ ] Edit `C:\Games\OctoWoW\realmlist.wtf` to contain:

      set realmlist 185.165.170.33
      set patchlist 185.165.170.33

      Source: official OctoWoW forum ("Realmlist" thread, staff-confirmed). **Verify
      against https://octowow.st before use** — server IPs change; if the launcher
      manages the realmlist itself, let it and note that instead.
- [ ] If the file keeps getting overwritten, set it read-only and log that.
- [ ] Log in and confirm the **Y'Shaarj (PvP)** realm is listed and the paladin appears.

## 3. Addon setup (1.12 API only — modern addons will NOT load)

Addons go in `C:\Games\OctoWoW\Interface\AddOns\<AddonName>\`.
Each folder must directly contain the addon's `.toc` file (watch for GitHub-zip double
nesting: `AddonName-master/AddonName/`).

- [ ] **SuperMacro** — extended macro length + `/in`, scripting; core of the rotation setup.
- [ ] QoL candidates (all have 1.12 versions; install as needed, log each):
  - [ ] **pfUI** or **pfQuest** — modern-feeling UI / quest helper for 1.12
  - [ ] **Bagnon (vanilla fork)** or **EngBags** — one-bag inventory
  - [ ] **Atlas + AtlasLoot (1.12)** — dungeon maps/loot
  - [ ] **Clique or similar** — click-casting, useful for touchpad-mode healing
- [ ] Check OctoWoW's own website/Discord for a recommended-addons list first — custom
      "Vanilla+" servers often ship patched addon versions that work better with their
      custom content.
- [ ] After first login with addons: enable them on the character-select AddOns button
      (check "load out of date" if needed) and confirm no red Lua errors.
- [ ] Commit each installed addon's name+version+source URL to `docs/machine-log.md`,
      and any edited `SavedVariables`/config snippets to `wow/`.

## 4. In-game key bindings (the contract with the overlay)

The touch overlay only sends **F1–F8**. AutoHotkey translates F1–F8 → `1`–`8`
(see `scripts/paladin-overlay.ahk`), so in-game we only rely on the default binding:

- Action bar 1, slots 1–8 = keys `1`–`8` (WoW default — no in-game rebinding needed).
- [ ] Place the paladin macros (from `wow/`) on action bar 1, slots 1–8, in the
      documented order (see `wow/README.md`).
- [ ] Leave slots 9/0/-/= free for future overlay buttons.

## 5. Shadow-side key mapping plan (phone touch overlay)

- [ ] In the Shadow Android app, create/edit a **virtual gamepad / touch overlay layout**
      for WoW with **8 large buttons** mapped to keyboard keys **F1–F8**
      (2×4 grid on the right half of the folded screen is the starting proposal).
- [ ] Keep **touchpad mode** as the mouse: tap = left click, two-finger tap = right click
      (right click = interact/loot/attack in vanilla — verify sensitivity feels OK).
- [ ] Movement: start with overlay arrow keys or W/A/S/D buttons on the left side;
      revisit after first play session (turning with touchpad + autorun `Num Lock`
      may feel better — add an autorun button if so).
- [ ] Export/screenshot the final overlay layout and commit it under `docs/`
      (Shadow layouts live only in the app otherwise — they must be reconstructable).

## 6. AutoHotkey

- [ ] Install **AutoHotkey v2** from https://www.autohotkey.com (log version).
- [ ] Run `scripts/paladin-overlay.ahk`; verify F1–F8 pass through as 1–8 **only when
      the WoW window is focused**.
- [ ] Add the script to Startup (shell:startup shortcut) so a Shadow reboot doesn't
      silently drop the mapping. Log that too.
