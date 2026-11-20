extends SceneTree

## Тесты `features.excavation` без сцены.
##
## Запуск: godot --headless --path . -s game/features/excavation/tests/run_excavation_tests.gd
## Проект должен быть импортирован (`godot --headless --path . --editor --quit`).

const ChunkScript := preload("res://game/core/block_grid/public/block_chunk.gd")
const StateScript := preload("res://game/core/block_grid/public/block_state.gd")
const RegistryScript := preload("res://game/features/rock_profile/public/rock_registry.gd")
const ProfileScript := preload("res://game/features/rock_profile/public/hardness_profile.gd")
const ToolScript := preload("res://game/features/excavation/public/tool_definition.gd")
const RulesScript := preload("res://game/features/excavation/public/excavation_rules.gd")
const MarksScript := preload("res://game/features/excavation/public/stubborn_registry.gd")
const ResultScript := preload("res://game/features/excavation/public/excavation_result.gd")


func _init() -> void:
	var failures := 0
	failures += _test_accepted_strike()
	failures += _test_stubborn_refusal()
	failures += _test_power_thresholds()
	failures += _test_fractions()
	failures += _test_return_with_better_tool()
	failures += _test_refusals()
	failures += _test_marks_serialization()
	print("excavation test: %d failure(s)" % failures)
	quit(1 if failures else 0)


func _fixture() -> Dictionary:
	var registry: RefCounted = RegistryScript.default_registry()
	return {
		"chunk": ChunkScript.new(),
		"profile": ProfileScript.new(registry, 10000.0),
		"marks": MarksScript.new(),
	}


func _test_accepted_strike() -> int:
	var f := _fixture()
	var chunk: RefCounted = f["chunk"]
	var profile: RefCounted = f["profile"]
	var chisel: RefCounted = ToolScript.by_id("chisel")
	var failures := 0
	var first: RefCounted = RulesScript.strike(chunk, profile, chisel, Vector3i(0, 0, 0), 0.0)
	failures += _check(first.accepted, "a chisel breaks soft rock")
	failures += _check(first.new_state == StateScript.Kind.PARTIAL, "one hit leaves the block partial")
	failures += _check(first.damage == 20, "one chisel hit adds 20 % damage")
	failures += _check(first.fraction.is_empty(), "a partial block yields no fraction yet")
	failures += _check(first.rock_id == "loam" and first.hardness == 1.0,
			"the strike reports the rock and hardness of the point")
	var last: RefCounted = first
	for hit: int in range(4):
		last = RulesScript.strike(chunk, profile, chisel, Vector3i(0, 0, 0), 0.0)
	failures += _check(last.accepted, "repeated hits are accepted")
	failures += _check(last.new_state == StateScript.Kind.REMOVED, "five chisel hits break the block")
	failures += _check(last.fraction == RulesScript.FRACTION_FINE, "soft rock yields a fine fraction")
	failures += _check(chunk.state_of(Vector3i(0, 0, 0)) == StateScript.Kind.REMOVED,
			"the chunk records the removed block")
	return failures


func _test_stubborn_refusal() -> int:
	var f := _fixture()
	var chunk: RefCounted = f["chunk"]
	var profile: RefCounted = f["profile"]
	var chisel: RefCounted = ToolScript.by_id("chisel")
	var failures := 0
	var result: RefCounted = RulesScript.strike(chunk, profile, chisel, Vector3i(1, 0, 0), 5000.0)
	failures += _check(not result.accepted, "a chisel cannot break the ore zone")
	failures += _check(result.stubborn, "the refusal is marked as stubborn rock")
	failures += _check(result.reason == ResultScript.REASON_STUBBORN, "the refusal has a stubborn reason")
	failures += _check(chunk.state_of(Vector3i(1, 0, 0)) == StateScript.Kind.INTACT,
			"a refused hit does not damage the block")
	failures += _check(chunk.damage_of(Vector3i(1, 0, 0)) == 0, "a refused hit spends nothing")
	failures += _check(result.hardness == 5.0, "the refusal reports the hardness that stopped the tool")
	return failures


func _test_power_thresholds() -> int:
	var f := _fixture()
	var chunk: RefCounted = f["chunk"]
	var profile: RefCounted = f["profile"]
	var pickaxe: RefCounted = ToolScript.by_id("pickaxe")
	var perforator: RefCounted = ToolScript.by_id("perforator")
	var failures := 0
	var weak: RefCounted = RulesScript.strike(chunk, profile, pickaxe, Vector3i(2, 0, 0), 2500.0)
	failures += _check(not weak.accepted and weak.stubborn, "a pickaxe stops at zone III")
	var strong: RefCounted = RulesScript.strike(chunk, profile, perforator, Vector3i(2, 0, 0), 2500.0)
	failures += _check(strong.accepted, "a perforator takes zone III")
	failures += _check(strong.damage == 45, "a perforator adds 45 % damage")
	failures += _check(perforator.can_break(3.0) and not pickaxe.can_break(3.0),
			"power is compared with hardness directly")
	return failures


