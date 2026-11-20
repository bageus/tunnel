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

Репозиторий подключён к GitHub, проект Godot 4.7.2 запускается, каркас правил шаблона перенесён и
проходит валидаторы. Спецификация игры — `DRAFT` версии 3: дизайн-документ получен почти целиком
(шапка, разделы 1–4.1, 4.2–20.5, 20.6–22), описаны все 19 систем дизайна, включая планирование и
зелёную зону, освещение и леса, сырьё и 22 изделия, логистику из семи этапов, локальные базы,
встречную проходку, воду, динамит, экономику, пять деревьев улучшений, отделку и процедурную скалу.

## Current phase

Phase 0 — Discovery and specification. Игровой код не пишется: сначала закрываются вопросы
Q-01…Q-08 из `GAME_SPEC.md` и утверждается MVP.

## Current milestone

M0_DISCOVERY — решения по провалу, сохранениям, управлению, масштабу времени, языку реализации,
режиму встречной проходки и подходу к скале, плюс утверждение MVP, чтобы перевести `GAME_SPEC.md`
в `READY`.

## Active task

None. `ACTIVE_TASK.md` в состоянии `EMPTY/NONE` — требование режима Discovery.

## Build and validation

- `python tools/validate_project.py` — проходит.
- `python tools/validate_game_spec.py` — структура валидна (DRAFT, phase 0, версия 3).
- `python tools/validate_workflow_state.py` — состояние непрерывности согласовано.
- `godot --headless --path . --editor --quit` — импорт проекта проходит (Godot 4.7.2).
- CI на GitHub: Architecture validation и Domain tests — success на коммитах `e1c093d` и `5921311`.

## Known blockers

- Q-01: не определены условия провала (победа описана: смыкание, свет, отделка, награда за качество).
- Q-02: не определена политика сохранений (автосейв против точек, слоты, хранение чанков).
- Q-03: не определена карта управления и нужны ли экраны вне первого лица.
- Q-04: не определён масштаб времени на 10 игровых километров.
- Q-05: язык реализации — GDScript (правила шаблона) или C# (допускает документ).
- Q-06: не выбран режим встречной проходки (авто / две стороны / гибрид).
- Q-07: не выбран подход к скале (Marching Cubes воксели или меши на FastNoiseLite).
- Q-08: MVP не утверждён (предложение A-04 в разделе 21).

## Next action

Задать владельцу вопросы Q-01…Q-08 (сформулированы в `GAME_SPEC.md`, раздел 26), записать ответы и
перевести спецификацию в `READY`.

## Handoff notes

- Точка входа проекта: `game/bootstrap/app/main.tscn`, модуль `bootstrap.app` (`module.json`).
- Источник истины по дизайну: `docs/GAME_DESIGN_SOURCE.md` (три фрагмента документа версии 1.1).
- Валидаторы в `tools/`, архитектурная политика — `architecture/policy.json`.
- Локальный Godot: `D:\Godot\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe`.
- Экспортных пресетов и workflow экспорта пока нет; появится после Phase 4 (T031 в бэклоге).
