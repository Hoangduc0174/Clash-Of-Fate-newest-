extends CharacterBody2D
class_name Player

enum State{
	IDLE,
	RUN,
	TURN_AROUND,
	JUMP,
	JUMP_FALL_BETWEEN,
	FALL,
	ATTACK,
	HURT,
	DIE
}

@onready var animation_tree: AnimationTree = $Visual/AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var visual: Node2D = $Visual


const SPEED = 130
const JUMP = -360
const GRAVITY = 800

var is_attacking:bool = false
var can_attack: bool = true
var is_hurt: bool = false

var flip_timer:float = 0.0
var flip_delay_time:float = 0.1
var coyote_time := 0.1
var coyote_timer := 0.0
var jump_buffer_time := 0.2
var jump_buffer_timer := 0.0

var move_direction: Vector2 = Vector2.ZERO
var state: State = State.IDLE

var enemy: Enemy
var enemy_in_range: bool = false

var damage: int = 1
var max_hp: int = 5
var hp: int = 1

func _ready() -> void:
	#active animation tree (animation ko auto run khi edit)
	animation_tree.set_active(true)


func _physics_process(delta: float) -> void:
	buffer_jump_and_coyote_time(delta) # nhay muot hon
	char_flip(delta) # xoay
	physics(delta) # di chuyen va roi
	attack() # tan cong
	jump() # nhay
	update_state() # cap nhat trang thai
	update_animation() # cap nhat animation qua trang thai
	move_and_slide() # cap nhat velocity va xu li va cham


func physics(delta):
	move_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	velocity.x = move_direction.x * SPEED
	
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	if is_hurt:
		velocity.x = 0
	
	if is_attacking and is_on_floor():
		velocity.x = 0


func update_state():
	if is_hurt: 
		return
	if is_attacking: return
	if not is_on_floor():
		if velocity.y < -0.01: state = State.JUMP
		elif velocity.y > 0.01: state = State.FALL
	else:
		if move_direction.x != 0: state = State.RUN
		else: state = State.IDLE


func update_animation():
	match state:
		State.IDLE: animation_playback.travel("idle")
		State.RUN: animation_playback.travel("run")
		State.ATTACK: animation_playback.travel("attack")
		State.JUMP: animation_playback.travel("jump")
		State.FALL: animation_playback.travel("fall")
		State.HURT: animation_playback.travel("hurt")
		State.TURN_AROUND: animation_playback.travel("turn_around")


func attack():
	if is_hurt:
		return
	if is_on_floor(): can_attack = true #on floor danh thoai mai
	if is_attacking:
		if not is_on_floor():
			can_attack = false #on air chi cho danh 1 phat
		return
	if Input.is_action_just_pressed("attack") and can_attack:
		is_attacking = true
		state = State.ATTACK


func buffer_jump_and_coyote_time(delta):
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time

	jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.7


func jump():
	if is_hurt: return
	if !Gamestate.skills["jump"]: return

	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP
		jump_buffer_timer = 0
		coyote_timer = 0


func char_flip(time):
	if is_attacking: return
	if flip_timer > 0: flip_timer -= time
		
	if move_direction.x < 0 and visual.scale.x == 1 and flip_timer <= 0:
		visual.scale.x = -1
		flip_timer = flip_delay_time
	elif move_direction.x > 0 and visual.scale.x == -1 and flip_timer <= 0:
		visual.scale.x = 1
		flip_timer = flip_delay_time


func deal_damage():
	if enemy_in_range and enemy and is_attacking:
		enemy.take_damage(damage, global_position.x)


func take_damage(amount):
	state = State.HURT
	is_hurt = true
	get_viewport().get_camera_2d().shake()
	hp -= amount
	hp = clamp(hp, 0, max_hp)


func die():
	pass


func _on_animation_tree_animation_attack_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
	if anim_name == "hurt":
		is_hurt = false


func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is Enemy:
		enemy_in_range = true
		enemy = body as Enemy


func _on_hitbox_body_exited(body: Node2D) -> void:
	if body is Enemy:
		enemy_in_range = false
