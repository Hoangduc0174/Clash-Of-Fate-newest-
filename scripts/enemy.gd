extends CharacterBody2D
class_name Enemy



enum State{
	IDLE,
	RUN,
	ATTACK,
	HURT,
	DIE
}

@onready var animation_tree: AnimationTree = $Visual/AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var visual: Node2D = $Visual
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Visual/Sprite2D


@export var patrol_distance := 20.0
var start_x: float

const FLASH_SHADER = preload("res://scripts/flash.gdshader")

var player_in_range: bool = false
var player: Player = null
var damage: int  = 1
var max_hp: int = 1
var hp: int = 1
var speed: int = 0
var gravity: int = 0

var state:State = State.IDLE
var is_attacking: bool = false
var is_flashing: bool = false
var is_dead: bool = false
var is_hurt: bool = false



func set_up_shader():
	var mat := ShaderMaterial.new()
	mat.shader = FLASH_SHADER
	sprite.material = mat


func physics(delta):
	if is_dead:
		return
	if is_hurt:
		return
	if visual.scale.x == 1: velocity.x = speed
	elif visual.scale.x == -1: velocity.x = -speed
	if not is_on_floor():
		velocity.y += gravity * delta


func update_state():
	if is_dead: return
	if is_hurt: return
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
		State.DIE: animation_playback.travel("die")
		State.HURT: animation_playback.travel("hurt")


func attack():
	if is_dead:
		return
	if is_attacking:
		return
	state = State.ATTACK
	is_attacking = true


func deal_damage():
	if player_in_range and player:
		player.take_damage(damage)


func die():
	collision.disabled = true
	state = State.DIE
	velocity.x = 0
	is_dead = true


func take_damage(amount, player_position):
	if is_dead:
		return
	
	if is_hurt:
		return
	
	get_viewport().get_camera_2d().shake(2.5, 0.5)
	hp -= amount
	hp = clamp(hp, 0, max_hp)
	
	if hp <= 0:
		await flash()
		die()
		return
		
	knock_back(player_position)


func knock_back(player_position):
	is_attacking = false
	is_hurt = true
	state = State.HURT

	var dir = sign(global_position.x - player_position)
	velocity.x = dir * 100

	await flash()
	await get_tree().create_timer(0.15).timeout
	is_hurt = false
	if player_in_range:
		attack()


func can_see_player() -> bool:
	if player == null:
		return false

	var space = get_world_2d().direct_space_state

	var query = PhysicsRayQueryParameters2D.create(
		global_position,
		player.global_position
	)

	query.exclude = [self]

	var result = space.intersect_ray(query)

	return result and result.collider == player


func set_up_patrol():
	start_x = global_position.x


func patrol():
	if is_dead or is_hurt or is_attacking:
		return

	if global_position.x >= start_x + patrol_distance:
		visual.scale.x = -1

	elif global_position.x <= start_x - patrol_distance:
		visual.scale.x = 1


func flash():
	if is_flashing:
		return

	is_flashing = true

	var mat := sprite.material as ShaderMaterial

	mat.set_shader_parameter("flash_amount", 1.0)
	await get_tree().create_timer(0.1).timeout
	mat.set_shader_parameter("flash_amount", 0)


	is_flashing = false
