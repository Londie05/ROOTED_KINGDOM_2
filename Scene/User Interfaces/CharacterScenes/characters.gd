extends Control

@export var available_heroes: Array[CharacterData] = []
@onready var hero_grid = $ScrollContainer/HeroGrid
@onready var confirm_button = $ConfirmButton
@onready var slot_container = $TeamPanel/SlotContainer

var selection_card_scene = preload("res://Scene/User Interfaces/CharacterScenes/SelectionCard.tscn")

@onready var detail_name = $DetailPanel/VBoxContainer/NameLabel
@onready var detail_stats = $DetailPanel/VBoxContainer/StatsLabel
@onready var unique_anchor = $DetailPanel/VBoxContainer/UniqueCardAnchor
@onready var common_grid = $DetailPanel/VBoxContainer/ScrollContainer/CommonGrid

# We need this to create the actual card images
var card_ui_scene = preload("res://Scene/CardUI.tscn")

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
		

	
	update_details(data)	
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


func update_details(data: CharacterData):
	detail_name.text = data.name
	detail_stats.text = "HP: " + str(data.max_health) + " | Shield: " + str(data.base_shield)
	
	for child in common_grid.get_children(): 
		child.queue_free()

	# Create a combined list: Unique Card + Common Cards
	var all_cards = []
	if data.unique_card:
		all_cards.append(data.unique_card)
	all_cards.append_array(data.common_cards)

	for card_data in all_cards:
		# 1. Create a Horizontal Container for this row
		var row = HBoxContainer.new()
		row.custom_minimum_size.y = 150 # Match your CardUI height
		row.add_theme_constant_override("separation", 15)
		common_grid.add_child(row)
		
		# 2. Add the CardUI
		var c_card = card_ui_scene.instantiate()
		row.add_child(c_card)
		c_card.setup(card_data)
		
		if c_card.has_node("VBoxContainer/PlayButton"):
			c_card.get_node("VBoxContainer/PlayButton").hide()
		
		# 3. Add the Description Label
		var desc_label = Label.new()
		desc_label.text = card_data.description # Ensure CardData has a 'description' variable
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.custom_minimum_size.x = 200 # Adjust based on panel width
		desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		# Optional: Make Unique Card text a different color
		if card_data == data.unique_card:
			desc_label.modulate = Color(1, 0.8, 0.3) # Golden text for Unique
			desc_label.text = "[SIGNATURE]\n" + desc_label.text
		else:
			desc_label.modulate = Color(0.535, 0.899, 0.935, 1.0) # Golden text for Unique
			desc_label.text = "[COMMON CARD]\n" + desc_label.text
		row.add_child(desc_label)
	
