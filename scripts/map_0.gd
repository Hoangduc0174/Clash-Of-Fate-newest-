extends Node2D

@onready var slime: Node2D = $slime
var unlocked: bool = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_instance_valid(slime):
		if not unlocked:
			Gamestate.unlock_skill("jump")
			unlocked = true
