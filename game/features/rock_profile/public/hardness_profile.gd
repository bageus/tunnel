class_name HardnessProfile
extends RefCounted

## Профиль твёрдости по длине тоннеля.
##
## Глубина растёт к середине горы, поэтому зоны зеркалятся по длине (D033): у входа и у выхода
## зона I, в центре — рудная зона V. Внутри зоны её породы идут по очереди равными отрезками,
## поэтому каждая из 20 пород встречается на маршруте.
##
## Профиль — данные: сегменты строятся из реестра, а не ветвлениями в коде, чтобы правки баланса
## не трогали логику.

const DEFAULT_LENGTH_M := 10000.0

## Границы зон по длине тоннеля в метрах при длине 10 000 м.
const ZONE_SPANS := [
	{"zone": 1, "start_m": 0.0, "end_m": 500.0},
	{"zone": 2, "start_m": 500.0, "end_m": 1500.0},
	{"zone": 3, "start_m": 1500.0, "end_m": 3000.0},
	{"zone": 4, "start_m": 3000.0, "end_m": 4500.0},
	{"zone": 5, "start_m": 4500.0, "end_m": 5500.0},
	{"zone": 4, "start_m": 5500.0, "end_m": 7000.0},
	{"zone": 3, "start_m": 7000.0, "end_m": 8500.0},
	{"zone": 2, "start_m": 8500.0, "end_m": 9500.0},
	{"zone": 1, "start_m": 9500.0, "end_m": 10000.0},
]


## Один отрезок маршрута: от начала до конца одна порода.
class Segment extends RefCounted:
	var start_m: float
	var end_m: float
	var rock_id: String
	var zone: int
	var hardness: float

	func _init(
		segment_start: float = 0.0,
		segment_end: float = 0.0,
		segment_rock: String = "",
		segment_zone: int = 0,
		segment_hardness: float = 0.0
	) -> void:
		start_m = segment_start
		end_m = segment_end
		rock_id = segment_rock
		zone = segment_zone
		hardness = segment_hardness

	func width() -> float:
		return end_m - start_m

	func contains(distance_m: float) -> bool:
		return distance_m >= start_m and distance_m < end_m


var length_m: float = DEFAULT_LENGTH_M
var last_error: String = ""

var _segments: Array = []


func _init(registry: Variant = null, tunnel_length_m: float = DEFAULT_LENGTH_M) -> void:
	length_m = tunnel_length_m
	if registry != null:
		build(registry, tunnel_length_m)


## Строит профиль из реестра пород. Возвращает false и заполняет `last_error`,
## если в зоне нет пород или длина некорректна.
func build(registry: Variant, tunnel_length_m: float = DEFAULT_LENGTH_M) -> bool:
	_segments.clear()
	if tunnel_length_m <= 0.0:
		last_error = "tunnel length must be positive"
		return false
	length_m = tunnel_length_m
	var scale: float = tunnel_length_m / DEFAULT_LENGTH_M
	for span: Dictionary in ZONE_SPANS:
		var zone: int = int(span["zone"])
		var start: float = float(span["start_m"]) * scale
		var end: float = float(span["end_m"]) * scale
		var rocks: Array = registry.in_zone(zone)
		if rocks.is_empty():
			last_error = "zone %d has no rocks" % zone
			return false
		var step: float = (end - start) / rocks.size()
		for index: int in rocks.size():
			var rock: RefCounted = rocks[index]
			var segment_start: float = start + step * index
			_segments.append(Segment.new(segment_start, segment_start + step, rock.id, zone, rock.hardness))
	last_error = ""
	return true


func segment_count() -> int:
	return _segments.size()


func segments() -> Array:
	return _segments.duplicate()


func segment_at(distance_m: float) -> RefCounted:
	if distance_m < 0.0 or distance_m > length_m:
		last_error = "distance %.1f m is outside 0..%.1f m" % [distance_m, length_m]
		return null
	# Границы отрезков полуоткрыты, кроме самого конца маршрута.
	if is_equal_approx(distance_m, length_m):
		return _segments.back()
	for segment: Segment in _segments:
		if segment.contains(distance_m):
			return segment
	last_error = "distance %.1f m is not covered by the profile" % distance_m
	return null


func zone_at(distance_m: float) -> int:
	var segment: RefCounted = segment_at(distance_m)
	return -1 if segment == null else int(segment.zone)


func rock_id_at(distance_m: float) -> String:
	var segment: RefCounted = segment_at(distance_m)
	return "" if segment == null else str(segment.rock_id)


func hardness_at(distance_m: float) -> float:
	var segment: RefCounted = segment_at(distance_m)
	return -1.0 if segment == null else float(segment.hardness)


## Покрытие без дыр и перекрытий: от 0 до длины маршрута.
func covers_range() -> bool:
	if _segments.is_empty():
		last_error = "the profile has no segments"
		return false
	var first: Segment = _segments[0]
	if not is_zero_approx(first.start_m):
		last_error = "the profile does not start at 0 m"
		return false
	var previous_end: float = first.end_m
	if previous_end <= first.start_m:
		last_error = "segment width must be positive"
		return false
	for index: int in range(1, _segments.size()):
		var segment: Segment = _segments[index]
		if not is_equal_approx(segment.start_m, previous_end):
			last_error = "a gap or overlap before %.1f m" % segment.start_m
			return false
		if segment.end_m <= segment.start_m:
			last_error = "segment width must be positive at %.1f m" % segment.start_m
			return false
		previous_end = segment.end_m
	if not is_equal_approx(previous_end, length_m):
		last_error = "the profile ends at %.1f m instead of %.1f m" % [previous_end, length_m]
		return false
	last_error = ""
	return true


## Симметрия профиля относительно середины маршрута (D033).
## Сэмплы берутся серединами шагов, чтобы не попадать на границы зон, где
## полуоткрытые интервалы дают законный разрыв в одну точку.
func is_symmetric(sample_step_m: float = 25.0) -> bool:
	if sample_step_m <= 0.0:
		last_error = "sample step must be positive"
		return false
	var distance: float = sample_step_m * 0.5
	var last_sample: float = length_m - sample_step_m * 0.5
	while distance <= last_sample:
		var mirror: float = length_m - distance
		if zone_at(distance) != zone_at(mirror):
			last_error = "zone at %.1f m differs from its mirror at %.1f m" % [distance, mirror]
			return false
		distance += sample_step_m
	last_error = ""
	return true


func serialize() -> Dictionary:
	var rows: Array = []
	for segment: Segment in _segments:
		rows.append([segment.start_m, segment.end_m, segment.rock_id, segment.zone, segment.hardness])
	return {"length_m": length_m, "segments": rows}


## Восстанавливает профиль из `serialize`. Возвращает null и печатает ошибку,
## если данные повреждены.
static func deserialize(data: Dictionary) -> HardnessProfile:
	var rows: Variant = data.get("segments")
	if not rows is Array:
		push_error("hardness profile data has no segments")
		return null
	var profile := HardnessProfile.new(null, float(data.get("length_m", DEFAULT_LENGTH_M)))
	for row: Variant in rows:
		if not row is Array or row.size() != 5:
			push_error("hardness profile segment must be [start, end, rock, zone, hardness]")
			return null
		profile._segments.append(Segment.new(
			float(row[0]), float(row[1]), str(row[2]), int(row[3]), float(row[4])
		))
	if not profile.covers_range():
		push_error("hardness profile does not cover the tunnel: " + profile.last_error)
		return null
	return profile
