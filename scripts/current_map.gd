extends Node2D

var map: Node2D = null


func load_map():
	if map != null:
		map.queue_free()
	map = MapData.current_map_scene.instantiate()
	add_child(map)
	
