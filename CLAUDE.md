# Shadow-WoW Shared Workspace

> **Note on this repo/branch:** this structure lives on the `claude/shadow-wow-repo-init-*`
> branch of `timokvamme/japan_cost`, which otherwise contains unrelated research code.
> If the user decides to move this to a dedicated repo, this whole tree can be copied as-is.
> See `outbox/2026-07-05-repo-initialized.md` for the open question.

## Context

The target machine is a **Shadow PC** (cloud Windows gaming PC) used primarily to run
**OctoWoW**, a vanilla 1.12 World of Warcraft private server (character: **paladin** on
the **Y'Shaarj PvP realm**). The Shadow PC is streamed to an **Honor foldable Android
phone** via the Shadow app, so all controls ultimately need to work through a **touch
overlay mapped to keyboard keys**, plus touchpad mode for mouse.

Two (or more) Claude instances collaborate on this setup and share state through this repo:

1. **Shadow PC Claude** — Claude Code running on the Windows Shadow PC itself. It can
   install software, edit WoW config files, run AutoHotkey, and test in-game.
2. **App-side Claude** — Claude in the mobile/web app with its own sandbox and GitHub
   access. It drops instructions and files into `inbox/` and reads results from `outbox/`.
3. (This structure was bootstrapped by a third instance: Claude Code on the web, in a
   Linux cloud container — it has repo access but **no** access to the Shadow PC.)

## Repo layout

- `CLAUDE.md` — this briefing plus conventions, so future sessions have context immediately
- `inbox/` — instructions and files pushed from the app-side Claude for the Shadow PC Claude to act on
- `outbox/` — results, logs, and questions pushed back from the Shadow PC Claude
- `scripts/` — AutoHotkey scripts, install helpers, key remapping configs
- `wow/` — SuperMacro macros, addon configs, Interface/WTF snippets for the 1.12 client
- `docs/` — setup checklist, decisions made, troubleshooting notes, machine log

## Conventions

- **Pull before starting work, push when done.** Small, frequent commits.
- If something needs a decision from the user or the other Claude, write it as a
  **question file in `outbox/`** (or `inbox/` if you are the app-side Claude) rather
  than guessing. Name files `YYYY-MM-DD-short-topic.md`.
- **Everything lives in the repo.** Nothing important should exist only on the Shadow PC,
  since Shadow PCs can be reset. Any file installed or edited on the machine gets a copy
  or snippet committed under `scripts/` or `wow/`.
- Every install or system change on the Shadow PC gets a dated entry in
  `docs/machine-log.md` so machine state is always reconstructable.
- Processed inbox items: move them to `inbox/done/` (git mv) so the inbox only shows
  outstanding work.

## Key technical facts

- WoW client: vanilla **1.12** — addons use the old Lua API; modern addons will not work.
- OctoWoW realmlist (verify against https://octowow.st before use):
  `set realmlist 185.165.170.33` in `realmlist.wtf` in the WoW install folder.
- AutoHotkey scripts in `scripts/` are written for **AutoHotkey v2** unless a file
  header says otherwise.
- The phone touch overlay sends plain keyboard keys (currently planned: F1–F8);
  AHK translates those into whatever the action bars actually need.
