extends Area2D

@export var speed := 200.0
@export var return_speed := 250.0

var direction := Vector2.RIGHT
var owner_enemy: Enemy
var return_position: Vector2
var is_returning := false


var player: Player
var damage: int = 1

func _ready():
	await get_tree().create_timer(0.8).timeout
	is_returning = true

func _physics_process(delta):
	if !is_returning:
		global_position += direction * speed * delta
	else:
		if is_instance_valid(owner_enemy):
			return_position = owner_enemy.global_position

		var dir = (return_position - global_position).normalized()
		global_position += dir * return_speed * delta

		if global_position.distance_to(return_position) < 10:
			queue_free()
	


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body as Player
		player.take_damage(damage)
