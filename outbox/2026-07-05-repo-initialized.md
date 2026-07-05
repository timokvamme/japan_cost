# 2026-07-05 — Repo structure initialized (from cloud session)

**From:** Claude Code (web/cloud container — *not* the Shadow PC)
**Status:** repo scaffolding done; zero changes made to the Shadow PC itself.

## What exists now

- `CLAUDE.md` — briefing + conventions for all future sessions
- `docs/setup-checklist.md` — full install/config/overlay plan
- `docs/machine-log.md` — machine-state log (template + first entry)
- `scripts/paladin-overlay.ahk` — F1–F8 → 1–8, WoW-window-only, AHK v2
- `wow/README.md` — action-bar contract + 1.12/SuperMacro macro notes
- `inbox/`, `outbox/` — message directories per convention

## Questions needing a decision

1. **Dedicated repo?** This all lives on branch `claude/shadow-wow-repo-init-*` of
   `timokvamme/japan_cost`, which is otherwise a research repo. Options:
   (a) merge to `main` here anyway, (b) create a dedicated repo (e.g. `shadow-wow`)
   and copy this tree over. **(b) recommended** — keeps histories clean and lets the
   Shadow PC clone something small.
2. **Overlay key budget:** the plan assumes exactly 8 buttons (F1–F8) plus movement
   keys and touchpad mouse. Confirm the Shadow app overlay comfortably fits 8 buttons
   on the folded Honor screen, or tell us the real number.
3. **Slot 8 utility choice:** mount vs Hammer of Justice vs Lay on Hands (see `wow/README.md`).
4. **Realmlist:** using `set realmlist 185.165.170.33` from the official OctoWoW forum —
   Shadow PC Claude should verify against https://octowow.st on install day.
