class_name ExcavationResult
extends RefCounted

## Итог одного удара: принят он или нет, почему, и что стало с блоком.
##
## `reason` — машинный код для правил и тестов, `describe()` — короткая строка для отладки.
## Результат неизменяемый по смыслу: новый удар создаёт новый результат.

const REASON_OK := "ok"
const REASON_STUBBORN := "stubborn"
const REASON_REMOVED := "removed"
const REASON_OUTSIDE_CHUNK := "outside_chunk"
const REASON_OUTSIDE_PROFILE := "outside_profile"
const REASON_NO_TOOL := "no_tool"
const REASON_NO_INPUT := "no_input"
const REASON_GRID_REFUSED := "grid_refused"

var accepted: bool = false
var reason: String = REASON_NO_INPUT
var new_state: int = -1
var damage: int = -1
var fraction: String = ""
var stubborn: bool = false
var rock_id: String = ""
var hardness: float = -1.0


func describe() -> String:
	if not accepted:
		return "refused(%s) rock=%s hardness=%.1f" % [reason, rock_id, hardness]
	if fraction.is_empty():
		return "hit rock=%s hardness=%.1f state=%d damage=%d" % [rock_id, hardness, new_state, damage]
	return "broke rock=%s hardness=%.1f fraction=%s" % [rock_id, hardness, fraction]


static func refused(
	refusal: String,
	rock_id: String = "",
	rock_hardness: float = -1.0,
	is_stubborn: bool = false
) -> ExcavationResult:
	var result := ExcavationResult.new()
	result.accepted = false
	result.reason = refusal
	result.rock_id = rock_id
	result.hardness = rock_hardness
	result.stubborn = is_stubborn
	return result


static func struck(
	block_state: int,
	block_damage: int,
	yield_fraction: String,
	rock_id: String,
	rock_hardness: float
) -> ExcavationResult:
	var result := ExcavationResult.new()
	result.accepted = true
	result.reason = REASON_OK
	result.new_state = block_state
	result.damage = block_damage
	result.fraction = yield_fraction
	result.rock_id = rock_id
	result.hardness = rock_hardness
	return result
