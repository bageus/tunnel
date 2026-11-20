---
state_version: 1
status: IMPLEMENTATION
current_phase: 1
current_milestone: P1_LOGIC_PROTOTYPE
active_task_id: P1-001
last_completed_task_id: NONE
build_status: PASS
updated: 2026-11-20
---

# Project State

This is the compact current truth about project progress. Update it after every material work session.

## Current outcome

Спецификация игры `READY` (версия 4): все вопросы Discovery закрыты ответами владельца, MVP
утверждён, встречная проходка отменена — игрок идёт от входного портала до выходного. Каркас правил
шаблона перенесён и проходит валидаторы, проект Godot 4.7.2 запускается. Началась Phase 1 —
логический прототип проходки.

## Current phase

Phase 1 — Logic prototype. Пишется только доменная модель проходки и её тесты; сцены забоя,
экономика, производство и логистика запрещены до выхода из фазы.

## Current milestone

P1_LOGIC_PROTOTYPE — сетка блоков чанка, профиль твёрдости по длине тоннеля, отбивание части блока,
выемка целого блока после насверливания, упорные породы; правила покрыты тестами без сцены.

## Active task

P1-001 — `core.block_grid`: сетка блоков внутри чанка, индексация, состояние блока (целый, частично
разрушен, вынут). Подробности в `ACTIVE_TASK.md`.

## Build and validation

- `python tools/validate_project.py` — проходит (валидаторы включены в строгом режиме, спецификация READY).
- `python tools/validate_game_spec.py --ready` — проходит.
- `python tools/validate_workflow_state.py --ready` — проходит.
- `godot --headless --path . --editor --quit` — импорт проекта проходит (Godot 4.7.2).
- CI на GitHub: Architecture validation и Domain tests — success на предыдущих коммитах.

## Known blockers

Блокеров нет. Открытые неблокирующие вопросы N-01…N-13 перечислены в `GAME_SPEC.md`, раздел 26.

## Next action

Выполнить P1-001: модуль `core.block_grid` с тестами без сцены — сетка блоков чанка, индексация,
состояние блока и сериализация состояния для сохранения.

## Handoff notes

- Точка входа проекта: `game/bootstrap/app/main.tscn`, модуль `bootstrap.app`.
- Источник истины по дизайну: `GAME_SPEC.md`; исходный документ — `docs/GAME_DESIGN_SOURCE.md`.
- Слои: `core → features → presentation → infrastructure → bootstrap`; контракты только в `public/`.
- Валидаторы в `tools/`, политика — `architecture/policy.json`.
- Локальный Godot: `D:\Godot\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`.
