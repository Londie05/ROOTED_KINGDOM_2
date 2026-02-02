extends Control

@onready var loading_bar = $LoadingBar
@onready var status_label = $StatusLabel

var database_path = "res://Resources/GameHeroList.tres"
var next_scene_path = ""

# --- Timer Settings ---
var bar_fill_duration: float = 3.0    # Time it takes for the bar to reach 100%
var post_load_delay: float = 2.0      # How long to wait at 100% before switching
var time_elapsed: float = 0.0
var data_loaded: bool = false

func _ready():
	# 1. Determine destination
	if Global.player_name == "" or not FileAccess.file_exists(Global.SAVE_PATH):
		next_scene_path = "res://Scene/User Interfaces/UI scenes/NameEntry.tscn"
	else:
		next_scene_path = "res://Scene/User Interfaces/UI scenes/main_menu.tscn"
	
	# 2. Start background loading
	ResourceLoader.load_threaded_request(database_path)
	ResourceLoader.load_threaded_request(next_scene_path)
	
	loading_bar.value = 0
	status_label.text = "Loading Resources..."

func _process(delta):
	time_elapsed += delta
	
	# --- REALISTIC BAR MOVEMENT ---
	# We use bar_fill_duration for the ratio so it hits 100% at 3 seconds
	var time_ratio = clamp(time_elapsed / bar_fill_duration, 0.0, 1.0)
	
	var progress = []
	var status = ResourceLoader.load_threaded_get_status(database_path, progress)
	var data_ratio = progress[0] if progress.size() > 0 else 0.0
	
	# Bar moves but stays clamped at 100% after 3 seconds
	var display_value = min(time_ratio, data_ratio)
	loading_bar.value = display_value * 100

	# --- DYNAMIC STATUS TEXT SEQUENCE ---
	if Global.player_name == "":
		# NEW PLAYER FLOW
		if time_elapsed < 1.5:
			status_label.text = "Initializing Data..."
		elif time_elapsed < bar_fill_duration:
			status_label.text = "Preparing Character Registration..."
		else:
			# This shows during the 2-second "post-load" wait
			status_label.text = "Going to Character Registration..."
	else:
		# RETURNING PLAYER FLOW
		if time_elapsed < 1.2:
			status_label.text = "Welcome, " + str(Global.player_name) + "!"
		elif time_elapsed < bar_fill_duration:
			status_label.text = "Syncing Data..."
		else:
			# This triggers once the bar is full and stays for the 2-second wait
			status_label.text = "Preparing Main Menu..."

	# --- CHECK DATA COMPLETION ---
	if status == ResourceLoader.THREAD_LOAD_LOADED and not data_loaded:
		var scene_status = ResourceLoader.load_threaded_get_status(next_scene_path)
		if scene_status == ResourceLoader.THREAD_LOAD_LOADED:
			data_loaded = true 
	
	# --- FINAL TRANSITION ---
	# Now we wait for (bar_fill_duration + post_load_delay) which is 5.0 seconds total
	if data_loaded and time_elapsed >= (bar_fill_duration + post_load_delay):
		complete_loading()

func complete_loading():
	var loaded_db = ResourceLoader.load_threaded_get(database_path)
	if loaded_db:
		Global.roaster_list.assign(loaded_db.all_heroes)
	
	var packed_scene = ResourceLoader.load_threaded_get(next_scene_path)
	if packed_scene:
		get_tree().change_scene_to_packed(packed_scene)
