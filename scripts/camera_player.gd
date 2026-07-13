extends Camera2D

@export var noise_frequency := 25.0
@export var return_speed := 80.0

var noise := FastNoiseLite.new()

var shake_time := 0.0
var shake_duration := 0.0
var shake_strength := 0.0
var noise_pos := 0.0

func _ready():
	randomize()
	noise.seed = randi()
	noise.frequency = noise_frequency

func shake(strength := 4.0, duration := 0.08):
	# Nếu đang rung mà có cú đánh mạnh hơn thì ghi đè
	shake_strength = max(shake_strength, strength)
	shake_duration = max(shake_duration, duration)
	shake_time = max(shake_time, duration)

func _physics_process(delta):
	if shake_time > 0.0:
		shake_time -= delta
		noise_pos += delta * 60.0

		var t := shake_time / shake_duration
		var current_strength := shake_strength * t * t

		offset.x = noise.get_noise_2d(noise_pos, 0.0) * current_strength
		offset.y = noise.get_noise_2d(0.0, noise_pos) * current_strength

		if shake_time <= 0.0:
			shake_strength = 0.0
			shake_duration = 0.0
	else:
		offset = offset.move_toward(Vector2.ZERO, return_speed * delta)
