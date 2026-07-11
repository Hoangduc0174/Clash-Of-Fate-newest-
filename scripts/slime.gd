extends CharacterBody2D
class_name Enemy



@onready var animation_tree: AnimationTree = $Visual/AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var visual: Node2D = $Visual



enum State{
	IDLE,
	RUN,
	TURN_AROUND,
	JUMP,
	JUMP_FALL_BETWEEN,
	FALL,
	ATTACK,
	DIE
}


const SPEED = 30

var is_attacking: bool = false
var player_in_range: bool = false

var state:State = State.IDLE
var player: Player

var damage: int = 1
var max_hp: int = 2
var hp: int = 2


func _physics_process(delta: float) -> void:
	physics()
	update_state()
	update_animation() 
	move_and_slide()


func _ready() -> void:
		animation_tree.set_active(true)
		visual.scale.x = -1


func physics():
	if visual.scale.x == 1: velocity.x = SPEED
	elif visual.scale.x == -1: velocity.x = -SPEED


func update_state():
	if is_attacking: 
		velocity.x = 0
		return
	if velocity.x != 0: state = State.RUN
	elif velocity.x == 0: state = State.IDLE


func update_animation():
	match state:
		State.IDLE: animation_playback.travel("idle")
		State.RUN: animation_playback.travel("run")
		State.ATTACK: animation_playback.travel("attack")


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body as Player
		attack()


func deal_damage():
	if player_in_range and player:
		player.take_damage(damage)


func take_damage(amount):
		hp -= amount
		hp = clamp(hp, 0, max_hp)
		print("Enemy Hp: " + str(hp))


func attack():
		state = State.ATTACK
		player_in_range = true
		is_attacking = true


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body is Player:
		player_in_range = false
		player = null


func _on_animation_tree_animation_finished(anim_name: StringName) -> void:
	if anim_name == "attack" and not player_in_range:
		is_attacking = false
