# Shadow PC machine log

Every install, config edit, or system change on the Shadow PC gets a dated entry here,
newest first. Goal: the machine is fully reconstructable from this file + `scripts/` +
`wow/` after a Shadow reset.

Entry format:

```
## YYYY-MM-DD — short title
- What: what was installed/changed (exact version, download URL)
- Where: paths touched
- Why: one line
- Repo copy: which file in scripts/ or wow/ mirrors it (or "n/a")
```

---

## 2026-07-05 — repo bootstrapped (no machine changes)
- What: shared repo structure, docs, and AHK script created by the cloud-side Claude
  Code session. **Nothing has been installed or changed on the Shadow PC yet.**
- Where: repo only
- Why: give the Shadow PC Claude a ready checklist and scripts to pull on first session
- Repo copy: everything under `docs/`, `scripts/`, `wow/`
