class_name RockRegistry
extends RefCounted

## Реестр пород по зонам глубины (дизайн-документ, раздел 3).
##
## Зона I — верхняя, мягкая: 5 пород; II — средняя: 4; III — глубинная: 4;
## IV — глубокие слои: 4; V — рудная, сверхтвёрдая: 3. Всего 20 пород.
## Реестр только читают: это данные, а не состояние.

const RockDefinitionScript := preload("res://game/features/rock_profile/public/rock_definition.gd")

const ZONE_COUNT := 5
const ZONE_HARDNESS := {1: 1.0, 2: 2.0, 3: 3.0, 4: 4.0, 5: 5.0}
const ZONE_STUBBORN_CHANCE := {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.1, 5: 0.25}

const DATA := [
	{"id": "loam", "name_ru": "Суглинок", "zone": 1, "raw_materials": []},
	{"id": "clay", "name_ru": "Глина", "zone": 1, "raw_materials": ["clay"]},
	{"id": "sandstone", "name_ru": "Песчаник", "zone": 1, "raw_materials": ["sand"]},
	{"id": "limestone", "name_ru": "Известняк", "zone": 1, "raw_materials": ["lime"]},
	{"id": "chalk", "name_ru": "Мел", "zone": 1, "raw_materials": ["lime"]},
	{"id": "shale", "name_ru": "Сланец", "zone": 2, "raw_materials": []},
	{"id": "dolomite", "name_ru": "Доломит", "zone": 2, "raw_materials": []},
	{"id": "siliceous_sandstone", "name_ru": "Кремнистый песчаник", "zone": 2, "raw_materials": ["silica"]},
	{"id": "gypsum", "name_ru": "Гипс", "zone": 2, "raw_materials": ["gypsum"]},
	{"id": "granite", "name_ru": "Гранит", "zone": 3, "raw_materials": []},
	{"id": "diorite", "name_ru": "Диорит", "zone": 3, "raw_materials": []},
	{"id": "basalt", "name_ru": "Базальт", "zone": 3, "raw_materials": []},
	{"id": "marble", "name_ru": "Мрамор", "zone": 3, "raw_materials": ["marble"]},
	{"id": "gabbro", "name_ru": "Габбро", "zone": 4, "raw_materials": []},
	{"id": "porphyry", "name_ru": "Порфир", "zone": 4, "raw_materials": []},
	{"id": "quartzite", "name_ru": "Кварцит", "zone": 4, "raw_materials": ["quartz"]},
	{"id": "obsidian", "name_ru": "Обсидиан", "zone": 4, "raw_materials": ["obsidian"]},
	{"id": "skarn", "name_ru": "Скарн", "zone": 5, "raw_materials": ["iron_ore", "copper_ore"]},
	{"id": "ore_veins", "name_ru": "Жилы руд", "zone": 5, "raw_materials": ["silver", "gold"]},
	{"id": "crystalline_rock", "name_ru": "Кристаллические породы", "zone": 5, "raw_materials": ["rare_crystals"]},
]

var last_error: String = ""

var _rocks: Array = []
var _by_id: Dictionary = {}
var _by_zone: Dictionary = {1: [], 2: [], 3: [], 4: [], 5: []}


func _init(entries: Array = DATA) -> void:
	build(entries)


## Создаёт реестр по данным дизайн-документа.
static func default_registry() -> RockRegistry:
	return RockRegistry.new(DATA)


## Создаёт реестр из произвольных данных: id, name_ru, zone, raw_materials.
static func from_entries(entries: Array) -> RockRegistry:
	return RockRegistry.new(entries)


func build(entries: Array) -> bool:
	_rocks.clear()
	_by_id.clear()
	_by_zone = {1: [], 2: [], 3: [], 4: [], 5: []}
	for entry: Variant in entries:
		if not entry is Dictionary:
			last_error = "a rock entry must be a dictionary"
			return false
		var data: Dictionary = entry
		var rock_id: String = str(data.get("id", ""))
		if rock_id.is_empty():
			last_error = "a rock entry has no id"
			return false
		if _by_id.has(rock_id):
			last_error = "duplicate rock id '%s'" % rock_id
			return false
		var zone: int = int(data.get("zone", 0))
		if zone < 1 or zone > ZONE_COUNT:
			last_error = "rock '%s' has zone %d outside 1..%d" % [rock_id, zone, ZONE_COUNT]
			return false
		var rock: RefCounted = RockDefinitionScript.new(
			rock_id,
			str(data.get("name_ru", rock_id)),
			zone,
			float(ZONE_HARDNESS[zone]),
			data.get("raw_materials", [])
		)
		_rocks.append(rock)
		_by_id[rock_id] = rock
		(_by_zone[zone] as Array).append(rock)
	last_error = ""
	return true


func all() -> Array:
	return _rocks.duplicate()


func count() -> int:
	return _rocks.size()


func in_zone(zone: int) -> Array:
	return (_by_zone.get(zone, []) as Array).duplicate()


func zone_size(zone: int) -> int:
	return (_by_zone.get(zone, []) as Array).size()


func by_id(rock_id: String) -> RefCounted:
	if not _by_id.has(rock_id):
		last_error = "unknown rock id '%s'" % rock_id
		return null
	return _by_id[rock_id]


func hardness_of_zone(zone: int) -> float:
	return float(ZONE_HARDNESS.get(zone, 0.0))


func stubborn_chance_of_zone(zone: int) -> float:
	return float(ZONE_STUBBORN_CHANCE.get(zone, 0.0))


func is_valid() -> bool:
	return _rocks.size() > 0 and last_error.is_empty()
