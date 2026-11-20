---
task_version: 1
task_id: NONE
status: EMPTY
phase: 0
updated: 2026-11-20
---

# Active Task

This file holds the single active unit of work. While the game specification is `DRAFT`, it stays
`EMPTY/NONE` and the project remains in Discovery mode.

## Goal

Нет активной задачи. Цель Discovery: закрыть вопросы Q-01…Q-05 и перевести `GAME_SPEC.md`
в `READY`.

## In scope

- чтение репозитория и уточнение спецификации;
- запись подтверждённых ответов в `GAME_SPEC.md` и `docs/`.

## Out of scope

- любой игровой код, сцены забоя, генерация скалы, экономика;
- новые зависимости, плагины и ассеты;
- изменение `architecture/policy.json`.

## Acceptance criteria

Задача появится здесь, когда спецификация станет `READY` и Phase 1 откроется.

## Progress

Пусто.

## Validation evidence

- `python tools/validate_project.py` — проходит (2026-11-20).
- `godot --headless --path . --editor --quit` — импорт проходит (2026-11-20).

## Blockers

- Спецификация `DRAFT`: Q-01, Q-02, Q-03, Q-04, Q-05 не закрыты.

## Next exact action

Задать владельцу Q-01…Q-05 из `GAME_SPEC.md`, раздел 26, и записать ответы в спецификацию.

## Session handoff

Каркас перенесён и проверен; следующий шаг — только работа со спецификацией, без кода.
