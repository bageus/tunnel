extends SceneTree

## Тесты `core.block_grid` без сцены.
##
## Запуск: godot --headless --path . -s game/core/block_grid/tests/run_block_grid_tests.gd
## Проект должен быть импортирован (`godot --headless --path . --editor --quit`).

const ChunkScript := preload("res://game/core/block_grid/public/block_chunk.gd")
const StateScript := preload("res://game/core/block_grid/public/block_state.gd")
const PositionScript := preload("res://game/core/block_grid/public/block_position.gd")


func _init() -> void:
	var failures := 0
	failures += _test_layout()
	failures += _test_damage_rules()
	failures += _test_removal()
	failures += _test_serialization()
	failures += _test_world_coordinates()
	failures += _test_positions()
	print("block grid test: %d failure(s)" % failures)
	quit(1 if failures else 0)


func _test_layout() -> int:
	var chunk: RefCounted = ChunkScript.new()
	var failures := 0
	failures += _check(chunk.size == Vector3i(8, 8, 8), "default chunk is 8x8x8 blocks")
	failures += _check(chunk.block_count() == 512, "an 8x8x8 chunk holds 512 blocks")
	failures += _check(chunk.changed_block_count() == 0, "a fresh chunk stores no changes")
	failures += _check(chunk.state_of(Vector3i(0, 0, 0)) == StateScript.Kind.INTACT, "a fresh block is intact")
	failures += _check(chunk.damage_of(Vector3i(0, 0, 0)) == 0, "an intact block has zero damage")
	failures += _check(chunk.index_of(Vector3i(0, 0, 0)) == 0, "index of the first block is 0")
	failures += _check(chunk.index_of(Vector3i(7, 7, 7)) == 511, "index of the last block is 511")
	failures += _check(chunk.position_of(chunk.index_of(Vector3i(3, 5, 7))) == Vector3i(3, 5, 7),
			"index round-trips to a position")
	failures += _check(chunk.index_of(Vector3i(8, 0, 0)) == -1, "a block outside the chunk has no index")
	failures += _check(chunk.state_of(Vector3i(-1, 0, 0)) == -1, "a block outside the chunk has no state")
	failures += _check(chunk.damage_of(Vector3i(0, 8, 0)) == -1, "a block outside the chunk has no damage")
	return failures


func _test_damage_rules() -> int:
	var chunk: RefCounted = ChunkScript.new()
	var failures := 0
	failures += _check(chunk.apply_damage(Vector3i(1, 1, 1), 30), "a 30 % hit is accepted")
	failures += _check(chunk.state_of(Vector3i(1, 1, 1)) == StateScript.Kind.PARTIAL, "a hit block becomes partial")
	failures += _check(chunk.damage_of(Vector3i(1, 1, 1)) == 30, "partial damage is stored")
	failures += _check(chunk.apply_damage(Vector3i(1, 1, 1), 80), "a hit past 100 % is accepted")
	failures += _check(chunk.state_of(Vector3i(1, 1, 1)) == StateScript.Kind.REMOVED, "100 % damage removes the block")
	failures += _check(chunk.damage_of(Vector3i(1, 1, 1)) == 100, "a removed block reports 100 % damage")
	failures += _check(not chunk.apply_damage(Vector3i(1, 1, 1), 10), "a removed block takes no more damage")
	failures += _check(chunk.last_error != "", "a refused hit explains itself")
	failures += _check(not chunk.apply_damage(Vector3i(0, 0, 0), 0), "zero damage is refused")
	failures += _check(not chunk.apply_damage(Vector3i(0, 0, 0), 101), "damage above 100 is refused")
	failures += _check(not chunk.set_state(Vector3i(0, 0, 0), StateScript.Kind.PARTIAL, 0),
			"a partial block needs damage")
	failures += _check(not chunk.set_state(Vector3i(0, 0, 0), StateScript.Kind.PARTIAL, 100),
			"100 % must be removed, not partial")
	failures += _check(not chunk.set_state(Vector3i(0, 0, 0), 42, 10), "an unknown state is refused")
	return failures


