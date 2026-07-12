extends Camera2D

var shake_time := 0.0
var shake_strength := 0.0
var original_offsets := Vector2.ZERO

func shake(strength := 3.0, time := 0.08):
	shake_strength = strength
	shake_time = time

func _process(delta):
	if shake_time > 0:
		shake_time -= delta
		offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)

	if shake_time <= 0:
		offset = original_offsets
