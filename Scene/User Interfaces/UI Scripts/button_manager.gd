extends Control

@onready var small_gem_label = $"../Profile/HBoxContainer/MarginContainer/HBoxContainer/SmallGemHolder/SmallGemLabel"
@onready var crystal_label = $"../Profile/HBoxContainer/MarginContainer/HBoxContainer/CrystalGemHolder/CrystalLabel"
@onready var currency_container = $"../Profile/HBoxContainer/MarginContainer"
@onready var uit_popup = $"../CustomQuitPopup"

@onready var player_name_label = $"../Profile/HBoxContainer/PlayerNameLabel"

func _ready() -> void:
	uit_popup.confirmed.connect(_on_confirmed_quit)
	
	if Global.player_name == "":
		get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/NameEntry.tscn")
		return
		
	player_name_label.visible = true
	currency_container.visible = true
	update_player_info()
	update_currency_ui()
	
func update_currency_ui():
	# Display the values from Global
	small_gem_label.text = "Gem: " + str(Global.small_gems)
	crystal_label.text = "Crystal: " + str(Global.crystal_gems)

func _on_start_battle_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/start_battle.tscn")

func _on_inventory_and_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/CharacterUpgradeUI.tscn")
	
func _on_characters_pressed() -> void:
	Global.from_tower_mode = false # Just looking at characters
	get_tree().change_scene_to_file("res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/tutorial.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/settings.tscn")

func update_player_info():
	player_name_label.text = Global.player_name

#  CHANGE THE BUTTON BEHAVIOR
func _on_quit_pressed() -> void:
	# Show our pretty new custom popup
	uit_popup.show_popup()

# THE ACTUAL QUIT FUNCTION
func _on_confirmed_quit() -> void:
	Global.save_game()
	get_tree().quit()


func _on_profile_button_pressed() -> void:
	player_name_label.visible = !player_name_label.visible
	currency_container.visible = !currency_container.visible
