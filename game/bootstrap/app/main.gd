extends Node2D

## Application composition root of `bootstrap.app`.
##
## Держите здесь только сборку верхнего уровня: загрузку уровней, переходы
## между экранами и связывание модулей. Игровые правила живут в
## `game/features/`, их владельцы состояния описаны в `module.json`.


func _ready() -> void:
	print("tunnel: main scene ready")
