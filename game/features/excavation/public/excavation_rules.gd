class_name ExcavationRules
extends RefCounted

## Правила удара инструментом по породе. Модуль без состояния: все входы передаются явно,
## поэтому правила вызываются без сцены и проверяются тестами.
##
## Правила:
## 1. инструмент слабее породы — удар не принимается, блок помечается упорным (раздел 4.2);
## 2. иначе удар наносит `damage_per_hit`, повреждение копится в `core.block_grid`;
## 3. разрушенный блок даёт одну фракцию по твёрдости породы (D032).

const BlockStateScript := preload("res://game/core/block_grid/public/block_state.gd")
const ResultScript := preload("res://game/features/excavation/public/excavation_result.gd")

const FRACTION_FINE := "rock_fine"
const FRACTION_MEDIUM := "rock_medium"
const FRACTION_COARSE := "rock_coarse"

## Границы фракций по твёрдости: мягкая порода сыпется мелко, твёрдая отбивается куском.
const FINE_MAX_HARDNESS := 2.0
const MEDIUM_MAX_HARDNESS := 4.0


## Один удар. Не меняет отметки упорных блоков — для этого есть `strike_and_mark`.
static func strike(
	chunk: Variant,
	profile: Variant,
	tool: Variant,
	block: Vector3i,
	distance_m: float
) -> RefCounted:
	if tool == null:
		return ResultScript.refused(ResultScript.REASON_NO_TOOL)
	if chunk == null or profile == null:
		return ResultScript.refused(ResultScript.REASON_NO_INPUT)
	if not chunk.is_inside(block):
		return ResultScript.refused(ResultScript.REASON_OUTSIDE_CHUNK)
	var rock_id: String = profile.rock_id_at(distance_m)
	var hardness: float = profile.hardness_at(distance_m)
	if rock_id.is_empty():
		return ResultScript.refused(ResultScript.REASON_OUTSIDE_PROFILE)
	var state: int = chunk.state_of(block)
	if state == BlockStateScript.Kind.REMOVED:
		return ResultScript.refused(ResultScript.REASON_REMOVED, rock_id, hardness)
	if not tool.can_break(hardness):
		return ResultScript.refused(ResultScript.REASON_STUBBORN, rock_id, hardness, true)
	if not chunk.apply_damage(block, tool.damage_per_hit):
		return ResultScript.refused(ResultScript.REASON_GRID_REFUSED, rock_id, hardness)
	var new_state: int = chunk.state_of(block)
	var fraction := ""
	if new_state == BlockStateScript.Kind.REMOVED:
		fraction = fraction_for(hardness)
	return ResultScript.struck(new_state, chunk.damage_of(block), fraction, rock_id, hardness)


## Удар с отметкой упорного блока. Отметка нужна, чтобы игрок вернулся к участку с лучшим
## инструментом: сама порода при отказе не повреждается.
static func strike_and_mark(
	chunk: Variant,
	profile: Variant,
	tool: Variant,
	block: Vector3i,
	distance_m: float,
	marks: Variant,
	chunk_index: Vector3i = Vector3i.ZERO
) -> RefCounted:
	var result: RefCounted = strike(chunk, profile, tool, block, distance_m)
	if marks != null:
		if result.stubborn:
			marks.mark(chunk_index, block, result.rock_id, _zone_of(profile, distance_m))
		elif result.accepted and marks.has(chunk_index, block):
			marks.unmark(chunk_index, block)
	return result


## Фракция для разрушенного блока по твёрдости породы (D032).
static func fraction_for(hardness: float) -> String:
	if hardness <= FINE_MAX_HARDNESS:
		return FRACTION_FINE
	if hardness <= MEDIUM_MAX_HARDNESS:
		return FRACTION_MEDIUM
	return FRACTION_COARSE


static func _zone_of(profile: Variant, distance_m: float) -> int:
	return int(profile.zone_at(distance_m))
