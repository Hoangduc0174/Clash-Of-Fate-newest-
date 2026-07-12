extends CharacterBody2D
class_name Enemy



enum State{
	IDLE,
	RUN,
	ATTACK,
	DIE
}

@onready var animation_tree: AnimationTree = $Visual/AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var visual: Node2D = $Visual
@onready var collision: CollisionShape2D = $CollisionShape2D

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
var is_knock_back: bool = false


func physics(delta):
	if is_dead:
		return
	if is_knock_back:
		return
	if visual.scale.x == 1: velocity.x = speed
	elif visual.scale.x == -1: velocity.x = -speed
	if not is_on_floor():
		velocity.y += gravity * delta


func update_state():
	if is_dead: return
	if is_knock_back: return
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


func take_damage(amount):
	if is_dead:
		return
	
	hp -= amount
	hp = clamp(hp, 0, max_hp)
	print("Enemy Hp: " + str(hp))
	
	if hp <= 0:
		die()
		return
		
	is_knock_back = true
	state = State.IDLE
	velocity.x = -visual.scale.x * 200
	flash()
	await get_tree().create_timer(0.15).timeout
	is_knock_back = false


func flash():
	if is_flashing:
		return
		
	is_flashing = true
	
	visual.modulate = Color(1, 1, 1, 0.3)
	await get_tree().create_timer(0.08).timeout
	visual.modulate = Color.WHITE
	is_flashing = false
