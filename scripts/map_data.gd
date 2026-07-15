extends Node



var maps = {
	0 : "res://scenes/Map_0.tscn"
}

var current_map_scene: PackedScene = load(maps[0])

# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass
