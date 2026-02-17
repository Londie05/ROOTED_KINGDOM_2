extends Control

@onready var back_button = $Back
@onready var custom_quit_popup = $"../CustomQuitPopup"

func _ready() -> void:
	pass # Replace with function body.

func _on_back_pressed() -> void:
	if Global.from_tower_mode:
		get_tree().change_scene_to_file("res://Scene/TowerSelection.tscn")
	elif Global.current_game_mode == Global.GameMode.STORY:
		_show_exit_verification()
	else:
		get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/main_menu.tscn")

func _confirm_exit():
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/StoryMode.tscn")
	
func _show_exit_verification():
	custom_quit_popup.setup_popup("Quit Selection?", "Yes, Quit", "Cancel", 1.0)
	
	if custom_quit_popup.confirmed.is_connected(_confirm_exit):
		custom_quit_popup.confirmed.disconnect(_confirm_exit)
	
	custom_quit_popup.confirmed.connect(_confirm_exit)
	custom_quit_popup.show_popup()
