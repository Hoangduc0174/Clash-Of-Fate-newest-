extends Node2D



@onready var player = $Player
@onready var current_map: Node2D = $Current_map

func _ready() -> void:
	RenderingServer.set_default_clear_color(Color.BLACK)
	current_map.load_map()
	await get_tree().physics_frame
	player.global_position = current_map.map.get_node("spawn_point").global_position
