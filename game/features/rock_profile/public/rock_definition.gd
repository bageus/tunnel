class_name RockDefinition
extends RefCounted

## Описание одной породы: стабильный id, зона по глубине, твёрдость и сырьё,
## которое она даёт при переработке.

var id: String
var name_ru: String
var zone: int
var hardness: float
var raw_materials: Array


func _init(
	rock_id: String = "",
	display_name: String = "",
	rock_zone: int = 1,
	rock_hardness: float = 1.0,
	materials: Array = []
) -> void:
	id = rock_id
	name_ru = display_name
	zone = rock_zone
	hardness = rock_hardness
	raw_materials = materials.duplicate()


func to_dict() -> Dictionary:
	return {
		"id": id,
		"name_ru": name_ru,
		"zone": zone,
		"hardness": hardness,
		"raw_materials": raw_materials.duplicate(),
	}


static func from_dict(data: Dictionary) -> RockDefinition:
	var rock_id: String = str(data.get("id", ""))
	var display_name: String = str(data.get("name_ru", ""))
	var rock_zone: int = int(data.get("zone", 0))
	var rock_hardness: float = float(data.get("hardness", 0.0))
	var materials: Array = data.get("raw_materials", [])
	return RockDefinition.new(rock_id, display_name, rock_zone, rock_hardness, materials)
