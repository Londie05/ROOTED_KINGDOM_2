extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.

func _on_back_pressed() -> void:
	if Global.from_tower_mode:
		# Go back to Floor Selection
		get_tree().change_scene_to_file("res://Scene/TowerSelection.tscn")
	else:
		# Go back to Main Menu
		get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/main_menu.tscn")
