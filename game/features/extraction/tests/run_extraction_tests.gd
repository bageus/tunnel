extends SceneTree

## Тесты `features.block_extraction` без сцены.
##
## Запуск: godot --headless --path . -s game/features/extraction/tests/run_extraction_tests.gd
## Проект должен быть импортирован (`godot --headless --path . --editor --quit`).

const ChunkScript := preload("res://game/core/block_grid/public/block_chunk.gd")
const StateScript := preload("res://game/core/block_grid/public/block_state.gd")
const RegistryScript := preload("res://game/features/rock_profile/public/rock_registry.gd")
const ProfileScript := preload("res://game/features/rock_profile/public/hardness_profile.gd")
const ToolScript := preload("res://game/features/excavation/public/tool_definition.gd")
const DrillStateScript := preload("res://game/features/extraction/public/drill_state.gd")
const DrillsScript := preload("res://game/features/extraction/public/drill_registry.gd")
const RulesScript := preload("res://game/features/extraction/public/extraction_rules.gd")
const ResultScript := preload("res://game/features/extraction/public/extraction_result.gd")

const ZONE_I_M := 0.0
const ZONE_III_M := 2500.0
const ZONE_V_M := 5000.0


func _init() -> void:
	var failures := 0
	failures += _test_drilling()
	failures += _test_liberation()
	failures += _test_size_rule()
	failures += _test_extraction_flow()
	failures += _test_refusals()
	failures += _test_serialization()
	print("extraction test: %d failure(s)" % failures)
	quit(1 if failures else 0)


func _fixture() -> Dictionary:
	var registry: RefCounted = RegistryScript.default_registry()
	return {
		"chunk": ChunkScript.new(),
		"profile": ProfileScript.new(registry, 10000.0),
		"drills": DrillsScript.new(),
	}


func _drill_side_faces(drills: RefCounted, block: Vector3i) -> void:
	for face: int in DrillStateScript.SIDE_FACES:
		drills.drill(Vector3i.ZERO, block, face)


func _test_drilling() -> int:
	var f := _fixture()
	var chunk: RefCounted = f["chunk"]
	var profile: RefCounted = f["profile"]
	var drills: RefCounted = f["drills"]
	var drill: RefCounted = ToolScript.by_id("hand_drill")
	var chisel: RefCounted = ToolScript.by_id("chisel")
	var failures := 0
	var block := Vector3i(0, 0, 0)
	var first: RefCounted = RulesScript.drill_face(chunk, profile, drill, drills,
			Vector3i.ZERO, block, DrillStateScript.Face.NORTH, ZONE_V_M)
	failures += _check(first.accepted, "a drill makes a hole")
	failures += _check(drills.has_holes(Vector3i.ZERO, block), "the hole is remembered")
	var again: RefCounted = RulesScript.drill_face(chunk, profile, drill, drills,
			Vector3i.ZERO, block, DrillStateScript.Face.NORTH, ZONE_V_M)
	failures += _check(again.reason == ResultScript.REASON_ALREADY_DRILLED, "the same face is not drilled twice")
	var no_drill: RefCounted = RulesScript.drill_face(chunk, profile, chisel, drills,
			Vector3i.ZERO, block, DrillStateScript.Face.SOUTH, ZONE_V_M)
	failures += _check(no_drill.reason == ResultScript.REASON_NO_DRILL, "a chisel cannot drill")
	return failures


func _test_liberation() -> int:
	var drills: RefCounted = DrillsScript.new()
	var block := Vector3i(1, 0, 0)
	var failures := 0
	_drill_side_faces(drills, block)
	failures += _check(not drills.is_liberated(Vector3i.ZERO, block),
			"four side holes alone do not free the block")
	failures += _check(drills.drill(Vector3i.ZERO, block, DrillStateScript.Face.TOP),
			"a top hole is accepted")
	failures += _check(drills.is_liberated(Vector3i.ZERO, block), "side holes plus a top hole free the block")
	var state: RefCounted = drills.state_of(Vector3i.ZERO, block)
	failures += _check(state.hole_count() == 5, "five faces are drilled")
	failures += _check(not drills.is_liberated(Vector3i.ZERO, Vector3i(9, 9, 9)),
			"an untouched block is not free")
	return failures


func _test_size_rule() -> int:
	var drill: RefCounted = ToolScript.by_id("hand_drill")
	var jackhammer: RefCounted = ToolScript.by_id("jackhammer")
	var perforator: RefCounted = ToolScript.by_id("perforator")
	var chisel: RefCounted = ToolScript.by_id("chisel")
	var failures := 0
	failures += _check(RulesScript.size_tier_for(1.0, drill) == 1, "soft rock caps the block at small")
	failures += _check(RulesScript.size_tier_for(3.0, perforator) == 1, "a weak drill keeps zone III small")
	failures += _check(RulesScript.size_tier_for(3.0, jackhammer) == 2, "a stronger drill frees a large block")
	failures += _check(RulesScript.size_tier_for(3.0, drill) == 2, "rock still caps zone III at large")
	failures += _check(RulesScript.size_tier_for(5.0, drill) == 3, "hard rock and a strong drill give a huge block")
	failures += _check(RulesScript.size_tier_for(5.0, jackhammer) == 2, "a weaker drill caps the ore zone at large")
	failures += _check(RulesScript.size_tier_for(5.0, chisel) == 0, "a chisel cannot extract at all")
	failures += _check(RulesScript.rock_cap(1.0) == 1 and RulesScript.rock_cap(5.0) == 3,
			"rock cap grows with hardness")
	return failures