func _test_fractions() -> int:
	var f := _fixture()
	var chunk: RefCounted = f["chunk"]
	var profile: RefCounted = f["profile"]
	var perforator: RefCounted = ToolScript.by_id("perforator")
	var drill: RefCounted = ToolScript.by_id("hand_drill")
	var failures := 0
	var medium: RefCounted = null
	for hit: int in range(3):
		medium = RulesScript.strike(chunk, profile, perforator, Vector3i(3, 0, 0), 2500.0)
	failures += _check(medium != null and medium.fraction == RulesScript.FRACTION_MEDIUM,
			"zone III rock yields a medium fraction")
	var coarse: RefCounted = null
	for hit: int in range(2):
		coarse = RulesScript.strike(chunk, profile, drill, Vector3i(3, 1, 0), 5000.0)
	failures += _check(coarse != null and coarse.fraction == RulesScript.FRACTION_COARSE,
			"the ore zone yields a coarse fraction")
	failures += _check(RulesScript.fraction_for(1.0) == RulesScript.FRACTION_FINE
			and RulesScript.fraction_for(2.0) == RulesScript.FRACTION_FINE,
			"soft rock always yields a fine fraction")
	failures += _check(RulesScript.fraction_for(5.0) == RulesScript.FRACTION_COARSE,
			"the hardest rock yields a coarse fraction")
	return failures


func _test_return_with_better_tool() -> int:
	var f := _fixture()
	var chunk: RefCounted = f["chunk"]
	var profile: RefCounted = f["profile"]
	var marks: RefCounted = f["marks"]
	var chisel: RefCounted = ToolScript.by_id("chisel")
	var drill: RefCounted = ToolScript.by_id("hand_drill")
	var failures := 0
	var block := Vector3i(4, 0, 0)
	var refused: RefCounted = RulesScript.strike_and_mark(chunk, profile, chisel, block, 5000.0, marks)
	failures += _check(refused.stubborn, "the weak tool is refused")
	failures += _check(marks.has(Vector3i.ZERO, block), "the block is marked for a later return")
	failures += _check(int(marks.get_mark(Vector3i.ZERO, block).get("zone", 0)) == 5,
			"the mark records the zone")
	var last: RefCounted = null
	for hit: int in range(2):
		last = RulesScript.strike_and_mark(chunk, profile, drill, block, 5000.0, marks)
	failures += _check(last != null and last.accepted, "the better tool breaks the marked block")
	failures += _check(last != null and last.fraction == RulesScript.FRACTION_COARSE,
			"the marked block yields a coarse fraction")
	failures += _check(not marks.has(Vector3i.ZERO, block), "the mark clears once the block is broken")
	return failures


func _test_refusals() -> int:
	var f := _fixture()
	var chunk: RefCounted = f["chunk"]
	var profile: RefCounted = f["profile"]
	var chisel: RefCounted = ToolScript.by_id("chisel")
	var failures := 0
	var outside: RefCounted = RulesScript.strike(chunk, profile, chisel, Vector3i(99, 0, 0), 0.0)
	failures += _check(outside.reason == ResultScript.REASON_OUTSIDE_CHUNK, "a block outside the chunk is refused")
	var no_tool: RefCounted = RulesScript.strike(chunk, profile, null, Vector3i(0, 0, 0), 0.0)
	failures += _check(no_tool.reason == ResultScript.REASON_NO_TOOL, "a missing tool is refused")
	var no_chunk: RefCounted = RulesScript.strike(null, profile, chisel, Vector3i(0, 0, 0), 0.0)
	failures += _check(no_chunk.reason == ResultScript.REASON_NO_INPUT, "a missing chunk is refused")
	var far: RefCounted = RulesScript.strike(chunk, profile, chisel, Vector3i(0, 0, 0), -5.0)
	failures += _check(far.reason == ResultScript.REASON_OUTSIDE_PROFILE, "a point outside the route is refused")
	chunk.remove_block(Vector3i(5, 0, 0))
	var removed: RefCounted = RulesScript.strike(chunk, profile, chisel, Vector3i(5, 0, 0), 0.0)
	failures += _check(removed.reason == ResultScript.REASON_REMOVED, "a removed block is refused")
	failures += _check(removed.describe().contains("refused"), "a refusal describes itself")
	return failures


func _test_marks_serialization() -> int:
	var marks: RefCounted = MarksScript.new()
	var failures := 0
	failures += _check(marks.mark(Vector3i.ZERO, Vector3i(1, 0, 0), "ore_veins", 5), "a mark is accepted")
	failures += _check(marks.mark(Vector3i(2, 0, 1), Vector3i(3, 4, 5), "quartzite", 4), "a second mark is accepted")
	failures += _check(not marks.mark(Vector3i.ZERO, Vector3i(0, 0, 0), "", 5), "a mark without a rock is refused")
	failures += _check(not marks.mark(Vector3i.ZERO, Vector3i(0, 0, 0), "loam", 9), "a mark with a bad zone is refused")
	var data: Dictionary = marks.serialize()
	failures += _check((data.get("marks") as Array).size() == 2, "serialization keeps every mark")
	var restored: RefCounted = MarksScript.deserialize(data)
	failures += _check(restored != null and restored.count() == 2, "marks are restored")
	failures += _check(restored != null and restored.has(Vector3i(2, 0, 1), Vector3i(3, 4, 5)),
			"a restored mark is found by its address")
	failures += _check(restored != null and restored.unmark(Vector3i.ZERO, Vector3i(1, 0, 0)),
			"a mark can be removed")
	failures += _check(restored != null and restored.count() == 1, "removing a mark shrinks the registry")
	failures += _check(MarksScript.deserialize({"marks": [[0, 0, 0, 1, 1, 1]]}) == null,
			"a short mark row is refused")
	return failures


func _check(ok: bool, name: String) -> int:
	if not ok:
		push_error("FAIL: " + name)
	return 0 if ok else 1
