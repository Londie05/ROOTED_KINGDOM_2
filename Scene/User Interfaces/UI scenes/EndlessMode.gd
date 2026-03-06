extends Control

@onready var high_score_label = $CenterContainer/VBoxContainer/HSPanel/HighestScoreLabel
@onready var start_button = $CenterContainer/VBoxContainer/HSPanel/StartButton

@onready var daily_highest_label = $CenterContainer/VBoxContainer/HSPanel/HighestScoreLabel
@onready var daily_rewards_label = $CenterContainer/VBoxContainer/HSPanel/RewardBox
@onready var reset_timer_label = $CenterContainer/VBoxContainer/HSPanel/ResetTimerDaily

func _ready() -> void:
	Global.check_daily_reset()
	
	high_score_label.text = "All-Time Highest Round: " + str(Global.highest_endless_round)
	daily_highest_label.text = "Highest Round: " + str(Global.daily_highest_round)
	
	daily_rewards_label.text = "Rewards Earned Today: " + str(Global.daily_gems_earned) + " Gems | " + str(Global.daily_crystals_earned) + " Crystals"
	
	start_button.pressed.connect(_on_start_button_pressed)

func _process(delta: float) -> void:
	update_reset_timer()

func update_reset_timer():
	var current_time = Time.get_time_dict_from_system()
	
	var hours_left = 47 - current_time["hour"]
	var minutes_left = 59 - current_time["minute"]
	var seconds_left = 59 - current_time["second"]
	
	var time_string = "%02d:%02d:%02d" % [hours_left, minutes_left, seconds_left]
	
	if reset_timer_label:
		reset_timer_label.text = "Resets in: " + time_string

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/start_battle.tscn")

func _on_start_button_pressed() -> void:
	Global.current_game_mode = Global.GameMode.ENDLESS
	Global.current_endless_round = 1
	
	get_tree().change_scene_to_file("res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn")
