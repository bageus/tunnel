class_name BlockState
extends RefCounted

## Состояние блока породы в сетке чанка.
##
## `INTACT` — блок целый, в сетке нет записи; `PARTIAL` — блок повреждён и хранит
## степень повреждения 1–99 %; `REMOVED` — блок вынут или разрушен полностью.

enum Kind {
	INTACT,
	PARTIAL,
	REMOVED,
}

const NAMES := {
	Kind.INTACT: "intact",
	Kind.PARTIAL: "partial",
	Kind.REMOVED: "removed",
}


static func is_valid(value: int) -> bool:
	return NAMES.has(value)


static func name_of(value: int) -> String:
	return NAMES.get(value, "unknown")


## Разрешены только переходы «вперёд»: целый → повреждённый → вынутый.
## Обратный переход и правка вынутого блока запрещены.
static func transition_allowed(from_state: int, to_state: int) -> bool:
	if not is_valid(from_state) or not is_valid(to_state):
		return false
	match from_state:
		Kind.INTACT:
			return to_state == Kind.PARTIAL or to_state == Kind.REMOVED
		Kind.PARTIAL:
			return to_state == Kind.PARTIAL or to_state == Kind.REMOVED
		_:
			return false
