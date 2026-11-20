class_name BlockChunk
extends RefCounted

## Сетка блоков одного чанка породы: адресация, состояние блока и компактная
## сериализация состояния.
##
## Чанк не знает о генерации, мешах, коллизиях и инструментах: это чистые
## доменные данные. Удары и выемка блока приходят из `features.excavation`.
##
## Хранятся только изменённые блоки: целый блок в словаре отсутствует, поэтому
## пустой чанк занимает ноль памяти, а сохранение содержит список изменений.

const State := preload("res://game/core/block_grid/public/block_state.gd")

const DEFAULT_SIZE := Vector3i(8, 8, 8)
const DEFAULT_BLOCK_SIZE_M := 1.0
const MAX_DAMAGE := 100

var chunk_index: Vector3i
var size: Vector3i
var block_size_m: float
var last_error: String = ""

var _states: Dictionary = {}
var _damage: Dictionary = {}


func _init(
	chunk_position: Vector3i = Vector3i.ZERO,
	chunk_size: Vector3i = DEFAULT_SIZE,
	block_size: float = DEFAULT_BLOCK_SIZE_M
) -> void:
	chunk_index = chunk_position
	size = chunk_size
	block_size_m = block_size


func block_count() -> int:
	return size.x * size.y * size.z


func changed_block_count() -> int:
	return _states.size()


func is_inside(pos: Vector3i) -> bool:
	return (
		pos.x >= 0 and pos.y >= 0 and pos.z >= 0
		and pos.x < size.x and pos.y < size.y and pos.z < size.z
	)


func index_of(pos: Vector3i) -> int:
	if not is_inside(pos):
		return -1
	return pos.x + size.x * (pos.y + size.y * pos.z)


func position_of(index: int) -> Vector3i:
	if index < 0 or index >= block_count():
		return Vector3i(-1, -1, -1)
	var x := index % size.x
	var y := (index / size.x) % size.y
	var z := index / (size.x * size.y)
	return Vector3i(x, y, z)


## Возвращает `BlockState.Kind.INTACT|PARTIAL|REMOVED` или -1 для блока вне чанка.
func state_of(pos: Vector3i) -> int:
	var index := index_of(pos)
	if index < 0:
		last_error = "block %s is outside the chunk" % pos
		return -1
	return int(_states.get(index, State.Kind.INTACT))


## Возвращает степень повреждения 0–100 или -1 для блока вне чанка.
func damage_of(pos: Vector3i) -> int:
	var index := index_of(pos)
	if index < 0:
		last_error = "block %s is outside the chunk" % pos
		return -1
	return int(_damage.get(index, 0))


## Ставит состояние явно. Правила: переход только вперёд, PARTIAL хранит 1–99 %,
## REMOVED всегда 100 %, целый блок не хранит записи вовсе.
func set_state(pos: Vector3i, state: int, damage: int = 0) -> bool:
	var index := index_of(pos)
	if index < 0:
		last_error = "block %s is outside the chunk" % pos
		return false
	if not State.is_valid(state):
		last_error = "unknown block state %d" % state
		return false
	var current: int = int(_states.get(index, State.Kind.INTACT))
	if not State.transition_allowed(current, state):
		last_error = "block %s cannot go from %s to %s" % [
			pos, State.name_of(current), State.name_of(state)
		]
		return false
	match state:
		State.Kind.INTACT:
			if damage != 0:
				last_error = "an intact block cannot carry damage"
				return false
			_states.erase(index)
			_damage.erase(index)
		State.Kind.PARTIAL:
			if damage <= 0 or damage >= MAX_DAMAGE:
				last_error = "a partial block needs damage 1..99, got %d" % damage
				return false
			_states[index] = State.Kind.PARTIAL
			_damage[index] = damage
		State.Kind.REMOVED:
			_states[index] = State.Kind.REMOVED
			_damage[index] = MAX_DAMAGE
	last_error = ""
	return true


