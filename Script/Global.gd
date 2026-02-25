extends Node

enum GameMode { TOWER, STORY }
var current_game_mode: GameMode = GameMode.TOWER

# var _CURRENTLY_PLAYING_CHAPTER: int = 1

var last_story_scene_path: String = ""
var story_line_resume_index: int = 0
var just_finished_battle: bool = false
var current_battle_stage: String = ""

# Background music
var bgm_player: AudioStreamPlayer
var current_bgm_track_name: String = "Music 1" # Default
var master_volume: float = 1.0
var is_muted: bool = false

# Account Management
var all_accounts: Dictionary = {} # Stores { "unique_id": "Player Name" }
var current_account_id: String = ""
var is_renaming_mode: bool = false 
const MASTER_SAVE_PATH = "user://master_config.save"

# --- MUSIC TRACKS ---
var bgm_tracks: Dictionary = {
	"Music 1": "res://Asset/Backgrounds/Story Mode/bgMusic2.ogg",
	"Music 2": "res://Asset/Backgrounds/Story Mode/bgMusic.ogg",
	"Music 3": "res://Asset/Backgrounds/Story Mode/music3.mp3",
	"Music 4": "res://Asset/Backgrounds/Story Mode/music4.mp3",
	"None": ""
}

# --- ALLOWED SCENES ---
var allowed_bgm_scenes: Array[String] = [
	"Settings",      
	"CharacterSelection", 
	"MainMenu",           
	"Start_Battle",     
	"TowerSelection",
	"CharacterUpgradeUi",
	"Tutorial",
	"Chapter_Selection",
	"NameEntry",
	"AccountSelection",
	"StoryMode",
	"EndlessMode"
]

# For backgrounds
var current_bg_name: String = "Default"
signal background_changed(bg_name: String)

# Save data
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
var small_gems: int = 50000
var crystal_gems: int = 5000

var unlocked_heroes: Array[String] = ["Hero"]
var from_tower_mode: bool = false

# Tower Variable but I placed it
var current_tower_unlocked = ""


# Dictionaries for levels
var card_levels: Dictionary = {} 
var character_levels: Dictionary = {}
var roaster_list: Array = []

var loading_target_scene: String = ""

var floor_rewards = {
	1: { "small": 100, "crystal": 5 },
	2: { "small": 150, "crystal": 5 },
	3: { "small": 200, "crystal": 5 },
	4: { "small": 250, "crystal": 5 },
	5: { "small": 500, "crystal": 5 },
	6: { "small": 100, "crystal": 5 },
	7: { "small": 150, "crystal": 5 },
	8: { "small": 200, "crystal": 5 },
	9: { "small": 250, "crystal": 5 },
	10: { "small": 300, "crystal": 5 },
	11: { "small": 350, "crystal": 10 },
	12: { "small": 400, "crystal": 10 },
	13: { "small": 450, "crystal": 10 },
	14: { "small": 500, "crystal": 10 },
	15: { "small": 550, "crystal": 10 },
	16: { "small": 600, "crystal": 10 },
	17: { "small": 650, "crystal": 10 },
	18: { "small": 700, "crystal": 10 },
	19: { "small": 750, "crystal": 15 },
	20: { "small": 1500, "crystal": 30 },
}

const HP_GROWTH_PER_LEVEL = 5

const UPGRADE_COST_BASE = 2 
const UPGRADE_COST_MULTIPLIER = 1.2

func _ready() -> void:
	setup_audio_node()
	
	bgm_player = AudioStreamPlayer.new()
	add_child(bgm_player)
	bgm_player.bus = "Master" 
	
	load_game() 
	
	get_tree().node_added.connect(_on_node_added)
	
	get_tree().tree_changed.connect(_on_scene_changed)
	connect_buttons_recursive(get_tree().root)
	apply_master_volume(master_volume)

	await get_tree().process_frame
	if get_tree().current_scene:
		check_and_play_bgm(get_tree().current_scene.name)

func get_current_save_path() -> String:
	if current_account_id == "":
		return "user://temp_data.save" # Fallback
	return "user://acc_" + current_account_id + ".save"

func save_master_config():
	var config = ConfigFile.new()
	config.set_value("Accounts", "list", all_accounts)
	config.set_value("Accounts", "last_played_id", current_account_id)
	config.save(MASTER_SAVE_PATH)
	
