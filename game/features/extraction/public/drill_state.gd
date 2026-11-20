class_name DrillState
extends RefCounted

## Отверстия одного блока: по каким граням просверлено.
##
## Дизайн-документ, раздел 15.2 и D029: чтобы вынуть блок целиком, игрок сверлит отверстия
## по горизонтали и по бокам, а затем отбивает блок. Отверстия — состояние блока, а не породы,
## поэтому живут вместе с сеткой чанка.

enum Face {
	TOP,
	BOTTOM,
	NORTH,
	SOUTH,
	EAST,
	WEST,
}

const FACE_NAMES := {
	Face.TOP: "top",
	Face.BOTTOM: "bottom",
	Face.NORTH: "north",
	Face.SOUTH: "south",
	Face.EAST: "east",
	Face.WEST: "west",
}

const SIDE_FACES := [Face.NORTH, Face.SOUTH, Face.EAST, Face.WEST]

var last_error: String = ""

var _mask: int = 0


static func is_valid_face(face: int) -> bool:
	return FACE_NAMES.has(face)


static func face_name(face: int) -> String:
	return str(FACE_NAMES.get(face, "unknown"))


func has_face(face: int) -> bool:
	if not is_valid_face(face):
		last_error = "unknown face %d" % face
		return false
	return (_mask & (1 << face)) != 0


## Ставит отверстие на грань. Повторное сверление той же грани отклоняется.
func drill(face: int) -> bool:
	if not is_valid_face(face):
		last_error = "unknown face %d" % face
		return false
	if has_face(face):
		last_error = "face %s is already drilled" % face_name(face)
		return false
	_mask |= 1 << face
	last_error = ""
	return true


func hole_count() -> int:
	var total := 0
	for face: int in FACE_NAMES.keys():
		if (_mask & (1 << face)) != 0:
			total += 1
	return total


## Блок освобождён: просверлены все боковые грани и хотя бы одна горизонтальная пара.
func is_liberated() -> bool:
	for face: int in SIDE_FACES:
		if not has_face(face):
			return false
	return has_face(Face.TOP) or has_face(Face.BOTTOM)


func serialize() -> Dictionary:
	return {"mask": _mask}


static func deserialize(data: Dictionary) -> DrillState:
	var mask := int(data.get("mask", 0))
	if mask < 0 or mask >= (1 << FACE_NAMES.size()):
		push_error("drill mask %d is outside the six faces" % mask)
		return null
	var state := DrillState.new()
	state._mask = mask
	return state


func _to_string() -> String:
	return "DrillState(mask=%d, holes=%d)" % [_mask, hole_count()]
