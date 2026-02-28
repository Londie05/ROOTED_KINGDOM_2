extends Control

@onready var tower_availability = $ButtonManager/MarginContainer/Panel/tower_mode/AvailabilityPanel
@onready var endless_availability = $ButtonManager/MarginContainer/Panel/endless_mode/AvailabilityPanel
func _ready():
	_update_mode_locks()

func _update_mode_locks():
	# Tower Mode unlocks after Chapter 1 is cleared
	if Global.story_chapters_cleared.has("Chapter1"):
		tower_availability.visible = false
	else:
		tower_availability.visible = true
		
	# Endless Mode unlocks after Chapter 2 is cleared
	if Global.story_chapters_cleared.has("Chapter2"):
		endless_availability.visible = false
	else:
		endless_availability.visible = true
