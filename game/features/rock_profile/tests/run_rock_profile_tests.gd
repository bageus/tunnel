extends SceneTree

## Тесты `features.rock_profile` без сцены.
##
## Запуск: godot --headless --path . -s game/features/rock_profile/tests/run_rock_profile_tests.gd
## Проект должен быть импортирован (`godot --headless --path . --editor --quit`).

const RegistryScript := preload("res://game/features/rock_profile/public/rock_registry.gd")
const ProfileScript := preload("res://game/features/rock_profile/public/hardness_profile.gd")


func _init() -> void:
	var failures := 0
	failures += _test_registry()
	failures += _test_coverage()
	failures += _test_zones()
	failures += _test_hardness()
	failures += _test_every_rock_appears()
	failures += _test_out_of_range()
	failures += _test_serialization()
	failures += _test_custom_length()
	print("rock profile test: %d failure(s)" % failures)
	quit(1 if failures else 0)


func _test_registry() -> int:
	var registry: RefCounted = RegistryScript.default_registry()
	var failures := 0
	failures += _check(registry.count() == 20, "the registry holds 20 rocks")
	failures += _check(registry.zone_size(1) == 5, "zone I has five rocks")
	failures += _check(registry.zone_size(2) == 4, "zone II has four rocks")
	failures += _check(registry.zone_size(3) == 4, "zone III has four rocks")
	failures += _check(registry.zone_size(4) == 4, "zone IV has four rocks")
	failures += _check(registry.zone_size(5) == 3, "zone V has three rocks")
	failures += _check(registry.hardness_of_zone(1) == 1.0 and registry.hardness_of_zone(5) == 5.0,
			"zone hardness runs from 1.0 to 5.0")
	var granite: RefCounted = registry.by_id("granite")
	failures += _check(granite != null and granite.zone == 3, "a rock is found by id")
	failures += _check(registry.by_id("nope") == null and registry.last_error != "",
			"an unknown rock id is refused with an error")
	failures += _check(registry.stubborn_chance_of_zone(5) > registry.stubborn_chance_of_zone(1),
			"the ore zone has more stubborn sections")
	var ids: Dictionary = {}
	for rock: RefCounted in registry.all():
		ids[rock.id] = true
	failures += _check(ids.size() == 20, "rock ids are unique")
	return failures


func _test_coverage() -> int:
	var profile: RefCounted = ProfileScript.new(RegistryScript.default_registry(), 10000.0)
	var failures := 0
	failures += _check(profile.covers_range(), "the profile covers 0..10000 m without gaps")
	failures += _check(profile.segment_count() > 20, "the profile is split into rock segments")
	var widths_ok := true
	for segment: RefCounted in profile.segments():
		if segment.width() <= 0.0:
			widths_ok = false
	failures += _check(widths_ok, "every segment has positive width")
	return failures


func _test_zones() -> int:
	var profile: RefCounted = ProfileScript.new(RegistryScript.default_registry(), 10000.0)
	var failures := 0
	failures += _check(profile.zone_at(0.0) == 1, "the entrance starts in zone I")
	failures += _check(profile.zone_at(499.0) == 1, "zone I reaches 500 m")
	failures += _check(profile.zone_at(500.0) == 2, "zone II starts at 500 m")
	failures += _check(profile.zone_at(5000.0) == 5, "the middle of the mountain is the ore zone")
	failures += _check(profile.zone_at(10000.0) == 1, "the exit is in zone I again")
	failures += _check(profile.zone_at(2500.0) == 3, "2500 m sits in zone III")
	failures += _check(profile.is_symmetric(), "zones mirror around the middle of the tunnel")
	return failures


