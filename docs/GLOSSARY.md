# Project Glossary

Use one stable term for each game concept. AI agents must consult this file before introducing synonyms in code or documentation.

## Rules

- Add a term when it has project-specific meaning.
- Prefer player-facing language unless a technical distinction is required.
- Give IDs stable `snake_case` forms.
- Rename through an explicit migration; do not leave mixed terminology.

## Terms

### Process

| Term | Stable ID | Meaning | Not the same as |
|---|---|---|---|
| Phase | phase | Major development stage numbered 0–8 | Milestone or task |
| Milestone | milestone | Measurable outcome inside a phase | Calendar deadline |
| Task | task | One small verifiable unit of work | Broad feature idea |
| Module | module | Architecture boundary with one coherent capability | Folder chosen only for organization |

### Game (confirmed by the source document)

| Term | Stable ID | Meaning | Not the same as |
|---|---|---|---|
| Тоннель | tunnel | Автомобильный тоннель сквозь гору; целевая длина 10 игровых км | Любая выработка или пещера |
| Портал | portal | Вход в тоннель с одной из сторон горы; порталов два | Забой |
| Смыкание | breakthrough | Момент встречи двух проходок в центре горы (~5 км от каждого портала) | Проходка |
| Проходка | excavation | Продвижение забоя в породе; скорость зависит от инструмента и твёрдости | Добыча сырья ради продажи |
| Забой | face | Передняя стенка выработки, где идёт работа | Весь тоннель |
| Зона пород | rock_zone | Один из пяти слоёв по глубине: верхняя, средняя, глубинная, глубокие слои, рудная | Отдельная порода |
| Твёрдость | hardness | Свойство породы: мягкая, средняя, твёрдая, очень твёрдая, сверхтвёрдая | Прочность крепи |
| Упорный участок | stubborn_section | Сверхтвёрдый участок в рудной зоне, требующий особого подхода | Обычная твёрдая порода |
| Долото/зубило | chisel | Стартовый ручной инструмент игрока | Бур или динамит |
| Крепь | support | Элементы, удерживающие породу | Леса как доступ к верху забоя |
| Леса | scaffolding | Временная конструкция для доступа к верхней части забоя | Постоянная крепь |
| Порода | rock | Материал, который проходит игрок | Изделие |
| Трасса | alignment | Запланированное направление тоннеля | Пройденный путь |
| Встречная проходка | counter_heading | Проходка с противоположной стороны навстречу; снижает гринд | Ускорение текущего забоя |
| Участок | site | Место работ: инструменты, крепь, свет, откат, снабжение | Отдельная механика |
| Локальная база | local_base | Промежуточный лагерь на длинном тоннеле, экономящий время | Портал |
| Колодец и насос | well_and_pump | Средства борьбы с водой в выработке | Декор |
| Дробилка | crusher | Оборудование первичной переработки породы | Печь или станок |
| Известь | lime | Продукт дробления (вместе со щебнем и порошком) | Изделие |
| Щебень | crushed_stone | Продукт дробления | Изделие |
| Порошок | powder | Продукт дробления | Изделие |
| Изделие | product | Результат производства (печи, станки, прессы, мастерские) | Сырьё |
| Спрос | demand | Влияет на цену изделия при продаже | Цена |
| Качество | quality | Свойство изделия, влияющее на цену | Спрос |
| Отделка | finishing | Финальная стадия: облицовка тоннеля материалами из той же скалы | Укрепление |
| Откат породы | muck_haul | Удаление разрушенной породы из забоя | Производство изделий |

### Technical (confirmed by the source document)

| Term | Stable ID | Meaning | Not the same as |
|---|---|---|---|
| Чанк | chunk | Блок скалы, который генерируется и рендерится только вблизи игрока | Уровень |
| LOD | lod | Упрощённая геометрия далёких объектов и чанков | Отсечение |
| Occlusion culling | occlusion_culling | Отсечение невидимого за породой через `OccluderInstance3D` | LOD |
| MultiMesh | multimesh | Один draw call для тысяч одинаковых объектов | Инстансинг сцены |
| Resolution scaling | resolution_scaling | Понижение разрешения 3D при падении FPS через `Viewport.scaling_3d_scale` | Масштаб интерфейса |
| FPS-таргет | fps_target | Фиксированные 30 или 60 FPS; при просадке снижается качество, а не пропускаются кадры | Максимальный FPS |
| Стилизованный арт-реализм | stylized_realism | Целевой визуальный стиль игры | Фотореализм или cartoon |

Add remaining game-specific terms during discovery. Terms for systems whose sections are missing
(`GAME_SPEC.md`, Q-01) are not added until the owner supplies them.
