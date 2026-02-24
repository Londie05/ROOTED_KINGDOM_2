extends CanvasLayer

@onready var title_label = $Panel/VBoxContainer/Title
@onready var action_btn = $Panel/VBoxContainer/ActionButton
@onready var quit_btn = $Panel/VBoxContainer/QuitButton
@onready var reward_label = $Panel/VBoxContainer/RewardLabel

@onready var action_btn_label = $Panel/VBoxContainer/ActionButton/Label
@onready var volume_slider = $"Panel/VBoxContainer/Volume/Volume Slider"
@onready var mute_button = $Panel/VBoxContainer/HBoxContainer/MuteButton
@onready var fullscreen_check = $"Panel/VBoxContainer/HBoxContainer/Fullscreen Check"
@onready var volume_label = $"Panel/VBoxContainer/Volume/Volume Label"

const GEM_ICON_PATH = "res://Asset/Backgrounds/gem_1.webp"
const CRYSTAL_ICON_PATH = "res://Asset/Backgrounds/gem_3.webp"

func _ready():
	hide()
	
	volume_slider.visible = true
	mute_button.visible = true
	fullscreen_check.visible = true
	volume_label.visible = true
	
	if mute_button:
		if not mute_button.pressed.is_connected(_on_mute_button_pressed):
			mute_button.pressed.connect(_on_mute_button_pressed)
			
	if volume_slider:
		volume_slider.value = Global.master_volume
		if not volume_slider.value_changed.is_connected(_on_volume_slider_value_changed):
			volume_slider.value_changed.connect(_on_volume_slider_value_changed)
			
	if fullscreen_check:
		fullscreen_check.button_pressed = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		if not fullscreen_check.toggled.is_connected(_on_fullscreen_check_toggled):
			fullscreen_check.toggled.connect(_on_fullscreen_check_toggled)

# --- CALL THIS WHENEVER THE MENU SHOWS ---
func refresh_audio_ui():
	update_mute_button_visuals()
	if volume_slider:
		volume_slider.value = Global.master_volume

func show_pause_menu():
	title_label.text = "PAUSED"
	title_label.show()
	reward_label.hide()
	action_btn_label.text = "Resume"
	refresh_audio_ui() 
	show()
	get_tree().paused = true

func show_victory_menu():
	volume_slider.visible = false
	mute_button.visible = false
	fullscreen_check.visible = false
	volume_label.visible = false
	
	title_label.text = "VICTORY!"
	title_label.show()
	
	if Global.from_tower_mode:
		action_btn_label.text = "Next Floor"
		var reward = Global.floor_rewards.get(Global.current_tower_floor, {"small": 0, "crystal": 0})
		Global.grant_floor_reward(Global.current_tower_floor)
		Global.mark_floor_cleared(Global.current_tower_floor)

		reward_label.show()
		reward_label.bbcode_enabled = true
		var txt = "[center]Rewards:[/center]\n[center]"
		if reward["small"] > 0:
			txt += "[img=30]%s[/img] +%d  " % [GEM_ICON_PATH, reward["small"]]
		if reward["crystal"] > 0:
			txt += "[img=30]%s[/img] +%d" % [CRYSTAL_ICON_PATH, reward["crystal"]]
		txt += "[/center]"
		reward_label.text = txt

	refresh_audio_ui() 
	show()
	get_tree().paused = true

func show_loss_menu():
	title_label.text = "YOU LOST"
	title_label.show()
	reward_label.hide()
	action_btn_label.text = "Try Again"
	volume_slider.visible = false
	mute_button.visible = false
	fullscreen_check.visible = false
	volume_label.visible = false
	
	refresh_audio_ui() 
	show()
	get_tree().paused = true

func _on_mute_button_pressed():
	Global.toggle_mute()
	update_mute_button_visuals()

func update_mute_button_visuals():
	if Global.is_muted:
		mute_button.text = "Unmute"
		mute_button.modulate = Color(1, 1, 1) # Keep toggle bright
		
		if volume_slider:
			volume_slider.editable = false
			volume_slider.modulate = Color(0.5, 0.5, 0.5, 0.4) # Ghosted out
	else:
		mute_button.text = "Mute All"
		mute_button.modulate = Color(1, 1, 1)
		
		if volume_slider:
			volume_slider.editable = true
			volume_slider.modulate = Color(1, 1, 1, 1)

func _on_volume_slider_value_changed(value: float):
	Global.master_volume = value
	Global.apply_master_volume(value)
	Global.save_game()

func _on_fullscreen_check_toggled(toggled_on: bool):
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1280, 720))

func _on_action_button_pressed():
	if action_btn_label.text == "Next Floor":
		
		volume_slider.visible = true
		mute_button.visible = true
		fullscreen_check.visible = true
		volume_label.visible = true
		get_tree().paused = false 
		Global.current_tower_floor += 1
		hide()
		if Global.current_tower_floor <= 20:
			get_tree().reload_current_scene()
		else:
			get_tree().change_scene_to_file("res://Scene/TowerSelection.tscn")
			
	elif action_btn_label.text == "Try Again":
		get_tree().paused = false 
		hide()
		get_tree().reload_current_scene()
	else:
		get_tree().paused = false 
		hide()

func _on_quit_button_pressed():
	get_tree().paused = false
	if Global.from_tower_mode:
		get_tree().change_scene_to_file("res://Scene/TowerSelection.tscn")
		hide()
