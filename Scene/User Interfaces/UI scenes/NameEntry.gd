extends Control

@onready var name_input = $ColorRect/CenterContainer/VBoxContainer/NameInput
@onready var confirmation_popup = $CustomQuitPopup 

func _ready() -> void:
	confirmation_popup.confirmed.connect(_on_name_confirmed_final)

func _on_confirm_button_pressed() -> void:
	var entered_name = name_input.text.strip_edges()
	
	if entered_name == "":
		name_input.placeholder_text = "Name cannot be empty"
		return
	if entered_name.length() > 10:
		name_input.text = "" 
		name_input.placeholder_text = "Too long! Max 10 chars"
		return 
	
	# If it passes both checks, show the popup
	confirmation_popup.setup_popup(
		"Are you sure with your name?", 
		"Yes", 
		"No"
	)
	confirmation_popup.show_popup()

func _on_name_confirmed_final() -> void:
	var entered_name = name_input.text.strip_edges()
	Global.player_name = entered_name
	Global.save_game()
	get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
