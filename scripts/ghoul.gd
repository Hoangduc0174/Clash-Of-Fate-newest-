extends Enemy
class_name Ghoul

@onready var throw_point: Marker2D = $Visual/Marker2D
@export var bone_scene: PackedScene

const SPEED = 30
const GRAVITY = 700


func _ready() -> void:
	set_up_shader()
	set_up_patrol()
	damage = 1
	max_hp = 2
	hp = 2
	player_in_range = false
	speed = SPEED
	gravity = GRAVITY
	
	animation_tree.set_active(true)



func _physics_process(delta: float) -> void:
	physics(delta)
	patrol()
	update_state()
	update_animation()
	move_and_slide()


func throw_bone():
	var bone = bone_scene.instantiate()
	get_tree().current_scene.add_child(bone)
	bone.global_position = throw_point.global_position

	bone.direction = Vector2(visual.scale.x, 0)
	bone.owner_enemy = self
	bone.return_position = global_position

func _on_detect_area_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		player = body as Player
		attack()


func _on_detect_area_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		player = null


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		if player_in_range:
			attack()
	
	if anim_name == "die":
		await get_tree().create_timer(0.3).timeout
		queue_free()
