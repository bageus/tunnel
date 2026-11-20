class_name StubbornRegistry
extends RefCounted

## Отметки упорных блоков.
##
## Дизайн-документ, раздел 4.2: кусок особо плотной породы, который текущим инструментом не разбить,
## игрок не блокирует — копает дальше, участок помечается и остаётся до возврата с лучшим
## инструментом. Здесь хранятся только отметки: сама порода и её твёрдость остаются в профиле.

const KEY_SEPARATOR := ":"

var last_error: String = ""

var _marks: Dictionary = {}


func _key(chunk_index: Vector3i, block: Vector3i) -> String:
	return "%d,%d,%d%s%d,%d,%d" % [
		chunk_index.x, chunk_index.y, chunk_index.z, KEY_SEPARATOR,
		block.x, block.y, block.z,
	]


func mark(chunk_index: Vector3i, block: Vector3i, rock_id: String, zone: int) -> bool:
	if rock_id.is_empty():
		last_error = "a stubborn mark needs a rock id"
		return false
	if zone < 1 or zone > 5:
		last_error = "zone %d is outside 1..5" % zone
		return false
	_marks[_key(chunk_index, block)] = {"rock_id": rock_id, "zone": zone}
	last_error = ""
	return true


func has(chunk_index: Vector3i, block: Vector3i) -> bool:
	return _marks.has(_key(chunk_index, block))


## Снимает отметку: блок пробили или он больше не интересен.
func unmark(chunk_index: Vector3i, block: Vector3i) -> bool:
	var key := _key(chunk_index, block)
	if not _marks.has(key):
		last_error = "no stubborn mark at chunk %s block %s" % [chunk_index, block]
		return false
	_marks.erase(key)
	last_error = ""
	return true


func get_mark(chunk_index: Vector3i, block: Vector3i) -> Dictionary:
	return (_marks.get(_key(chunk_index, block), {}) as Dictionary).duplicate()


func count() -> int:
	return _marks.size()


func clear() -> void:
	_marks.clear()


func serialize() -> Dictionary:
	var rows: Array = []
	var keys: Array = _marks.keys()
	keys.sort()
	for key: String in keys:
		var parts: PackedStringArray = key.split(KEY_SEPARATOR)
		var chunk_parts: PackedStringArray = parts[0].split(",")
		var block_parts: PackedStringArray = parts[1].split(",")
		var mark_data: Dictionary = _marks[key]
		rows.append([
			int(chunk_parts[0]), int(chunk_parts[1]), int(chunk_parts[2]),
			int(block_parts[0]), int(block_parts[1]), int(block_parts[2]),
			str(mark_data["rock_id"]), int(mark_data["zone"]),
		])
	return {"marks": rows}


## Восстанавливает отметки из `serialize`. Возвращает null и печатает ошибку,
## если данные повреждены.
static func deserialize(data: Dictionary) -> StubbornRegistry:
	var rows: Variant = data.get("marks")
	if not rows is Array:
		push_error("stubborn data has no marks")
		return null
	var registry := StubbornRegistry.new()
	for row: Variant in rows:
		if not row is Array or row.size() != 8:
			push_error("a stubborn mark must be [chunk xyz, block xyz, rock, zone]")
			return null
		var chunk := Vector3i(int(row[0]), int(row[1]), int(row[2]))
		var block := Vector3i(int(row[3]), int(row[4]), int(row[5]))
		if not registry.mark(chunk, block, str(row[6]), int(row[7])):
			push_error("a stubborn mark is invalid: " + registry.last_error)
			return null
	return registry
