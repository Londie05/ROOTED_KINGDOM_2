extends Node

var player_name: String = ""
const SAVE_PATH = "user://player_data.save"

var button_click_sfx = preload("res://Asset/Sound effects/button_effects.mp3")
var sfx_player: AudioStreamPlayer

# --- PROGRESSION VARIABLES ---
var current_tower_floor: int = 1
var floors_cleared: Array = []
var selected_team: Array[CharacterData] = []
var player_team: Array = []

var upgrade_materials: int = 500
var small_gems: int = 5000
var crystal_gems: int = 100

var unlocked_heroes: Array[String] = ["Hero"]
var from_tower_mode: bool = false

# Dictionaries for levels
var card_levels: Dictionary = {} 
var character_levels: Dictionary = {}
var roaster_list: Array = []

var loading_target_scene: String = ""

var floor_rewards = {
	1: { "small": 100, "crystal": 0 },
	2: { "small": 150, "crystal": 0 },
	3: { "small": 200, "crystal": 1 },
	4: { "small": 250, "crystal": 1 },
	5: { "small": 500, "crystal": 1 },
	6: { "small": 100, "crystal": 1 },
	7: { "small": 150, "crystal": 1 },
	8: { "small": 200, "crystal": 1 },
	9: { "small": 250, "crystal": 1 },
	10: { "small": 1000, "crystal": 5 },
}

const HP_GROWTH_PER_LEVEL = 20
const UPGRADE_COST_BASE = 100
const UPGRADE_COST_MULTIPLIER = 1.5

func _ready() -> void:
	setup_audio_node()
	load_game()
	
	get_tree().node_added.connect(_on_node_added)
	connect_buttons_recursive(get_tree().root)