func _test_removal() -> int:
	var chunk: RefCounted = ChunkScript.new()
	var failures := 0
	failures += _check(chunk.remove_block(Vector3i(2, 0, 0)), "a whole block can be removed at once")
	failures += _check(not chunk.set_state(Vector3i(2, 0, 0), StateScript.Kind.INTACT),
			"a removed block cannot be restored in place")
	failures += _check(chunk.apply_damage(Vector3i(3, 0, 0), 40), "another block is damaged")
	failures += _check(chunk.count_blocks(StateScript.Kind.INTACT) == 510, "intact count follows the changes")
	failures += _check(chunk.count_blocks(StateScript.Kind.PARTIAL) == 1, "one block stays partial")
	failures += _check(chunk.count_blocks(StateScript.Kind.REMOVED) == 1, "one block is removed")
	failures += _check(chunk.count_blocks(77) == -1, "an unknown state has no count")
	return failures


func _test_serialization() -> int:
	var chunk: RefCounted = ChunkScript.new()
	chunk.apply_damage(Vector3i(1, 1, 1), 55)
	chunk.remove_block(Vector3i(2, 0, 0))
	var failures := 0
	var data: Dictionary = chunk.serialize()
	failures += _check((data.get("changed") as Array).size() == 2, "serialization keeps only changed blocks")
	failures += _check(data.get("size") == [8, 8, 8], "serialization keeps the chunk size")
	var restored: RefCounted = ChunkScript.deserialize(data)
	failures += _check(restored != null, "serialized state is restored")
	if restored != null:
		failures += _check(restored.state_of(Vector3i(1, 1, 1)) == StateScript.Kind.PARTIAL,
				"a partial block survives a round-trip")
		failures += _check(restored.damage_of(Vector3i(1, 1, 1)) == 55, "damage survives a round-trip")
		failures += _check(restored.state_of(Vector3i(2, 0, 0)) == StateScript.Kind.REMOVED,
				"a removed block survives a round-trip")
		failures += _check(restored.serialize().get("changed") == data.get("changed"),
				"serialization round-trip is lossless")
	failures += _check(ChunkScript.deserialize({"chunk": [0, 0, 0], "size": [8, 8, 8], "changed": [[999, 2, 100]]}) == null,
			"an entry outside the chunk is refused")
	failures += _check(ChunkScript.deserialize({"size": [8, 8, 8], "changed": []}) == null,
			"data without a chunk index is refused")
	return failures


func _test_world_coordinates() -> int:
	var chunk: RefCounted = ChunkScript.new(Vector3i(1, 0, 0), Vector3i(8, 8, 8), 1.0)
	var failures := 0
	failures += _check(chunk.block_world_origin(Vector3i(1, 2, 3)) == Vector3(9, 2, 3),
			"a block maps to world meters")
	failures += _check(chunk.world_to_block(Vector3(9.5, 2.5, 3.5)) == Vector3i(1, 2, 3),
			"a world point maps back to its block")
	failures += _check(chunk.contains_world(Vector3(15.9, 0.1, 0.1)), "the chunk owns its world volume")
	failures += _check(not chunk.contains_world(Vector3(16.1, 0.1, 0.1)), "the next chunk does not belong here")
	failures += _check(chunk.block_world_origin(Vector3i(8, 0, 0)) == Vector3.INF,
			"a block outside the chunk has no world origin")
	return failures


func _test_positions() -> int:
	var position: RefCounted = PositionScript.from_array([1, 2, 3, 4, 5, 6])
	var failures := 0
	failures += _check(position != null and position.chunk == Vector3i(1, 2, 3), "a position restores its chunk")
	failures += _check(position != null and position.block == Vector3i(4, 5, 6), "a position restores its block")
	failures += _check(position.to_array() == [1, 2, 3, 4, 5, 6], "a position round-trips through an array")
	failures += _check(PositionScript.from_array([1, 2]) == null, "a short position array is refused")
	return failures


func _check(ok: bool, name: String) -> int:
	if not ok:
		push_error("FAIL: " + name)
	return 0 if ok else 1