func _test_hardness() -> int:
	var profile: RefCounted = ProfileScript.new(RegistryScript.default_registry(), 10000.0)
	var failures := 0
	failures += _check(profile.hardness_at(0.0) == 1.0, "the entrance is soft")
	failures += _check(profile.hardness_at(2500.0) == 3.0, "the middle third is hard")
	failures += _check(profile.hardness_at(5000.0) == 5.0, "the centre is super hard")
	failures += _check(profile.hardness_at(1000.0) == profile.hardness_at(9000.0),
			"hardness mirrors around the middle")
	failures += _check(profile.hardness_at(0.0) < profile.hardness_at(2500.0)
			and profile.hardness_at(2500.0) < profile.hardness_at(5000.0),
			"hardness grows towards the centre")
	return failures


func _test_every_rock_appears() -> int:
	var registry: RefCounted = RegistryScript.default_registry()
	var profile: RefCounted = ProfileScript.new(registry, 10000.0)
	var seen: Dictionary = {}
	for segment: RefCounted in profile.segments():
		seen[segment.rock_id] = true
	var failures := 0
	failures += _check(seen.size() == 20, "all twenty rocks appear along the route")
	for rock: RefCounted in registry.all():
		if not seen.has(rock.id):
			failures += _check(false, "rock %s never appears" % rock.id)
	return failures


func _test_out_of_range() -> int:
	var profile: RefCounted = ProfileScript.new(RegistryScript.default_registry(), 10000.0)
	var failures := 0
	failures += _check(profile.zone_at(-1.0) == -1, "a negative distance has no zone")
	failures += _check(profile.last_error != "", "a negative distance explains itself")
	failures += _check(profile.rock_id_at(10001.0) == "", "a distance past the exit has no rock")
	failures += _check(profile.hardness_at(-0.5) == -1.0, "a negative distance has no hardness")
	failures += _check(profile.segment_at(10001.0) == null, "a segment past the exit is refused")
	return failures


func _test_serialization() -> int:
	var profile: RefCounted = ProfileScript.new(RegistryScript.default_registry(), 10000.0)
	var failures := 0
	var data: Dictionary = profile.serialize()
	failures += _check((data.get("segments") as Array).size() == profile.segment_count(),
			"serialization keeps every segment")
	var restored: RefCounted = ProfileScript.deserialize(data)
	failures += _check(restored != null, "the profile is restored from data")
	if restored != null:
		failures += _check(restored.segment_count() == profile.segment_count(), "segment count survives")
		failures += _check(restored.zone_at(5000.0) == 5, "the centre stays the ore zone")
		failures += _check(restored.covers_range(), "the restored profile covers the tunnel")
		failures += _check(restored.serialize().get("segments") == data.get("segments"),
				"serialization round-trip is lossless")
	failures += _check(ProfileScript.deserialize({"length_m": 10000.0, "segments": [[0.0, 10000.0, "loam", 1, 1.0]]}) != null,
			"a single-span profile is accepted")
	failures += _check(ProfileScript.deserialize({"length_m": 10000.0,
			"segments": [[0.0, 500.0, "loam", 1, 1.0], [600.0, 10000.0, "loam", 1, 1.0]]}) == null,
			"a profile with a gap is refused")
	return failures


func _test_custom_length() -> int:
	var profile: RefCounted = ProfileScript.new(RegistryScript.default_registry(), 5000.0)
	var failures := 0
	failures += _check(profile.covers_range(), "a shorter tunnel is covered")
	failures += _check(profile.zone_at(2500.0) == 5, "the middle of a shorter tunnel is still the ore zone")
	failures += _check(profile.zone_at(0.0) == 1 and profile.zone_at(5000.0) == 1,
			"both ends of a shorter tunnel are soft")
	failures += _check(profile.is_symmetric(), "a shorter tunnel profile is symmetric too")
	failures += _check(ProfileScript.new(RegistryScript.default_registry(), 0.0).covers_range() == false,
			"a zero-length profile is refused")
	return failures


func _check(ok: bool, name: String) -> int:
	if not ok:
		push_error("FAIL: " + name)
	return 0 if ok else 1
