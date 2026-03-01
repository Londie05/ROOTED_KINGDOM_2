extends Control

func _on_back_pressed() -> void:
	Global.current_game_mode = Global.GameMode.TOWER
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/main_menu.tscn")

func _on_tower_mode_pressed() -> void:
	Global.current_game_mode = Global.GameMode.TOWER
	Global.from_tower_mode = true
	get_tree().change_scene_to_file("res://Scene/TowerSelection.tscn")

func _on_story_mode_pressed() -> void:
	Global.current_game_mode = Global.GameMode.STORY
	Global.from_tower_mode = false
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/StoryMode.tscn")

func _on_endless_mode_pressed() -> void:
	Global.current_game_mode = Global.GameMode.ENDLESS
	Global.from_tower_mode = false 
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/EndlessMode.tscn")
