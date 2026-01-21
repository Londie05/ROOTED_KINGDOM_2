extends Control

@export var available_heroes: Array[CharacterData] = []
@onready var hero_grid = $ScrollContainer/HeroGrid
@onready var confirm_button = $ConfirmButton
@onready var slot_container = $TeamPanel/SlotContainer

var selection_card_scene = preload("res://Scene/User Interfaces/CharacterScenes/SelectionCard.tscn")

func _ready():
	Global.clear_team()
	update_confirm_button()
	display_roster()
	
func display_roster():
	for data in available_heroes:
		var card = selection_card_scene.instantiate()
		hero_grid.add_child(card)
		
		card.get_node("Illustration").texture = data.character_illustration
		card.get_node("NameLabel").text = data.name
		
		card.pressed.connect(_on_hero_selection.bind(data, card))
		
func _on_hero_selection(data: CharacterData, card_node: Button):
	if data in Global.selected_team:
		Global.selected_team.erase(data)
		card_node.get_node("SelectionOverlay").hide()
	elif Global.selected_team.size() < 3:
		Global.add_to_team(data)
		card_node.get_node("SelectionOverlay").show()
		print("Added " + data.name + " to team.")
		
	update_confirm_button()
	update_team_ui()
	
func update_confirm_button():
	# Only let the player continue if they have exactly 3 heroes selected
	confirm_button.disabled = Global.selected_team.size() != 3
	
func _on_confirm_button_pressed():
	# Go to the Mode Selection or Battle
	get_tree().change_scene_to_file("res://Scene/battlefield.tscn")

func update_team_ui():
	# 1. Clear the old icons in the bottom slots
	for child in slot_container.get_children():
		child.queue_free()
	
	# 2. Create a small icon for every hero currently in the Global team
	for hero in Global.selected_team:
		var icon = TextureRect.new()
		icon.texture = hero.character_illustration
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(130, 80) # Small square size
		slot_container.add_child(icon)
