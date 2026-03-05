extends Control

@onready var play_button: TextureButton = $Button

func _ready():
	Global.load_master_config()
	
	play_button.modulate.a = 0
	var tween = create_tween()
	tween.tween_property(play_button, "modulate:a", 1.0, 2)

func _on_button_pressed() -> void:
	if Global.all_accounts.is_empty():
		Global.loading_target_scene = "res://Scene/User Interfaces/UI scenes/NameEntry.tscn"
	else:
		Global.loading_target_scene = "res://Scene/User Interfaces/UI scenes/AccountSelection.tscn"
	
	get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
