extends Node

signal new_skills

var skills = {
	"jump": false,
	"dash": false
}


func _ready() -> void:
	pass


func unlock_skill(name: String):
	skills[name] = true
	new_skills.emit()
