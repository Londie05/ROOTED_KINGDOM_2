extends Control

@onready var name_input = $ColorRect/CenterContainer/VBoxContainer/NameInput

func _on_confirm_button_pressed() -> void:
	var entered_name = name_input.text.strip_edges()
	
	if entered_name != "":
		Global.player_name = entered_name
		Global.save_game() # Saves to the local file
		
		# --- CHANGE: Go back to LoadingScene instead of MainMenu ---
		get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
	else:
		name_input.placeholder_text = "Name cannot be empty"
