class_name DrillRegistry
extends RefCounted

## Отверстия по блокам: адрес блока → `DrillState`.
##
## Хранятся только блоки, у которых есть хотя бы одно отверстие, поэтому реестр пуст, пока игрок
## не начал сверлить. Реестр сериализуется отдельно от сетки чанка: сетка знает, цел ли блок,
## а сверление — отдельное состояние.

const DrillStateScript := preload("res://game/features/extraction/public/drill_state.gd")

const SEPARATOR := ":"

var last_error: String = ""

var _states: Dictionary = {}


func _key(chunk_index: Vector3i, block: Vector3i) -> String:
	return "%d,%d,%d%s%d,%d,%d" % [
		chunk_index.x, chunk_index.y, chunk_index.z, SEPARATOR,
		block.x, block.y, block.z,
	]


func state_of(chunk_index: Vector3i, block: Vector3i) -> RefCounted:
	var key := _key(chunk_index, block)
	if not _states.has(key):
		_states[key] = DrillStateScript.new()
	return _states[key]


func has_holes(chunk_index: Vector3i, block: Vector3i) -> bool:
	var key := _key(chunk_index, block)
	if not _states.has(key):
		return false
	var state: RefCounted = _states[key]
	return state.hole_count() > 0


## Ставит отверстие на грань блока.
func drill(chunk_index: Vector3i, block: Vector3i, face: int) -> bool:
	var state: RefCounted = state_of(chunk_index, block)
	if not state.drill(face):
		last_error = state.last_error
		return false
	last_error = ""
	return true


func is_liberated(chunk_index: Vector3i, block: Vector3i) -> bool:
	if not _states.has(_key(chunk_index, block)):
		return false
	return bool((_states[_key(chunk_index, block)] as RefCounted).is_liberated())


func drilled_blocks() -> int:
	var total := 0
	for state: RefCounted in _states.values():
		if state.hole_count() > 0:
			total += 1
	return total


func clear(chunk_index: Vector3i, block: Vector3i) -> void:
	_states.erase(_key(chunk_index, block))


func serialize() -> Dictionary:
	var rows: Array = []
	var keys: Array = _states.keys()
	keys.sort()
	for key: String in keys:
		var state: RefCounted = _states[key]
		if state.hole_count() == 0:
			continue
		var parts: PackedStringArray = key.split(SEPARATOR)
		var chunk_parts: PackedStringArray = parts[0].split(",")
		var block_parts: PackedStringArray = parts[1].split(",")
		rows.append([
			int(chunk_parts[0]), int(chunk_parts[1]), int(chunk_parts[2]),
			int(block_parts[0]), int(block_parts[1]), int(block_parts[2]),
			int((state.serialize() as Dictionary)["mask"]),
		])
	return {"blocks": rows}


static func deserialize(data: Dictionary) -> DrillRegistry:
	var rows: Variant = data.get("blocks")
	if not rows is Array:
		push_error("drill data has no blocks")
		return null
	var registry := DrillRegistry.new()
	for row: Variant in rows:
		if not row is Array or row.size() != 7:
			push_error("a drill row must be [chunk xyz, block xyz, mask]")
			return null
		var state: RefCounted = DrillStateScript.deserialize({"mask": int(row[6])})
		if state == null:
			return null
		var chunk := Vector3i(int(row[0]), int(row[1]), int(row[2]))
		var block := Vector3i(int(row[3]), int(row[4]), int(row[5]))
		registry._states[registry._key(chunk, block)] = state
	return registry
