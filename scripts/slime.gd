extends Enemy
class_name Slime


@export var SPEED = 30
@export var GRAVITY = 700
@export var HP = 2
@export var MAX_HP = 2
@export var DAMAGE = 1


func _physics_process(delta: float) -> void:
	physics(delta)
	patrol()
	update_state()
	update_animation() 
	move_and_slide()


func _ready() -> void:
	set_up_shader()
	set_up_patrol()
	damage = DAMAGE
	max_hp = MAX_HP
	hp = HP
	player_in_range = false
	speed = SPEED
	gravity = GRAVITY
	
	animation_tree.set_active(true)



func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		player_in_range = true
		player = body as Player
		attack()


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		player = null


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
		if player_in_range:
			attack()


	if anim_name == "die":
		queue_free()