func get_card_damage(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	return data.damage + (data.damage_growth * lvl)

func get_card_shield(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	return data.shield + (data.shield_growth * lvl)

func get_card_heal(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	return data.heal_amount + (data.heal_growth * lvl)

func get_card_mana(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	return data.mana_gain + (data.mana_gain * lvl)
	
func get_card_level_number(data: CardData) -> int:
	return card_levels.get(data.card_name, 0) + 1

func get_character_level(char_name: String) -> int:
	return character_levels.get(char_name, 0)

func get_character_max_hp(data: CharacterData) -> int:
	var lvl = get_character_level(data.name)
	return data.max_health + (lvl * HP_GROWTH_PER_LEVEL)
	
func get_upgrade_cost(char_name: String) -> int:
	var lvl = get_character_level(char_name)
	return int(UPGRADE_COST_BASE * pow(UPGRADE_COST_MULTIPLIER, lvl))

func try_redeem_code(code: String) -> String:
	match code.to_upper(): 
		"RICH":
			small_gems += 9999
			crystal_gems += 99
			save_game()
			return "Success! +9999 Gems\n+99 Crystals"
		"POOR":
			small_gems = 0
			crystal_gems = 0
			save_game()
			return "Wallet Empty..."
		"RESET":
			reset_player_data()
			return "Save File Deleted."
		_:
			return "Invalid Code"
			
# --- ACTION LOGIC ---

func attempt_upgrade(data: CardData) -> bool:
	if small_gems >= data.upgrade_cost:
		small_gems -= data.upgrade_cost
		
		if not card_levels.has(data.card_name):
			card_levels[data.card_name] = 0
		
		card_levels[data.card_name] += 1
		
		print("Card Upgrade Successful! Saved.")
		save_game()
		return true
	else:
		return false

func upgrade_character(data: CharacterData) -> bool:
	var cost = get_upgrade_cost(data.name)
	
	if small_gems >= cost:
		small_gems -= cost
		
		if not character_levels.has(data.name):
			character_levels[data.name] = 0
		character_levels[data.name] += 1
		
		var all_cards = []
		if data.unique_card: all_cards.append(data.unique_card)
		all_cards.append_array(data.common_cards)
		
		for card in all_cards:
			if not card_levels.has(card.card_name):
				card_levels[card.card_name] = 0
			card_levels[card.card_name] += 1
			
		save_game()
		print("Character Upgrade Successful!")
		return true
	else:
		return false

# --- SYSTEM (SAVE/LOAD) ---
func save_game():
	var config = ConfigFile.new()
	
	config.set_value("Progression", "character_levels", character_levels)
	config.set_value("Progression", "player_name", player_name)
	config.set_value("Progression", "small_gems", small_gems)
	config.set_value("Progression", "crystal_gems", crystal_gems)
	config.set_value("Progression", "unlocked_heroes", unlocked_heroes)
	config.set_value("Progression", "current_floor", current_tower_floor)
	config.set_value("Progression", "card_levels", card_levels)
	config.set_value("Progression", "floors_cleared", floors_cleared)
	
	var err = config.save(SAVE_PATH)
	if err == OK:
		print("Game Saved!")
	else:
		print("Error saving game.")
	
func load_game():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err != OK: return
	
	character_levels = config.get_value("Progression", "character_levels", {})
	player_name = config.get_value("Progression", "player_name", "")
	small_gems = config.get_value("Progression", "small_gems", 5000)
	crystal_gems = config.get_value("Progression", "crystal_gems", 100)
	unlocked_heroes = config.get_value("Progression", "unlocked_heroes", ["Hero"])
	current_tower_floor = config.get_value("Progression", "current_floor", 1)
	card_levels = config.get_value("Progression", "card_levels", {})
	floors_cleared = config.get_value("Progression", "floors_cleared", [])
	
func reset_player_data():
	player_name = ""
	small_gems = 5000
	crystal_gems = 100
	unlocked_heroes = ["Hero"]
	card_levels = {}
	character_levels = {}
	current_tower_floor = 1
	floors_cleared = []
	
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)

# --- TEAM ---
func add_to_team(data: CharacterData):
	selected_team.append(data)
		
func clear_team():
	selected_team.clear()

func unlock_hero(hero_name: String):
	if not unlocked_heroes.has(hero_name):
		unlocked_heroes.append(hero_name)
		save_game()

func is_hero_unlocked(hero_name: String) -> bool:
	return unlocked_heroes.has(hero_name)

# --- AUDIO ---
func setup_audio_node():
	sfx_player = AudioStreamPlayer.new()
	add_child(sfx_player)
	if AudioServer.get_bus_index("SFX") != -1:
		sfx_player.bus = "SFX"
	else:
		sfx_player.bus = "Master"
	
func play_button_sfx():
	if sfx_player and button_click_sfx:
		sfx_player.stream = button_click_sfx
		sfx_player.pitch_scale = randf_range(0.98, 1.02)
		sfx_player.play()
		
func _on_node_added(node: Node):
	if node is BaseButton:
		_connect_button(node)

func connect_buttons_recursive(node: Node):
	if node is BaseButton:
		_connect_button(node)
	for child in node.get_children():
		connect_buttons_recursive(child)
		
func _connect_button(btn: BaseButton):
	if not btn.pressed.is_connected(play_button_sfx):
		btn.pressed.connect(play_button_sfx)
	
	if not btn.button_down.is_connected(_on_button_down.bind(btn)):
		btn.button_down.connect(_on_button_down.bind(btn))
	if not btn.button_up.is_connected(_on_button_up.bind(btn)):
		btn.button_up.connect(_on_button_up.bind(btn))

func _on_button_down(btn: BaseButton):
	btn.set_meta("previous_color", btn.modulate)
	btn.modulate = btn.get_meta("previous_color") * 0.8
	btn.scale = Vector2(0.95, 0.95)
	
func _on_button_up(btn: BaseButton):
	if btn.has_meta("previous_color"):
		btn.modulate = btn.get_meta("previous_color")
	else:
		btn.modulate = Color(1, 1, 1)
	btn.scale = Vector2(1, 1)

func mark_floor_cleared(floor_num: int):
	if not floors_cleared.has(floor_num):
		floors_cleared.append(floor_num)
		print("Floor ", floor_num, " marked as cleared!")
		save_game()
		
func grant_floor_reward(floor_num: int):
	var reward = floor_rewards.get(floor_num, {"small": 0, "crystal": 0})
	small_gems += reward["small"]
	crystal_gems += reward["crystal"]
	print("Granted Reward: ", reward)
	save_game()
