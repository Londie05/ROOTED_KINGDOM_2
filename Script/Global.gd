extends Node

var player_name: String = ""
const SAVE_PATH = "user://player_data.save"

var button_click_sfx = preload("res://Asset/Sound effects/button_effects.mp3")
var sfx_player: AudioStreamPlayer

# --- PROGRESSION VARIABLES ---
# NOTE: Changing these numbers here won't work if a save file already exists!
# You must call reset_player_data() once to see these changes.
var current_tower_floor: int = 1
var floors_cleared: Array = [] 
var selected_team: Array[CharacterData] = []
var player_team: Array = []

var upgrade_materials: int = 500
var card_levels: Dictionary = {}
var small_gems: int = 5000
var crystal_gems: int = 100

var unlocked_heroes: Array[String] = ["Hero"] 

var from_tower_mode: bool = false

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

var character_levels: Dictionary = {} # Stores {"HeroName": 0, "AnotherHero": 2}
# You can adjust these growth numbers to balance your game
const HP_GROWTH_PER_LEVEL = 20 
const UPGRADE_COST_BASE = 100
const UPGRADE_COST_MULTIPLIER = 1.5


func _ready() -> void:
	setup_audio_node()
	
	load_game()
	
	get_tree().node_added.connect(_on_node_added)
	connect_buttons_recursive(get_tree().root)

# --- TEAM MANAGEMENT ---
func add_to_team(data: CharacterData):
	selected_team.append(data)
		
func clear_team():
	selected_team.clear()

# --- REWARD & UNLOCK LOGIC ---
func mark_floor_cleared(floor_num: int):
	if not floors_cleared.has(floor_num):
		floors_cleared.append(floor_num)
		# Only save if we actually added something new
		save_game()
	
func grant_floor_reward(floor_num: int):
	if floor_rewards.has(floor_num):
		var reward = floor_rewards[floor_num]
		small_gems += reward["small"]
		crystal_gems += reward["crystal"]
		print("Victory! Gained: ", reward["small"], " Gems and ", reward["crystal"], " Crystals")
		save_game()

func unlock_hero(hero_name: String):
	if not unlocked_heroes.has(hero_name):
		unlocked_heroes.append(hero_name)
		print("Unlocked new hero: ", hero_name)
		save_game()

func is_hero_unlocked(hero_name: String) -> bool:
	return unlocked_heroes.has(hero_name)

# --- UPGRADE LOGIC ---
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
	
func attempt_upgrade(data: CardData) -> bool:
	if small_gems >= data.upgrade_cost:
		small_gems -= data.upgrade_cost
		
		if not card_levels.has(data.card_name):
			card_levels[data.card_name] = 0
		
		card_levels[data.card_name] += 1
		
		print("Upgrade Successful! Saved.")
		save_game()
		return true
	else:
		print("Not enough Small Gems!")
		return false

func try_redeem_code(code: String) -> String:
	match code:
		"RICH":
			small_gems += 9999
			crystal_gems += 99
			save_game()
			return "Success! +5000 Gems\n+50 Crystals"
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

# --- SAVE SYSTEM ---
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
		print("Game Saved! Name: " + player_name)
	else:
		print("Error saving game.")
	
func load_game():
	var config = ConfigFile.new()
	var err = config.load(SAVE_PATH)
	
	if err != OK: return 
	
	# 1. LOAD THE NAME
	character_levels = config.get_value("Progression", "character_levels", {})
	player_name = config.get_value("Progression", "player_name", "")
	
	# 2. LOAD THE REST
	small_gems = config.get_value("Progression", "small_gems", 5000)
	crystal_gems = config.get_value("Progression", "crystal_gems", 100)
	unlocked_heroes = config.get_value("Progression", "unlocked_heroes", ["Hero"])
	current_tower_floor = config.get_value("Progression", "current_floor", 1)
	card_levels = config.get_value("Progression", "card_levels", {})
	floors_cleared = config.get_value("Progression", "floors_cleared", [])
	
	print("Loaded Data. Player Name: " + player_name)
	
func reset_player_data():
	player_name = ""
	small_gems = 5000
	crystal_gems = 100
	unlocked_heroes = ["Hero"]
	card_levels = {}
	current_tower_floor = 1
	floors_cleared = []
	character_levels = {}
	
	# Delete the physical file from your computer
	if FileAccess.file_exists(SAVE_PATH):
		DirAccess.remove_absolute(SAVE_PATH)
	print("Data Reset! Restart the game to see fresh defaults.")

# --- AUDIO SYSTEM ---
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
	
	# NEW: Add a visual "shiver" or scale effect when clicked
	if not btn.button_down.is_connected(_on_button_down.bind(btn)):
		btn.button_down.connect(_on_button_down.bind(btn))
	if not btn.button_up.is_connected(_on_button_up.bind(btn)):
		btn.button_up.connect(_on_button_up.bind(btn))
	if not btn.pressed.is_connected(play_button_sfx):
		btn.pressed.connect(play_button_sfx)

func get_player_data_as_dict() -> Dictionary:
	return {
		"player_name": player_name,
		"small_gems": small_gems,
		"crystal_gems": crystal_gems,
		"unlocked_heroes": unlocked_heroes,
		"current_floor": current_tower_floor,
		"card_levels": card_levels
	}

func get_character_level(char_name: String) -> int:
	return character_levels.get(char_name, 0)

func get_character_max_hp(data: CharacterData) -> int:
	var lvl = get_character_level(data.name)
	return data.max_health + (lvl * HP_GROWTH_PER_LEVEL)
	
func get_upgrade_cost(char_name: String) -> int:
	var lvl = get_character_level(char_name)
	# Level 0->1 costs 100, Level 1->2 costs 150, etc.
	return int(UPGRADE_COST_BASE * pow(UPGRADE_COST_MULTIPLIER, lvl))


func upgrade_character(data: CharacterData) -> bool:
	var cost = get_upgrade_cost(data.name)
	
	if small_gems >= cost:
		small_gems -= cost
		
		# 1. Increase Character Level
		if not character_levels.has(data.name):
			character_levels[data.name] = 0
		character_levels[data.name] += 1
		
		# 2. Increase Level of ALL their cards
		# This fulfills your requirement: "Increase effects of cards they hold"
		var all_cards = []
		if data.unique_card: all_cards.append(data.unique_card)
		all_cards.append_array(data.common_cards)
		
		for card in all_cards:
			if not card_levels.has(card.card_name):
				card_levels[card.card_name] = 0
			card_levels[card.card_name] += 1
			
		save_game()
		print("Upgraded " + data.name + " to Level " + str(character_levels[data.name]))
		return true
	else:
		return false

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
	
