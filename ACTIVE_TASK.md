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

Нет активной задачи. Цель Discovery: закрыть вопросы Q-01…Q-08 и перевести `GAME_SPEC.md`
в `READY`.

## In scope

- чтение репозитория и уточнение спецификации;
- запись подтверждённых ответов в `GAME_SPEC.md` и `docs/`.

## Out of scope

- любой игровой код, сцены забоя, генерация скалы, экономика;
- новые зависимости, плагины и ассеты;
- изменение `architecture/policy.json`, в том числе ради перехода на C#.

## Acceptance criteria

Задача появится здесь, когда спецификация станет `READY` и Phase 1 откроется.

## Progress

Пусто.

## Validation evidence

- `python tools/validate_project.py` — проходит (2026-11-20).
- `python tools/validate_game_spec.py` — DRAFT, phase 0, версия 3 (2026-11-20).
- `godot --headless --path . --editor --quit` — импорт проходит (2026-11-20).

## Blockers

- Спецификация `DRAFT`: Q-01 (условия провала), Q-02 (сохранения), Q-03 (управление),
  Q-04 (масштаб времени), Q-05 (GDScript или C#), Q-06 (режим встречной проходки),
  Q-07 (подход к скале), Q-08 (утверждение MVP) не закрыты.

## Next exact action

Запросить у владельца ответы на Q-01…Q-08 из `GAME_SPEC.md`, раздел 26, затем записать решения в
спецификацию и снять маркеры `[BLOCKER]`.

## Session handoff

Дизайн-документ собран почти полностью (три фрагмента) и переписан в спецификацию версии 3.
Следующий шаг — только работа со спецификацией, без кода.
