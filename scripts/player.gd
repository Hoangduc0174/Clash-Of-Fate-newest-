extends CharacterBody2D


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

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var animation_playback: AnimationNodeStateMachinePlayback = $AnimationTree["parameters/playback"]
@onready var texture_anim: Sprite2D = $Sprite2D

const SPEED = 160
const JUMP = -350
const GRAVITY = 800

var is_attacking:bool = false
var can_attack: bool = true
var flip_timer:float = 0.0
var flip_delay_time:float = 0.1

var move_direction: Vector2 = Vector2.ZERO
var state: State = State.IDLE


func _ready() -> void:
	#active animation tree (animation ko auto run khi edit)
	animation_tree.set_active(true)


func _physics_process(delta: float) -> void:
	char_flip(delta) #xoay
	jump_and_fall()
	physics(delta)
	attack()
	move_and_slide()
	update_state()
	update_animation()


func physics(delta):
	move_direction.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	velocity.x = move_direction.x * SPEED
	if not is_on_floor(): velocity.y += GRAVITY * delta


func update_state():
	if is_attacking: return
	if velocity.y < -0.01: state = State.JUMP
	elif velocity.y > 0.01: state = State.FALL
	if is_on_floor():
		if move_direction.x != 0: state = State.RUN
		else: state = State.IDLE


func update_animation():
	match state:
		State.IDLE: animation_playback.travel("idle")
		State.RUN: animation_playback.travel("run")
		State.ATTACK: animation_playback.travel("attack")
		State.JUMP: animation_playback.travel("jump")
		State.FALL: animation_playback.travel("fall")
		State.TURN_AROUND: animation_playback.travel("turn_around")


func attack():
	if is_on_floor(): can_attack = true #on floor danh thoai mai
	if is_attacking:
		if is_on_floor(): 
			velocity.x = 0
		else:
			can_attack = false #on air chi cho danh 1 phat
		return
	if Input.is_action_just_pressed("attack") and can_attack:
		is_attacking = true
		state = State.ATTACK


func jump_and_fall():
	if Gamestate.skills["jump"]:
		if Input.is_action_just_pressed("jump") and is_on_floor():
				velocity.y = JUMP


func char_flip(time):
	if is_attacking: return
	if flip_timer > 0: flip_timer -= time
		
	if move_direction.x < 0 and not texture_anim.flip_h and flip_timer <= 0:
		texture_anim.flip_h = true
		flip_timer = flip_delay_time
	elif move_direction.x > 0 and texture_anim.flip_h and flip_timer <= 0:
		texture_anim.flip_h = false
		flip_timer = flip_delay_time


func _on_animation_tree_animation_attack_finished(anim_name: StringName) -> void:
	if anim_name == "attack":
		is_attacking = false
