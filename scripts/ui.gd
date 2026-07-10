extends CanvasLayer



@onready var jump_button: Control = $Touch_control/Jump_button
@onready var attack_button: Control = $Touch_control/Attack_button
@onready var joystick: Control = $"Touch_control/Virtual Joystick"
@onready var ripple_attack: TextureRect = $Touch_control/Attack_button/ripple
@onready var ripple_jump: TextureRect = $Touch_control/Jump_button/ripple

@onready var buttons = {
	"jump": jump_button
}

@onready var ripples = {
	"attack": ripple_attack,
	"jump": ripple_jump
}

var ripple_tweens = {}

signal attack_pressed
signal jump_pressed


func _ready() -> void:
	update_button()
	#unlock new button
	Gamestate.new_skills.connect(update_button)
	
	#play effect button
	attack_pressed.connect(button_pressed_effect.bind(attack_button, "attack"))
	jump_pressed.connect(button_pressed_effect.bind(jump_button, "jump"))
	joystick.joystick_pressed.connect(joystick_pressed_effect)
	joystick.joystick_released.connect(joystick_released_effect)

#unlock new button
func update_button():
	for skill_name in buttons:
		buttons[skill_name].visible = Gamestate.skills[skill_name]


func _on_touch_screen_attack_pressed() -> void:
	attack_pressed.emit()

func _on_touch_screen_jump_pressed() -> void:
	jump_pressed.emit()

#joystick effect
func joystick_pressed_effect():
	var tween = create_tween()
	tween.tween_property(joystick, "modulate:a", 1.0, 0.15)

func joystick_released_effect():
	var tween = create_tween()
	tween.tween_property(joystick, "modulate:a", 0.51, 0.15)

#button effect
func button_pressed_effect(button_name: Control, ripple_name: String):
	var tween = create_tween()
	tween.tween_property(button_name, "modulate:a", 1.0, 0.15)
	tween.tween_property(button_name, "modulate:a", 0.51, 0.15)
	
	play_ripple(ripple_name)

func play_ripple(ripple_name: String):
	if ripple_tweens.has(ripple_name):
		ripple_tweens[ripple_name].kill()
	ripples[ripple_name].size / 2
	ripples[ripple_name].pivot_offset = ripples[ripple_name].size / 2
	ripples[ripple_name].scale = Vector2.ZERO
	ripples[ripple_name].modulate.a = 0.5

	var tween = create_tween()
	ripple_tweens[ripple_name] = tween
	tween.parallel().tween_property(ripples[ripple_name], "scale", Vector2(2,2), 0.3)
	tween.parallel().tween_property(ripples[ripple_name], "modulate:a", 0, 0.3)
