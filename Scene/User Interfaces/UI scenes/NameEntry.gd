extends Control

@onready var name_input = $ColorRect/CenterContainer/VBoxContainer/NameInput
@onready var confirmation_popup = $CustomQuitPopup 
@onready var title_label = $ColorRect/CenterContainer/VBoxContainer/Label # Assuming there is a title label

func _ready() -> void:
	confirmation_popup.confirmed.connect(_on_name_confirmed_final)
	
	# Check Mode
	if Global.is_renaming_mode:
		name_input.text = Global.player_name
		if title_label: title_label.text = "Rename Account"
	else:
		name_input.text = ""
		if title_label: title_label.text = "Enter Name"

func _on_confirm_button_pressed() -> void:
	var entered_name = name_input.text.strip_edges()
	
	if entered_name == "":
		name_input.placeholder_text = "Name cannot be empty"
		return
	if entered_name.length() > 10:
		name_input.text = "" 
		name_input.placeholder_text = "Too long! Max 10 chars"
		return 
	
	# Show Confirmation
	confirmation_popup.setup_popup(
		"Use this name: " + entered_name + "?", 
		"Yes", 
		"No"
	)
	confirmation_popup.show_popup()

func _on_name_confirmed_final() -> void:
	var entered_name = name_input.text.strip_edges()
	
	if Global.is_renaming_mode:
		Global.complete_rename(entered_name)
		
		Global.loading_target_scene = "res://Scene/User Interfaces/UI scenes/settings.tscn"
		
		get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
		
	else:
		Global.complete_account_creation(entered_name)
		
		Global.loading_target_scene = "res://Scene/User Interfaces/UI scenes/main_menu.tscn"
		
		get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
