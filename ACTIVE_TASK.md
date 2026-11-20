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
- `python tools/validate_game_spec.py` — DRAFT, phase 0, версия 2 (2026-11-20).
- `godot --headless --path . --editor --quit` — импорт проходит (2026-11-20).

## Blockers

- Спецификация `DRAFT`: Q-01 (нет разделов 4.1–20.5), Q-02 (условия провала), Q-03 (сохранения),
  Q-04 (управление), Q-05 (масштаб времени) не закрыты.

## Next exact action

Запросить у владельца разделы 4.1–20.5 дизайн-документа и ответы на Q-02…Q-05 из `GAME_SPEC.md`,
раздел 26, затем записать ответы в спецификацию.

## Session handoff

Каркас перенесён и проверен; спецификация обновлена по двум фрагментам документа версии 1.1.
Следующий шаг — только работа со спецификацией, без кода.
