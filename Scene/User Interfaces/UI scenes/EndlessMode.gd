extends Control

# Connect your new UI nodes here
@onready var high_score_label = $CenterContainer/VBoxContainer/HSPanel/HighestScoreLabel
@onready var start_button = $CenterContainer/VBoxContainer/HSPanel/StartButton

func _ready() -> void:
	# 1. Update the UI with the player's actual high score
	# We'll use the variable we added to Global earlier
	high_score_label.text = "Highest Round: " + str(Global.highest_endless_round)
	
	# 2. Make sure the Start button is ready to click
	start_button.pressed.connect(_on_start_button_pressed)

func _on_back_button_pressed() -> void:
	# Sends player back to the Mode Selection
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/start_battle.tscn")

func _on_start_button_pressed() -> void:
	# Set the mode so the Battlefield knows what to spawn later
	Global.current_game_mode = Global.GameMode.ENDLESS
	Global.current_endless_round = 1
	
	# Go to Character Selection so they can pick their team
	get_tree().change_scene_to_file("res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn")
