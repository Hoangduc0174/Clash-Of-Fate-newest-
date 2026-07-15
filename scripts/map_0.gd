extends Node2D

@onready var slime: Node2D = $Monster/slime
@onready var door_end: Area2D = $Door_end
@onready var door_start: Area2D = $Door_start
@onready var monster: Node2D = $Monster
var unlocked: bool = false
var opened: bool = false

@onready var player

func _ready() -> void:
	door_start.open_door.emit()
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player") as Player
	player.camera.limit_right = 3250.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_instance_valid(slime):
		if not unlocked:
			Gamestate.unlock_skill("jump")
			unlocked = true
			
	if not opened:
		if monster.get_child_count() == 0:
			door_end.open_door.emit()
			opened = true
