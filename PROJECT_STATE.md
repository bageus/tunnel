---
state_version: 1
status: IMPLEMENTATION
current_phase: 1
current_milestone: P1_LOGIC_PROTOTYPE
active_task_id: P1-002
last_completed_task_id: P1-001
build_status: PASS
updated: 2026-11-20
---

# Project State

This is the compact current truth about project progress. Update it after every material work session.

## Current outcome

Спецификация `READY` (версия 5): все вопросы Discovery закрыты, MVP утверждён, встречная проходка
отменена, вынутый материал — шесть видов. Готов первый модуль Phase 1: `core.block_grid` (сетка
блоков чанка, состояния, повреждение, компактная сериализация) с headless-тестами. Начата P1-002:
профиль твёрдости и реестр пород.

## Current phase

Phase 1 — Logic prototype. Пишется только доменная модель проходки и её тесты; сцены забоя,
экономика, производство и логистика запрещены до выхода из фазы.

## Current milestone

P1_LOGIC_PROTOTYPE — сетка блоков, профиль твёрдости по длине тоннеля, отбивание части блока,
выемка целого блока, упорные породы; правила покрыты тестами без сцены.

## Active task

P1-002 — `features.rock_profile`: профиль твёрдости по длине тоннеля и реестр 22 пород пяти зон.
Подробности в `ACTIVE_TASK.md`.

## Build and validation

- `python tools/validate_project.py` — проходит (READY, строгий режим), архитектура видит 2 модуля.
- `python tools/validate_source_size.py` — 0 предупреждений.
- `godot --headless --path . -s game/core/block_grid/tests/run_block_grid_tests.gd` — `0 failure(s)`,
  exit 0 (P1-001).
- `godot --headless --path . --editor --quit` — импорт проекта проходит (Godot 4.7.2).
- CI: Architecture validation и Domain tests — success на коммитах до появления первого набора тестов;
  workflow теперь импортирует проект перед прогоном доменных тестов.

## Known blockers

Блокеров нет. Неблокирующие вопросы N-01…N-13 — в `GAME_SPEC.md`, раздел 26.

## Next action

Выполнить P1-002: `features.rock_profile` — реестр пород и профиль твёрдости как данные, с тестами
без сцены.

## Handoff notes

- Готовые модули: `bootstrap.app` (сцена-заглушка), `core.block_grid` (P1-001).
- Точка входа проекта: `game/bootstrap/app/main.tscn`.
- Источник истины по дизайну: `GAME_SPEC.md`; исходный документ — `docs/GAME_DESIGN_SOURCE.md`.
- Слои: `core → features → presentation → infrastructure → bootstrap`; контракты только в `public/`.
- Локальный Godot: `D:\Godot\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`.
- Тесты запускать после `--editor --quit`, иначе сценарии без сцены падают на кэше классов.
