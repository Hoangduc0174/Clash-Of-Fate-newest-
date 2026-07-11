extends Node

signal new_skills

var skills = {
	"jump": false,
	"dash": false
}


func _ready() -> void:
	pass # Replace with function body.


func unlock_skill(name: String):
	skills[name] = true
	new_skills.emit()
