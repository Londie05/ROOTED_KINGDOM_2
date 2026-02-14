extends Control

@onready var small_gem_label = $CurrenciesBackground/MarginContainer/HBoxContainer/SmallGemHolder/SmallGemLabel
@onready var crystal_label = $CurrenciesBackground/MarginContainer/HBoxContainer/CrystalGemHolder/CrystalLabel

# --- CONFIGURATION ---
@export var all_available_heroes: Array[CharacterData] = []
@export var card_ui_scene: PackedScene = preload("res://Scene/CardUI.tscn")

# --- UI REFERENCES ---
@onready var hero_hbox = $SelectionScroll/HeroHBox
@onready var upgrade_panel = $UpgradePanel
@onready var char_preview = $UpgradePanel/HBoxContainer/StatsVBox/CharPreview
@onready var name_label = $UpgradePanel/HBoxContainer/StatsVBox/NameLabel
@onready var hp_label = $UpgradePanel/HBoxContainer/StatsVBox/HPUpgradeLabel
@onready var card_hbox = $UpgradePanel/HBoxContainer/CardsVBox/CardScroll/CardHBox

# --- CARDS ---
@onready var card_name_lbl = $UpgradePanel/HBoxContainer/CardsVBox/CardDetailVBox/CardNameLabel
@onready var card_stats_lbl = $UpgradePanel/HBoxContainer/CardsVBox/CardDetailVBox/CardDmgLabel # Renamed variable for clarity

@onready var cards_vbox = $UpgradePanel/HBoxContainer/CardsVBox
@onready var show_cards_btn = $UpgradePanel/HBoxContainer/StatsVBox/ShowCards
@onready var upgrade_panel_node = $UpgradePanel

var collapsed_width: float = 305.0
var expanded_width: float = 640.0

var selected_hero: CharacterData = null
var selected_card: CardData = null