## Наносит повреждение. Возвращает true, если удар принят; итоговое состояние
## и повреждение читаются через `state_of` и `damage_of`.
func apply_damage(pos: Vector3i, amount: int) -> bool:
	if amount <= 0 or amount > MAX_DAMAGE:
		last_error = "damage must be 1..100, got %d" % amount
		return false
	var current := state_of(pos)
	if current < 0:
		return false
	if current == State.Kind.REMOVED:
		last_error = "block %s is already removed" % pos
		return false
	var total := damage_of(pos) + amount
	if total >= MAX_DAMAGE:
		return set_state(pos, State.Kind.REMOVED)
	return set_state(pos, State.Kind.PARTIAL, total)


## Убирает блок целиком — например, когда его вынули после насверливания.
func remove_block(pos: Vector3i) -> bool:
	return set_state(pos, State.Kind.REMOVED)


func count_blocks(state: int) -> int:
	if not State.is_valid(state):
		last_error = "unknown block state %d" % state
		return -1
	if state == State.Kind.INTACT:
		return block_count() - _states.size()
	var total := 0
	for value: Variant in _states.values():
		if int(value) == state:
			total += 1
	return total


## Мировой центр-угол блока: начало блока в метрах.
func block_world_origin(pos: Vector3i) -> Vector3:
	if not is_inside(pos):
		last_error = "block %s is outside the chunk" % pos
		return Vector3.INF
	var global_block := Vector3(chunk_index * size) + Vector3(pos)
	return global_block * block_size_m


## Мировой блок, в который попадает точка, в локальных индексах этого чанка.
func world_to_block(world: Vector3) -> Vector3i:
	var global_block := Vector3i((world / block_size_m).floor())
	return global_block - chunk_index * size


func contains_world(world: Vector3) -> bool:
	return is_inside(world_to_block(world))


## Компактное состояние: только изменённые блоки, отсортированные по индексу.
func serialize() -> Dictionary:
	var changed: Array = []
	var indexes: Array = _states.keys()
	indexes.sort()
	for index: int in indexes:
		changed.append([index, _states[index], _damage[index]])
	return {
		"chunk": [chunk_index.x, chunk_index.y, chunk_index.z],
		"size": [size.x, size.y, size.z],
		"block_size_m": block_size_m,
		"changed": changed,
	}


## Восстанавливает чанк из данных `serialize`. Возвращает null и печатает ошибку,
## если данные повреждены.
static func deserialize(data: Dictionary) -> BlockChunk:
	var chunk_values: Variant = data.get("chunk")
	var size_values: Variant = data.get("size")
	var changed: Variant = data.get("changed")
	if not chunk_values is Array or not size_values is Array or not changed is Array:
		push_error("block chunk data is missing chunk, size or changed")
		return null
	if chunk_values.size() != 3 or size_values.size() != 3:
		push_error("block chunk chunk/size must have three components")
		return null
	var chunk := Vector3i(int(chunk_values[0]), int(chunk_values[1]), int(chunk_values[2]))
	var chunk_size := Vector3i(int(size_values[0]), int(size_values[1]), int(size_values[2]))
	if chunk_size.x <= 0 or chunk_size.y <= 0 or chunk_size.z <= 0:
		push_error("block chunk size must be positive")
		return null
	var block_size := float(data.get("block_size_m", DEFAULT_BLOCK_SIZE_M))
	var chunk_data := BlockChunk.new(chunk, chunk_size, block_size)
	var total := chunk_data.block_count()
	for entry: Variant in changed:
		if not entry is Array or entry.size() != 3:
			push_error("block chunk entry must be [index, state, damage]")
			return null
		var index := int(entry[0])
		var state := int(entry[1])
		var damage := int(entry[2])
		if index < 0 or index >= total:
			push_error("block chunk entry index %d is outside the chunk" % index)
			return null
		if not chunk_data.set_state(chunk_data.position_of(index), state, damage):
			push_error("block chunk entry is invalid: " + chunk_data.last_error)
			return null
	return chunk_data
