extends Control

@export var available_heroes: Array[CharacterData] = []
@onready var hero_grid = $ScrollContainer/HeroGrid
@onready var confirm_button = $ConfirmButton
@onready var slot_container = $TeamPanel/SlotContainer

@onready var small_gem_label = $MarginContainer/HBoxContainer/SmallGemHolder/SmallGemLabel
@onready var crystal_label = $MarginContainer/HBoxContainer/CrystalGemHolder/CrystalLabel

@onready var detail_name = $DetailPanel/VBoxContainer/NameLabel
@onready var detail_stats = $DetailPanel/VBoxContainer/StatsLabel
@onready var common_grid = $DetailPanel/VBoxContainer/ScrollContainer/CommonGrid
@onready var unlock_btn = $DetailPanel/UnlockButton


var selection_card_scene = preload("res://Scene/User Interfaces/CharacterScenes/SelectionCard.tscn")
var card_ui_scene = preload("res://Scene/CardUI.tscn")

var current_viewed_hero: CharacterData = null


func _ready():
	Global.clear_team()
	display_roster()
	update_currency_ui()
	
	# Only show the confirm button if we came from Tower Mode
	if Global.from_tower_mode:
		confirm_button.visible = true
	else:
		confirm_button.visible = false
		
	$ConfirmButton.pressed.connect(_on_confirm_battle_pressed)
	if unlock_btn:
		unlock_btn.pressed.connect(_on_unlock_hero_pressed)
		unlock_btn.hide()
	
	if Global.from_tower_mode == false:
		var team_panel = $TeamPanel
		var scroll = $ScrollContainer
		scroll.position.y = 150 
		scroll.size.y = 850
		
		team_panel.hide()
		
func update_currency_ui():
	small_gem_label.text = "Gem: " + str(Global.small_gems)
	crystal_label.text = "Crystal: " + str(Global.crystal_gems)

func display_roster():
	for child in hero_grid.get_children():
		child.queue_free()

	for data in Global.roaster_list:
		var card = selection_card_scene.instantiate()
		hero_grid.add_child(card)
		
		Global.connect_buttons_recursive(card)
		
		card.get_node("Illustration").texture = data.character_illustration
		card.get_node("NameLabel").text = data.name
		
		var is_actually_locked = data.is_locked and not Global.is_hero_unlocked(data.name)
		
		if is_actually_locked:
			card.modulate = Color(0.3, 0.3, 0.3, 1.0)
			card.get_node("NameLabel").text = "LOCKED"
		else:
			card.modulate = Color.WHITE
			if data in Global.selected_team:
				card.get_node("SelectionOverlay").show()
		
		card.pressed.connect(_on_hero_selection.bind(data, card))

# --- 3. SELECTION LOGIC ---
func _on_hero_selection(data: CharacterData, card_node: Button):
	current_viewed_hero = data
	update_details(data)
	
	# 1. Create a single variable to determine if the hero is locked or owned
	var is_actually_locked = data.is_locked and not Global.is_hero_unlocked(data.name)
	
	if is_actually_locked:
		# SHOW UNLOCK BUTTON
		if unlock_btn:
			unlock_btn.text = "Unlock: " + str(data.unlock_cost) + " Gems"
			unlock_btn.show()
			unlock_btn.disabled = (Global.small_gems < data.unlock_cost)
		
		return 
	
	# Hide the unlock button 
	if unlock_btn: 
		unlock_btn.hide()
	
	# 3. ADD/REMOVE FROM TEAM LOGIC
	if data in Global.selected_team:
		Global.selected_team.erase(data)
		card_node.get_node("SelectionOverlay").hide()
		print("Removed " + data.name + " from team.")
	elif Global.selected_team.size() < 3:
		Global.add_to_team(data)
		card_node.get_node("SelectionOverlay").show()
		print("Added " + data.name + " to team.")
	else:
		print("Team is full!")
		
	update_team_ui()

func _on_unlock_hero_pressed():
	if current_viewed_hero == null: return
	
	if Global.small_gems >= current_viewed_hero.unlock_cost:
		Global.small_gems -= current_viewed_hero.unlock_cost
		
		# SAVE TO GLOBAL SO IT PERSISTS
		Global.unlock_hero(current_viewed_hero.name)
		
		display_roster()
		update_details(current_viewed_hero)
		if unlock_btn: unlock_btn.hide()
		
	update_currency_ui()
	
func _on_confirm_battle_pressed():
	if Global.selected_team.size() > 0:
		# 1. Set the target destination
		if Global.from_tower_mode:
			Global.loading_target_scene = "res://Scene/battlefield.tscn"
		# 2. Go to the loading scene
		get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
	else:
		print("You must select at least one character!")

func update_team_ui():
	for child in slot_container.get_children():
		child.queue_free()
	
	for hero in Global.selected_team:
		var icon = TextureRect.new()
		icon.texture = hero.character_illustration
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(130, 80)
		slot_container.add_child(icon)

func update_details(data: CharacterData):
	detail_name.text = data.name
	detail_stats.text = "HP: " + str(data.max_health) + " | Shield: " + str(data.base_shield)
	
	for child in common_grid.get_children(): 
		child.queue_free()

	# IF LOCKED: Maybe hide cards or show them as "???"	
	var all_cards = []
	if data.unique_card:
		all_cards.append(data.unique_card)
	all_cards.append_array(data.common_cards)

	for card_data in all_cards:
		var row = HBoxContainer.new()
		row.custom_minimum_size.y = 150
		row.add_theme_constant_override("separation", 15)
		common_grid.add_child(row)
		
		var c_card = card_ui_scene.instantiate()
		row.add_child(c_card)
		c_card.setup(card_data)
		
		c_card.is_playable = false
		
		if c_card.has_method("toggle_info_capability"):
			c_card.toggle_info_capability(false)
			
		var play_btn = c_card.get_node_or_null("Visuals/VBoxContainer/PlayButton")
		if play_btn:
			play_btn.hide()
		
		var desc_label = Label.new()
		# Only show description if unlocked? 
		desc_label.text = card_data.description 
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.custom_minimum_size.x = 320 
		desc_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		
		var c_name = card_data.card_name.to_upper()
		var c_desc = card_data.description

		if card_data == data.unique_card:
			desc_label.modulate = Color(0.973, 0.82, 0.0, 1.0)
			desc_label.text = "[SIGNATURE]\n" + c_name + ":" + "\n" + c_desc
		else:
			desc_label.modulate = Color(0.535, 0.899, 0.935, 1.0)
			desc_label.text = "[COMMON CARD]\n" + c_name + ":" + "\n" + c_desc
		row.add_child(desc_label)
		
		var mana_lbl = c_card.get_node_or_null("Visuals/VBoxContainer/ManaLabel")
		if mana_lbl:
			mana_lbl.hide()

func _on_upgrades_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/CharacterUpgradeUI.tscn")