func _ready() -> void:
	cards_vbox.hide()
	upgrade_panel_node.size.x = collapsed_width
	show_cards_btn.text = "Show Cards"
	
	# Connect Buttons
	$BackButton.pressed.connect(func(): get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/main_menu.tscn"))
	show_cards_btn.pressed.connect(_on_show_cards_toggled)
	$UpgradePanel/HBoxContainer/StatsVBox/UpgradeCharButton.pressed.connect(_on_upgrade_char_pressed)
	$UpgradePanel/HBoxContainer/CardsVBox/CardDetailVBox/UpgradeCardButton.pressed.connect(_on_upgrade_card_pressed)
	
	populate_hero_list()
	update_currency_display()

func _on_show_cards_toggled():
	if cards_vbox.visible:
		# Collapse the UI
		cards_vbox.hide()
		upgrade_panel_node.size.x = collapsed_width
		show_cards_btn.text = "Show Cards"
	else:
		# Expand the UI
		cards_vbox.show()
		upgrade_panel_node.size.x = expanded_width
		show_cards_btn.text = "Hide Cards"
		
		if selected_hero:
			load_hero_cards(selected_hero)
			
func populate_hero_list():
	for child in hero_hbox.get_children():
		child.queue_free()
		
	if all_available_heroes.size() == 0:
		print("DEBUG: No heroes found in the Inspector array!")
		return

	for hero in all_available_heroes:
		var btn = TextureButton.new()
		
		if hero.character_illustration:
			btn.texture_normal = hero.character_illustration
		else:
			btn.texture_normal = preload("res://Asset/Characters/Arlene/Arlene.jpg")
			
		btn.ignore_texture_size = true
		btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
		btn.custom_minimum_size = Vector2(120, 120)
		
		var is_actually_locked = hero.is_locked and not Global.is_hero_unlocked(hero.name)
		
		if is_actually_locked:
			btn.modulate = Color(0.2, 0.2, 0.2)
			btn.disabled = true
		else:
			btn.modulate = Color(1, 1, 1)
			btn.disabled = false
			btn.pressed.connect(_on_hero_selected.bind(hero))
		
		hero_hbox.add_child(btn)

func _on_hero_selected(hero: CharacterData):
	selected_hero = hero
	upgrade_panel.show()
	
	# Reset card view state
	cards_vbox.hide()
	upgrade_panel_node.size.x = collapsed_width
	show_cards_btn.text = "Show Cards"
	
	char_preview.texture = hero.character_illustration
	name_label.text = hero.name
	
	update_hero_stats_ui()

func update_hero_stats_ui():
	var cur_lvl = Global.get_character_level(selected_hero.name)
	var cur_hp = Global.get_character_max_hp(selected_hero)
	var next_hp = cur_hp + Global.HP_GROWTH_PER_LEVEL
	
	$UpgradePanel/HBoxContainer/StatsVBox/LevelLabel.text = "Level: " + str(cur_lvl)
	hp_label.text = "HP: " + str(cur_hp) + " -> " + str(next_hp)
	
	var cost = Global.get_upgrade_cost(selected_hero.name)
	$UpgradePanel/HBoxContainer/StatsVBox/UpgradeCharButton.text = "Upgrade (" + str(cost) + " Crystals)"

func load_hero_cards(hero: CharacterData):
	for child in card_hbox.get_children():
		child.queue_free()
	
	var deck = []
	if hero.unique_card: deck.append(hero.unique_card)
	deck.append_array(hero.common_cards)
	
	for card in deck:
		var card_node = card_ui_scene.instantiate()
		card_hbox.add_child(card_node)
		card_node.setup(card)
		
		card_node.allow_hover = false
		card_node.allow_inspect = false 
		card_node.is_playable = true 
		
		var mana_lbl = card_node.get_node_or_null("Visuals/VBoxContainer/ManaLabel")
		if mana_lbl: mana_lbl.hide()
			
		if selected_card and selected_card.card_name == card.card_name:
			card_node.modulate = Color(1.5, 1.5, 1.5)
		
		if not card_node.card_clicked.is_connected(_on_card_selected):
			card_node.card_clicked.connect(func(_node): _on_card_selected(card))

func _on_card_selected(card: CardData):
	selected_card = card
	var cur_lvl = Global.get_card_level_number(card) 
	var internal_lvl = Global.card_levels.get(card.card_name, 0) 
	card_name_lbl.text = card.card_name
	$UpgradePanel/HBoxContainer/CardsVBox/CardDetailVBox/CardLvlLabel.text = "Level: " + str(cur_lvl)
	
	# --- DYNAMIC STAT STRING BUILDING ---
	var stats_text = ""
	
	if card.damage > 0:
		var cur_dmg = Global.get_card_damage(card)
		var next_dmg = cur_dmg + card.damage_growth
		stats_text += "Dmg: " + str(cur_dmg) + " -> " + str(next_dmg) + "\n"
		
	if card.shield > 0:
		var cur_shd = Global.get_card_shield(card)
		var next_shd = cur_shd + card.shield_growth
		stats_text += "Shld: " + str(cur_shd) + " -> " + str(next_shd) + "\n"
		
	if card.heal_amount > 0:
		var cur_heal = Global.get_card_heal(card)
		var next_heal = cur_heal + card.heal_growth
		stats_text += "Heal: " + str(cur_heal) + " -> " + str(next_heal) + "\n"
		
	if card.mana_gain > 0:
		var cur_mana = Global.get_card_mana(card)
		var next_mana = card.mana_gain + int((internal_lvl + 1) / 5)
		stats_text += "Mana: " + str(cur_mana) + " -> " + str(next_mana)
	
	card_stats_lbl.text = stats_text
	
	var dynamic_cost = Global.get_card_upgrade_cost(card)
	$UpgradePanel/HBoxContainer/CardsVBox/CardDetailVBox/UpgradeCardButton.text = "Upgrade (" + str(dynamic_cost) + ")"
	
	load_hero_cards(selected_hero)

func update_currency_display():
	small_gem_label.text = "Gem: " + str(Global.small_gems)
	crystal_label.text = "Crystal: " + str(Global.crystal_gems)
	
func _on_upgrade_char_pressed():
	if not selected_hero: return
	
	if Global.upgrade_character(selected_hero):
		update_hero_stats_ui()
		update_currency_display()
		
		if selected_card:
			_on_card_selected(selected_card)
		
		load_hero_cards(selected_hero)
		print("Hero Upgraded!")
	else:
		# --- CHANGED: Update error message ---
		print("Not enough Crystals for Hero Upgrade!")
		
func _on_upgrade_card_pressed():
	if not selected_card: return
	
	if Global.attempt_upgrade(selected_card):
		_on_card_selected(selected_card)
		update_currency_display()
		load_hero_cards(selected_hero)
		print("Card Upgraded!")
	else:
		print("Not enough Gems for Card Upgrade!")
		
func _on_cancel_pressed() -> void:
	upgrade_panel.hide()

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn")
