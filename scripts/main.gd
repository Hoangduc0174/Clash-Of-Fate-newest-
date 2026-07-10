extends Node2D

@onready var Player: CharacterBody2D = $Player

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
