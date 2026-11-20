class_name ToolDefinition
extends RefCounted

## Ручной инструмент проходчика: сила против твёрдости породы и повреждение за удар.
##
## Цепочка из дизайн-документа (раздел 17.1): долото → кирка → перфоратор → отбойный молоток →
## ручной бур → механический бур → проходческий комбайн → автоматические буры. Здесь описаны только
## первые пять: остальные появятся вместе с автоматизацией.
##
## Сила стартовых инструментов — предположение A-07, уточняется после замера в P1-005.

var id: String
var name_ru: String
var power: float
var damage_per_hit: int
## Может ли инструмент сверлить отверстия под закладку и выемку блока (раздел 15.3).
var can_drill: bool = false
## Наибольший размер блока, который этим буром можно освободить: 1 малый, 2 большой, 3 огромный.
var drill_cap: int = 0


func _init(
	tool_id: String = "",
	display_name: String = "",
	tool_power: float = 1.0,
	tool_damage: int = 20,
	drills: bool = false,
	drill_capacity: int = 0
) -> void:
	id = tool_id
	name_ru = display_name
	power = tool_power
	damage_per_hit = tool_damage
	can_drill = drills
	drill_cap = drill_capacity


## Инструменты по порядку цепочки: сила 1.0…5.0 совпадает с твёрдостью зон I–V.
static func catalog() -> Array:
	return [
		ToolDefinition.new("chisel", "Долото/зубило", 1.0, 20, false, 0),
		ToolDefinition.new("pickaxe", "Кирка", 2.0, 30, false, 0),
		ToolDefinition.new("perforator", "Перфоратор", 3.0, 45, true, 1),
		ToolDefinition.new("jackhammer", "Отбойный молоток", 4.0, 60, true, 2),
		ToolDefinition.new("hand_drill", "Ручной бур", 5.0, 70, true, 3),
	]


static func by_id(tool_id: String) -> ToolDefinition:
	for tool: ToolDefinition in catalog():
		if tool.id == tool_id:
			return tool
	return null


## Может ли инструмент вообще брать породу такой твёрдости.
func can_break(hardness: float) -> bool:
	return power >= hardness


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name_ru": name_ru,
		"power": power,
		"damage_per_hit": damage_per_hit,
		"can_drill": can_drill,
		"drill_cap": drill_cap,
	}
