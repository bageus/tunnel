---
state_version: 1
status: DISCOVERY
current_phase: 0
current_milestone: M0_DISCOVERY
active_task_id: NONE
last_completed_task_id: NONE
build_status: PASS
updated: 2026-11-20
---

# Project State

This is the compact current truth about project progress. Update it after every material work session.

## Current outcome

Репозиторий подключён к GitHub, проект Godot 4.7.2 запускается, каркас правил шаблона перенесён
(`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `AI_START_HERE.md`, `.cursor`, `.github`, `docs/`,
`architecture/policy.json`, `tools/validate_*`) и проходит валидаторы. Спецификация игры —
`DRAFT`: из дизайн-документа получены только разделы 20.6–22.

## Current phase

Phase 0 — Discovery and specification. Игровой код не пишется: сначала закрываются вопросы
Q-01…Q-05 из `GAME_SPEC.md`.

## Current milestone

M0_DISCOVERY — получить полный дизайн-документ и решения по жанру, цели, сохранению и вводу,
чтобы перевести `GAME_SPEC.md` в `READY`.

## Active task

None. `ACTIVE_TASK.md` в состоянии `EMPTY/NONE` — это требование режима Discovery.

## Build and validation

- `python tools/validate_game_spec.py` — структура спецификации валидна (DRAFT, phase 0).
- `python tools/validate_workflow_state.py` — состояние непрерывности согласовано.
- `python tools/validate_project.py` — проходит.
- `godot --headless --path . --editor --quit` — импорт проекта проходит (Godot 4.7.2).
- Сцена `game/bootstrap/app/main.tscn` запускается, печатает `tunnel: main scene ready`.

## Known blockers

- Q-01: отсутствуют разделы 1–20.5 исходного дизайн-документа.
- Q-02: не определён жанр и роль игрока (ручная проходка против менеджмента участка).
- Q-03: не определены цель, условие победы и поражения.
- Q-04: неизвестно, есть ли сохранение прогресса тоннеля.
- Q-05: не подтверждены устройства ввода и объём управления вне первого лица.

## Next action

Задать владельцу вопросы Q-01…Q-05 (они уже сформулированы в `GAME_SPEC.md`, раздел 26) и
записать ответы в спецификацию.

## Handoff notes

- Точка входа проекта: `game/bootstrap/app/main.tscn`, модуль `bootstrap.app` (`module.json`).
- Валидаторы лежат в `tools/`, архитектурная политика — `architecture/policy.json`.
- Локальный Godot: `D:\Godot\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`.
- HTML/артефактов и экспортных пресетов пока нет; экспорт появится после Phase 4.
