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
`DRAFT` версии 2: из дизайн-документа получены шапка, разделы 1–4 (концепция, цикл, масштаб горы,
начало инструментов) и хвост 20.6–22 (перспектива, оптимизация, сводная таблица систем).

## Current phase

Phase 0 — Discovery and specification. Игровой код не пишется: сначала закрываются вопросы
Q-01…Q-05 из `GAME_SPEC.md`.

## Current milestone

M0_DISCOVERY — получить утраченные разделы 4.1–20.5 и решения по провалу, сохранениям, управлению и
масштабу времени, чтобы перевести `GAME_SPEC.md` в `READY`.

## Active task

None. `ACTIVE_TASK.md` в состоянии `EMPTY/NONE` — это требование режима Discovery.

## Build and validation

- `python tools/validate_project.py` — проходит.
- `python tools/validate_game_spec.py` — структура валидна (DRAFT, phase 0, версия 2).
- `python tools/validate_workflow_state.py` — состояние непрерывности согласовано.
- `godot --headless --path . --editor --quit` — импорт проекта проходит (Godot 4.7.2).
- CI на GitHub: Architecture validation и Domain tests — success (коммит `e1c093d`).

## Known blockers

- Q-01: отсутствуют разделы 4.1–20.5 дизайн-документа (инструменты, навигация, освещение,
  производство, лаборатория, сортировка, логистика, базы, вода, динамит, экономика, улучшения,
  отделка, техническая реализация).
- Q-02: не определено, что считается провалом (победа описана: смыкание, укрепление, свет, отделка).
- Q-03: неизвестно, есть ли сохранение прогресса тоннеля и как хранятся чанки.
- Q-04: не определена карта управления и нужны ли режимы вне первого лица (карта, план трассы).
- Q-05: не определён масштаб времени на 10 игровых километров.

## Next action

Запросить у владельца разделы 4.1–20.5 дизайн-документа и ответы на Q-02…Q-05 (сформулированы в
`GAME_SPEC.md`, раздел 26), затем записать ответы в спецификацию.

## Handoff notes

- Точка входа проекта: `game/bootstrap/app/main.tscn`, модуль `bootstrap.app` (`module.json`).
- Источник истины по дизайну: `docs/GAME_DESIGN_SOURCE.md` (два фрагмента документа версии 1.1).
- Валидаторы в `tools/`, архитектурная политика — `architecture/policy.json`.
- Локальный Godot: `D:\Godot\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`.
- Экспортных пресетов и workflow экспорта пока нет; появится после Phase 4 (T025 в бэклоге).
