extends Control

@onready var loading_bar = $LoadingBar
@onready var status_label = $StatusLabel

var database_path = "res://Resources/GameHeroList.tres"
var next_scene_path = ""

# --- Timer Settings ---
var bar_fill_duration: float = 3.0
var post_load_delay: float = 2.0
var time_elapsed: float = 0.0
var data_loaded: bool = false

func _ready():
	if Global.loading_target_scene != "":
		next_scene_path = Global.loading_target_scene
		Global.loading_target_scene = "" 
	else:
		if Global.player_name == "" or not FileAccess.file_exists(Global.SAVE_PATH):
			next_scene_path = "res://Scene/User Interfaces/UI scenes/NameEntry.tscn"
		else:
			next_scene_path = "res://Scene/User Interfaces/UI scenes/main_menu.tscn"
	
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

	# --- DYNAMIC TEXT BASED ON DESTINATION ---
	if next_scene_path.contains("battlefield") or  next_scene_path.contains("Story_Mode_battle"):
		_update_battle_text()
	elif Global.player_name == "":
		_update_new_player_text()
	else:
		_update_returning_player_text()

	if status == ResourceLoader.THREAD_LOAD_LOADED and not data_loaded:
		if ResourceLoader.load_threaded_get_status(next_scene_path) == ResourceLoader.THREAD_LOAD_LOADED:
			data_loaded = true 
	
	if data_loaded and time_elapsed >= (bar_fill_duration + post_load_delay):
		complete_loading()

# --- Helper Functions for Text ---
func _update_battle_text():
	if time_elapsed < 1.5:
		status_label.text = "Preparing for Battle."
	elif time_elapsed < bar_fill_duration:
		status_label.text = "Preparing for Battle.."
	else:
		status_label.text = "Preparing for Battle..."

func _update_new_player_text():
	if time_elapsed < 1.5:
		status_label.text = "Initializing Data..."
	else:
		status_label.text = "Preparing Character Registration..."

func _update_returning_player_text():
	if time_elapsed < 1.2:
		status_label.text = "Welcome, " + str(Global.player_name) + "!"
	else:
		status_label.text = "Preparing Main Menu..."

func complete_loading():
	var loaded_db = ResourceLoader.load_threaded_get(database_path)
	if loaded_db:
		Global.roaster_list.assign(loaded_db.all_heroes)
	
	var packed_scene = ResourceLoader.load_threaded_get(next_scene_path)
	if packed_scene:
		get_tree().change_scene_to_packed(packed_scene)