func load_master_config() -> bool:
	var config = ConfigFile.new()
	if config.load(MASTER_SAVE_PATH) != OK:
		return false
	
	all_accounts = config.get_value("Accounts", "list", {})
	var last_id = config.get_value("Accounts", "last_played_id", "")
	
	if current_account_id == "" and last_id != "":
		current_account_id = last_id
		load_game()
		return true
		
	return !all_accounts.is_empty()
	
func delete_account_data(target_acc_id: String) -> void:
	# Remove from the Dictionary
	if all_accounts.has(target_acc_id):
		all_accounts.erase(target_acc_id)
	
	# Delete the actual save file
	var file_path = "user://acc_" + target_acc_id + ".save"
	if FileAccess.file_exists(file_path):
		DirAccess.remove_absolute(file_path)
		print("Deleted save file: " + file_path)
	
	# Update the Master Config so the game forgets this account exists
	save_master_config()
	
func logout():
	current_account_id = ""
	player_name = ""
	# Reset other temporary gameplay data here if needed
	reset_player_data()
	
	# We update the master config so it doesn't try to auto-resume the old ID
	var config = ConfigFile.new()
	if config.load(MASTER_SAVE_PATH) == OK:
		config.set_value("Accounts", "last_played_id", "") 
		config.save(MASTER_SAVE_PATH)
		
func prepare_new_account_creation():
	# 1. Reset all game variables to default
	reset_player_data()
	
	# 2. Generate a unique ID (Timestamp + Random Number)
	current_account_id = str(Time.get_unix_time_from_system()) + "_" + str(randi() % 1000)
	
	# 3. Set flag so NameEntry knows we are new
	is_renaming_mode = false
	
func complete_account_creation(new_name: String):
	player_name = new_name
	
	# Register in the master list
	all_accounts[current_account_id] = new_name
	
	save_game() # Creates the user://acc_[id].save file
	save_master_config() # Updates the list of accounts
	
func complete_rename(new_name: String):
	player_name = new_name
	
	# Update the name in the master list
	if all_accounts.has(current_account_id):
		all_accounts[current_account_id] = new_name
		
	save_game()
	save_master_config()
	is_renaming_mode = false
func toggle_mute():
	is_muted = !is_muted
	apply_master_volume(master_volume) 
	save_game()
	
func set_background(bg_name: String):
	current_bg_name = bg_name
	emit_signal("background_changed", bg_name)
	save_game()
		
func _on_scene_changed():
	var tree = get_tree()
	if not tree: 
		return
	
	await tree.process_frame
	
	if not is_inside_tree() or get_tree() == null: 
		return

	var current_scene = get_tree().current_scene
	if current_scene:
		check_and_play_bgm(current_scene.name)

func check_and_play_bgm(scene_name: String):
	if scene_name in allowed_bgm_scenes:
		play_selected_bgm()
	else:
		bgm_player.stop()

func play_selected_bgm():
	if current_bgm_track_name == "None" or current_bgm_track_name == "":
		if bgm_player:
			bgm_player.stop()
		return
	
	var track_path = bgm_tracks.get(current_bgm_track_name, "")
	if track_path == "":
		if bgm_player:
			bgm_player.stop()
		return
		
	if bgm_player.playing and bgm_player.stream:
		if bgm_player.stream.resource_path == track_path:
			return
		
	var stream = load(track_path)
	if stream:
		if stream is AudioStreamMP3 or stream is AudioStreamOggVorbis:
			stream.loop = true 
			
		bgm_player.stream = stream
		bgm_player.play()
		
func set_bgm_preference(track_name: String):
	current_bgm_track_name = track_name
	save_game()
	
	# Re-check immediately
	if get_tree().current_scene:
		check_and_play_bgm(get_tree().current_scene.name)

