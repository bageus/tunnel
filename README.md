# tunnel

Godot 4.7 project. Минимальный скелет: главная сцена, точка входа на GDScript, настройки окна.

## Запуск

1. Открыть папку проекта в Godot 4.7 (или `godot --path .` из этой папки).
2. F5 — запуск главной сцены `scenes/main.tscn`.

Проверка из консоли без окна:

```bash
godot --headless --path . --quit-after 5
```

## Структура

```
project.godot      настройки проекта, главная сцена, рендер gl_compatibility
icon.svg           иконка проекта
scenes/main.tscn   главная сцена: фон + заголовок, корень Node2D
scripts/main.gd    точка входа: загрузка уровней, переходы, состояние игры
```

По мере роста проекта новые сцены кладём в `scenes/`, скрипты — в `scripts/`, ресурсы — в `assets/`.

## Git

Служебная папка `.godot/` и экспортные сборки в репозиторий не попадают (см. `.gitignore`).

```bash
git clone https://github.com/bageus/tunnel.git
```