func _test_extraction_flow() -> int:
	var f := _fixture()
	var chunk: RefCounted = f["chunk"]
	var profile: RefCounted = f["profile"]
	var drills: RefCounted = f["drills"]
	var drill: RefCounted = ToolScript.by_id("hand_drill")
	var block := Vector3i(2, 0, 0)
	var failures := 0
	var early: RefCounted = RulesScript.extract_block(chunk, profile, drill, drills,
			Vector3i.ZERO, block, ZONE_V_M)
	failures += _check(early.reason == ResultScript.REASON_NOT_FREED, "an undrilled block is not extracted")
	_drill_side_faces(drills, block)
	drills.drill(Vector3i.ZERO, block, DrillStateScript.Face.BOTTOM)
	var result: RefCounted = RulesScript.extract_block(chunk, profile, drill, drills,
			Vector3i.ZERO, block, ZONE_V_M)
	failures += _check(result.accepted, "a freed block is extracted")
	failures += _check(result.size_id == ResultScript.SIZE_HUGE and result.size_tier == 3,
			"the ore zone with a strong drill gives a huge block")
	failures += _check(chunk.state_of(block) == StateScript.Kind.REMOVED, "the block leaves the grid")
	failures += _check(not drills.is_liberated(Vector3i.ZERO, block), "drilling state is cleared after extraction")
	return failures


func _test_refusals() -> int:
	var f := _fixture()
	var chunk: RefCounted = f["chunk"]
	var profile: RefCounted = f["profile"]
	var drills: RefCounted = f["drills"]
	var drill: RefCounted = ToolScript.by_id("hand_drill")
	var block := Vector3i(3, 0, 0)
	var failures := 0
	var outside: RefCounted = RulesScript.extract_block(chunk, profile, drill, drills,
			Vector3i.ZERO, Vector3i(99, 0, 0), ZONE_V_M)
	failures += _check(outside.reason == ResultScript.REASON_OUTSIDE_CHUNK, "a block outside the chunk is refused")
	chunk.remove_block(block)
	var removed: RefCounted = RulesScript.extract_block(chunk, profile, drill, drills,
			Vector3i.ZERO, block, ZONE_V_M)
	failures += _check(removed.reason == ResultScript.REASON_BLOCK_REMOVED, "a removed block is refused")
	var damaged_block := Vector3i(4, 0, 0)
	chunk.apply_damage(damaged_block, 30)
	var damaged: RefCounted = RulesScript.extract_block(chunk, profile, drill, drills,
			Vector3i.ZERO, damaged_block, ZONE_V_M)
	failures += _check(damaged.reason == ResultScript.REASON_BLOCK_DAMAGED, "a damaged block cannot be pulled out whole")
	var drilled_damaged: RefCounted = RulesScript.drill_face(chunk, profile, drill, drills,
			Vector3i.ZERO, damaged_block, DrillStateScript.Face.TOP, ZONE_V_M)
	failures += _check(drilled_damaged.reason == ResultScript.REASON_BLOCK_DAMAGED, "a damaged block cannot be drilled")
	var no_tool: RefCounted = RulesScript.extract_block(chunk, profile, null, drills,
			Vector3i.ZERO, Vector3i(5, 0, 0), ZONE_V_M)
	failures += _check(no_tool.reason == ResultScript.REASON_NO_TOOL, "a missing tool is refused")
	return failures


func _test_serialization() -> int:
	var drills: RefCounted = DrillsScript.new()
	var failures := 0
	var block := Vector3i(1, 1, 1)
	_drill_side_faces(drills, block)
	drills.drill(Vector3i.ZERO, block, DrillStateScript.Face.TOP)
	var data: Dictionary = drills.serialize()
	failures += _check((data.get("blocks") as Array).size() == 1, "serialization keeps drilled blocks")
	var restored: RefCounted = DrillsScript.deserialize(data)
	failures += _check(restored != null and restored.is_liberated(Vector3i.ZERO, block),
			"a restored block keeps its liberation")
	failures += _check(restored != null and restored.drilled_blocks() == 1, "drilled count survives")
	var bad: RefCounted = DrillStateScript.deserialize({"mask": 999})
	failures += _check(bad == null, "an impossible drill mask is refused")
	failures += _check(DrillsScript.deserialize({"blocks": [[0, 0, 0, 1, 1, 1]]}) == null,
			"a short drill row is refused")
	return failures


func _check(ok: bool, name: String) -> int:
	if not ok:
		push_error("FAIL: " + name)
	return 0 if ok else 1
