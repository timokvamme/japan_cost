; paladin-overlay.ahk — AutoHotkey v2
;
; Purpose: the Shadow app touch overlay on the phone only has a few large buttons,
; mapped to F1–F8. This script translates those into action-bar keys 1–8, but ONLY
; while the WoW 1.12 window is focused, so F-keys keep their normal meaning everywhere
; else on the Shadow PC.
;
; In-game contract (see docs/setup-checklist.md §4 and wow/README.md):
;   action bar 1, slots 1–8 hold the paladin macros, WoW-default keybinds 1–8.
;
; Install: AutoHotkey v2 (https://www.autohotkey.com), then run this script.
; Autostart: put a shortcut to this file in shell:startup.

#Requires AutoHotkey v2.0
#SingleInstance Force

; Vanilla 1.12 client window. If matching fails, check the real title/class with
; AHK's WindowSpy and adjust — some custom clients rename the window.
#HotIf WinActive("World of Warcraft") or WinActive("ahk_class GxWindowClassD3d")

F1::1   ; slot 1 — main attack / Seal + auto-attack macro
F2::2   ; slot 2 — Judgement
F3::3   ; slot 3 — re-seal (Seal of Righteousness / Command)
F4::4   ; slot 4 — Consecration / AoE
F5::5   ; slot 5 — Holy Light (downranked) self-heal macro
F6::6   ; slot 6 — Flash of Light self-heal macro
F7::7   ; slot 7 — defensive (Divine Protection/Shield, or Blessing refresh)
F8::8   ; slot 8 — utility (mount / Hammer of Justice / Lay on Hands — decide in wow/)

#HotIf
