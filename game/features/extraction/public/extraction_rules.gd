class_name ExtractionRules
extends RefCounted

## Правила выемки блока: сверление граней, проверка освобождения и сама выемка.
##
## Размер вынутого блока — минимум из двух ограничений (D034):
## насколько крупный блок позволяет порода (по твёрдости) и насколько крупный может освободить бур.
## Поэтому мягкая порода даёт только малый блок даже мощным буром, а огромный блок — только
## в твёрдой породе и только сильным буром.

const BlockStateScript := preload("res://game/core/block_grid/public/block_state.gd")
const DrillStateScript := preload("res://game/features/extraction/public/drill_state.gd")
const ResultScript := preload("res://game/features/extraction/public/extraction_result.gd")

## Порог твёрдости, до которого порода держит только малый блок.
const SMALL_ROCK_MAX_HARDNESS := 2.0
## Порог твёрдости, до которого порода держит большой блок.
const LARGE_ROCK_MAX_HARDNESS := 4.0


## Наибольший размер блока, который держит порода такой твёрдости.
static func rock_cap(hardness: float) -> int:
	if hardness <= SMALL_ROCK_MAX_HARDNESS:
		return 1
	if hardness <= LARGE_ROCK_MAX_HARDNESS:
		return 2
	return 3


## Наибольший размер блока, который может освободить этот инструмент.
static func drill_cap(tool: Variant) -> int:
	if tool == null or not tool.can_drill:
		return 0
	return int(tool.drill_cap)


## Итоговый размер: минимум из возможностей породы и возможности бура; 0 — вынуть нельзя.
static func size_tier_for(hardness: float, tool: Variant) -> int:
	var by_rock := rock_cap(hardness)
	var by_drill := drill_cap(tool)
	if by_drill <= 0:
		return 0
	return mini(by_rock, by_drill)


## Сверление одной грани блока.
static func drill_face(
	chunk: Variant,
	profile: Variant,
	tool: Variant,
	drills: Variant,
	chunk_index: Vector3i,
	block: Vector3i,
	face: int,
	distance_m: float
) -> RefCounted:
	if tool == null:
		return ResultScript.refused(ResultScript.REASON_NO_TOOL)
	if chunk == null or profile == null or drills == null:
		return ResultScript.refused(ResultScript.REASON_NO_INPUT)
	if not chunk.is_inside(block):
		return ResultScript.refused(ResultScript.REASON_OUTSIDE_CHUNK)
	var rock_id: String = profile.rock_id_at(distance_m)
	var hardness: float = profile.hardness_at(distance_m)
	if rock_id.is_empty():
		return ResultScript.refused(ResultScript.REASON_OUTSIDE_PROFILE)
	if not tool.can_drill:
		return ResultScript.refused(ResultScript.REASON_NO_DRILL, rock_id, hardness)
	var state: int = chunk.state_of(block)
	if state == BlockStateScript.Kind.REMOVED:
		return ResultScript.refused(ResultScript.REASON_BLOCK_REMOVED, rock_id, hardness)
	if state == BlockStateScript.Kind.PARTIAL:
		return ResultScript.refused(ResultScript.REASON_BLOCK_DAMAGED, rock_id, hardness)
	if not drills.drill(chunk_index, block, face):
		return ResultScript.refused(ResultScript.REASON_ALREADY_DRILLED, rock_id, hardness)
	return ResultScript.drilled(face, rock_id, hardness)


## Выемка блока: только целый и освобождённый блок, только буром, который тянет этот размер.
static func extract_block(
	chunk: Variant,
	profile: Variant,
	tool: Variant,
	drills: Variant,
	chunk_index: Vector3i,
	block: Vector3i,
	distance_m: float
) -> RefCounted:
	if tool == null:
		return ResultScript.refused(ResultScript.REASON_NO_TOOL)
	if chunk == null or profile == null or drills == null:
		return ResultScript.refused(ResultScript.REASON_NO_INPUT)
	if not chunk.is_inside(block):
		return ResultScript.refused(ResultScript.REASON_OUTSIDE_CHUNK)
	var rock_id: String = profile.rock_id_at(distance_m)
	var hardness: float = profile.hardness_at(distance_m)
	if rock_id.is_empty():
		return ResultScript.refused(ResultScript.REASON_OUTSIDE_PROFILE)
	var state: int = chunk.state_of(block)
	if state == BlockStateScript.Kind.REMOVED:
		return ResultScript.refused(ResultScript.REASON_BLOCK_REMOVED, rock_id, hardness)
	if state == BlockStateScript.Kind.PARTIAL:
		return ResultScript.refused(ResultScript.REASON_BLOCK_DAMAGED, rock_id, hardness)
	if drill_cap(tool) <= 0:
		return ResultScript.refused(ResultScript.REASON_NO_DRILL, rock_id, hardness)
	if not drills.is_liberated(chunk_index, block):
		return ResultScript.refused(ResultScript.REASON_NOT_FREED, rock_id, hardness)
	var tier := size_tier_for(hardness, tool)
	if tier <= 0:
		return ResultScript.refused(ResultScript.REASON_NO_DRILL, rock_id, hardness)
	if not chunk.remove_block(block):
		return ResultScript.refused(ResultScript.REASON_BLOCK_REMOVED, rock_id, hardness)
	drills.clear(chunk_index, block)
	return ResultScript.extracted(ResultScript.size_id_for_tier(tier), tier, rock_id, hardness)
