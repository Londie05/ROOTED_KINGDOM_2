extends Control

@onready var loading_bar = $LoadingBar
@onready var status_label = $StatusLabel

var database_path = "res://Resources/GameHeroList.tres"
var next_scene_path = ""

# --- Timer Settings ---
var bar_fill_duration: float = 3.0
var post_load_delay: float = 1.0 
var time_elapsed: float = 0.0
var data_loaded: bool = false

func _ready():
	# 1. Load Master Config
	var accounts_found = Global.load_master_config()
	
	# 2. Determine Destination
	if Global.loading_target_scene != "":
		next_scene_path = Global.loading_target_scene
		Global.loading_target_scene = "" 
	else:
		if not accounts_found or Global.all_accounts.is_empty():
			next_scene_path = "res://Scene/User Interfaces/UI scenes/NameEntry.tscn"
		else:
			next_scene_path = "res://Scene/User Interfaces/UI scenes/AccountSelection.tscn"
	
	# 3. Start Loading
	ResourceLoader.load_threaded_request(database_path)
	ResourceLoader.load_threaded_request(next_scene_path)
	loading_bar.value = 0

func _process(delta):
	time_elapsed += delta
	var time_ratio = clamp(time_elapsed / bar_fill_duration, 0.0, 1.0)
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(database_path, progress)
	var data_ratio = progress[0] if progress.size() > 0 else 0.0
	
	loading_bar.value = min(time_ratio, data_ratio) * 100

	_update_loading_text()

	if status == ResourceLoader.THREAD_LOAD_LOADED and not data_loaded:
		if ResourceLoader.load_threaded_get_status(next_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
			data_loaded = true 
	
	if data_loaded and time_elapsed >= (bar_fill_duration + post_load_delay):
		complete_loading()

# --- TEXT LOGIC ---
func _update_loading_text():
	if next_scene_path.contains("battlefield") or next_scene_path.contains("Story_mode_battle"):
		_update_battle_text()
	
	elif next_scene_path.contains("Chapter2"):
		status_label.text = "Entering Chapter 2..."
	elif next_scene_path.contains("StoryMode.tscn"):
		status_label.text = "Returning to Chapter Selection..."
	elif next_scene_path.contains("Chapter_"):
		status_label.text = "Redirecting to Chapter " + str(Global._CURRENTLY_PLAYING_CHAPTER) + "..."
	elif next_scene_path.contains("Stage_Scene_1-1"):
		status_label.text = "Loading Stage 1-1..."
	elif next_scene_path.contains("NameEntry"):
		_update_name_entry_text()
	elif next_scene_path.contains("AccountSelection"):
		status_label.text = "Loading Account Records..."
	else:
		if Global.player_name != "":
			status_label.text = "Welcome, " + str(Global.player_name) + "!"
		else:
			status_label.text = "Loading Game Resources..."

# Restoration of the missing helper functions
func _update_battle_text():
	# Creates a cycling "..." animation
	var dots = "".repeat(int(time_elapsed * 2.0) % 4)
	status_label.text = "Preparing for Battle" + dots

func _update_name_entry_text():
	if Global.is_renaming_mode:
		status_label.text = "Preparing Profile Rename..."
	else:
		if time_elapsed < 1.5:
			status_label.text = "Initializing System..."
		else:
			status_label.text = "Awaiting Hero Registration..."
			
func complete_loading():
	var loaded_db = ResourceLoader.load_threaded_get(database_path)
	if loaded_db:
		Global.roaster_list.assign(loaded_db.all_heroes)
	
	var packed_scene = ResourceLoader.load_threaded_get(next_scene_path)
	if packed_scene:
		get_tree().change_scene_to_packed(packed_scene)
