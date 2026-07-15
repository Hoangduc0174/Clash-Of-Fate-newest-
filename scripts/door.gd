extends Area2D



@onready var hole: AnimatedSprite2D = $visual/hole

signal open_door

func _ready() -> void:
	hole.visible = false
	open_door.connect(func()-> void: hole.visible = true)
