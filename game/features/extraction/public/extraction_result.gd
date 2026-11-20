class_name ExtractionResult
extends RefCounted

## Итог сверления или выемки блока.
##
## `reason` — машинный код, `size_id` — материал, который получил игрок (`block_small`,
## `block_large`, `block_huge`), `size_tier` — 1/2/3 для правил и UI.

const REASON_OK := "ok"
const REASON_NOT_FREED := "not_freed"
const REASON_NO_DRILL := "no_drill"
const REASON_OUTSIDE_CHUNK := "outside_chunk"
const REASON_OUTSIDE_PROFILE := "outside_profile"
const REASON_BLOCK_DAMAGED := "block_damaged"
const REASON_BLOCK_REMOVED := "block_removed"
const REASON_NO_TOOL := "no_tool"
const REASON_NO_INPUT := "no_input"
const REASON_ALREADY_DRILLED := "already_drilled"

const SIZE_SMALL := "block_small"
const SIZE_LARGE := "block_large"
const SIZE_HUGE := "block_huge"

var accepted: bool = false
var reason: String = REASON_NO_INPUT
var size_id: String = ""
var size_tier: int = 0
var face: int = -1
var rock_id: String = ""
var hardness: float = -1.0


func describe() -> String:
	if not accepted:
		return "refused(%s) rock=%s hardness=%.1f" % [reason, rock_id, hardness]
	if size_tier > 0:
		return "extracted %s tier=%d rock=%s hardness=%.1f" % [size_id, size_tier, rock_id, hardness]
	return "drilled face=%d rock=%s hardness=%.1f" % [face, rock_id, hardness]


static func refused(reason_code: String, rock_id: String = "", rock_hardness: float = -1.0) -> ExtractionResult:
	var result := ExtractionResult.new()
	result.accepted = false
	result.reason = reason_code
	result.rock_id = rock_id
	result.hardness = rock_hardness
	return result


static func drilled(face_index: int, rock_id: String, rock_hardness: float) -> ExtractionResult:
	var result := ExtractionResult.new()
	result.accepted = true
	result.reason = REASON_OK
	result.face = face_index
	result.rock_id = rock_id
	result.hardness = rock_hardness
	return result


static func extracted(size: String, tier: int, rock_id: String, rock_hardness: float) -> ExtractionResult:
	var result := ExtractionResult.new()
	result.accepted = true
	result.reason = REASON_OK
	result.size_id = size
	result.size_tier = tier
	result.rock_id = rock_id
	result.hardness = rock_hardness
	return result


static func size_id_for_tier(tier: int) -> String:
	match tier:
		1:
			return SIZE_SMALL
		2:
			return SIZE_LARGE
		3:
			return SIZE_HUGE
		_:
			return ""