# --- CARD STAT CALCULATIONS ---
func get_card_upgrade_cost(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	var steps = int(lvl / 5)
	var multiplier = pow(2, steps)
	return int(data.upgrade_cost * multiplier)

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
	var extra_mana = int(lvl / 5) 
	return data.mana_gain + extra_mana
	
func get_card_level_number(data: CardData) -> int:
	return card_levels.get(data.card_name, 0) + 1

# --- CHARACTER STAT CALCULATIONS ---
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
			small_gems += 9999999999999
			crystal_gems += 9999999999
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
	var dynamic_cost = get_card_upgrade_cost(data)
	if small_gems >= dynamic_cost:
		small_gems -= dynamic_cost
		if not card_levels.has(data.card_name):
			card_levels[data.card_name] = 0
		card_levels[data.card_name] += 1
		save_game()
		return true
	else:
		return false

func upgrade_character(data: CharacterData) -> bool:
	var cost = get_upgrade_cost(data.name)
	if crystal_gems >= cost:
		crystal_gems -= cost
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
		return true
	else:
		return false

# --- SYSTEM (SAVE/LOAD) ---
func save_game():
	if current_account_id == "": return
		
	var config = ConfigFile.new()
	config.set_value("Progression", "character_levels", character_levels)
	config.set_value("Progression", "player_name", player_name)
	config.set_value("Progression", "small_gems", small_gems)
	config.set_value("Progression", "crystal_gems", crystal_gems)
	config.set_value("Progression", "unlocked_heroes", unlocked_heroes)
	config.set_value("Progression", "current_floor", current_tower_floor)
	config.set_value("Progression", "card_levels", card_levels)
	config.set_value("Progression", "floors_cleared", floors_cleared)
	
	
	config.set_value("settings", "bgm_track_name", current_bgm_track_name)
	
	config.set_value("settings", "bg_name", current_bg_name)
	# Saving the Settings
	config.set_value("settings", "master_volume", master_volume)
	config.set_value("settings", "is_muted", is_muted)
	
	var err = config.save(get_current_save_path())
	if err == OK:
		print("Game Saved to: " + get_current_save_path())
		
func load_game():
	if current_account_id == "": return
	
	var config = ConfigFile.new()
	var err = config.load(get_current_save_path())
	if err != OK: return
	
	character_levels = config.get_value("Progression", "character_levels", {})
	player_name = config.get_value("Progression", "player_name", "")
	small_gems = config.get_value("Progression", "small_gems", 5000)
	crystal_gems = config.get_value("Progression", "crystal_gems", 100)
	unlocked_heroes = config.get_value("Progression", "unlocked_heroes", ["Hero"])
	current_tower_floor = config.get_value("Progression", "current_floor", 1)
	card_levels = config.get_value("Progression", "card_levels", {})
	floors_cleared = config.get_value("Progression", "floors_cleared", [])
		
	current_bg_name = config.get_value("settings", "bg_name", current_bg_name)
	
	current_bgm_track_name = config.get_value("settings", "bgm_track_name", current_bgm_track_name)
	
	master_volume = config.get_value("settings", "master_volume", 1.0)
	is_muted = config.get_value("settings", "is_muted", false)
	
	apply_master_volume(master_volume)

func apply_master_volume(value: float):
	var bus_index = AudioServer.get_bus_index("Master")
	
	if is_muted:
		AudioServer.set_bus_mute(bus_index, true)
	else:
		if value > 0:
			var volume_curve = value * value * 2
			AudioServer.set_bus_volume_db(bus_index, linear_to_db(volume_curve))
			AudioServer.set_bus_mute(bus_index, false)
		else:
			AudioServer.set_bus_mute(bus_index, true)
		
func reset_player_data():
	# Resets variables only. Does not delete file.
	player_name = ""
	small_gems = 5000
	crystal_gems = 5000
	unlocked_heroes = ["Hero"]
	card_levels = {}
	character_levels = {}
	current_tower_floor = 1
	floors_cleared = []
	current_bg_name = "Default"
	current_bgm_track_name = "Music 1"


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
	if btn.disabled:
		return 
		
	if btn.has_meta("previous_color"):
		btn.modulate = btn.get_meta("previous_color")
	else:
		btn.modulate = Color(1, 1, 1)
	btn.scale = Vector2(1, 1)

func mark_floor_cleared(floor_num: int):
	if not floors_cleared.has(floor_num):
		floors_cleared.append(floor_num)
		save_game()
		
func grant_floor_reward(floor_num: int):
	if floors_cleared.has(floor_num):
		return
	var reward = floor_rewards.get(floor_num, {"small": 0, "crystal": 0})
	small_gems += reward["small"]
	crystal_gems += reward["crystal"]
	save_game()
