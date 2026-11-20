class_name BlockPosition
extends RefCounted

## Адрес блока: индекс чанка в сетке мира плюс локальный индекс блока в чанке.
##
## Значение неизменяемое по смыслу: проходка создаёт новый адрес, а не правит старый.
## Долговременная идентичность блока — этот адрес плюс сид мира, не NodePath и не RID.

var chunk: Vector3i
var block: Vector3i


func _init(chunk_index: Vector3i = Vector3i.ZERO, block_index: Vector3i = Vector3i.ZERO) -> void:
	chunk = chunk_index
	block = block_index


func equals(other: BlockPosition) -> bool:
	return other != null and other.chunk == chunk and other.block == block


func to_array() -> Array[int]:
	return [chunk.x, chunk.y, chunk.z, block.x, block.y, block.z]


static func from_array(values: Array) -> BlockPosition:
	if values.size() != 6:
		return null
	for value: Variant in values:
		if typeof(value) != TYPE_INT and typeof(value) != TYPE_FLOAT:
			return null
	return BlockPosition.new(
		Vector3i(int(values[0]), int(values[1]), int(values[2])),
		Vector3i(int(values[3]), int(values[4]), int(values[5]))
	)


func _to_string() -> String:
	return "BlockPosition(chunk=%s, block=%s)" % [chunk, block]
