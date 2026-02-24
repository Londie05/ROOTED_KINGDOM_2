extends Control

# --- ONREADY VARIABLES ---
@onready var cheat_input = $VBoxContainer/CheatInput
@onready var redeem_btn = $VBoxContainer/RedeemButton
@onready var feedback_lbl = $VBoxContainer/FeedbackLabel

# --- AUDIO & VIDEO ---
@onready var bgm_select = $"User Interface/Options/VBoxContainer/BackgroundSound/BGMSelect"
@onready var volume_slider = $"User Interface/Options/VBoxContainer/Volume/Volume Slider"
@onready var fullscreen_check = $"User Interface/Options/VBoxContainer/HBoxContainer/Fullscreen Check"
@onready var mute_button = $"User Interface/Options/VBoxContainer/HBoxContainer/MuteButton"

# --- BACKGROUNDS ---
@onready var btn_bg_default = $"User Interface/Options/VBoxContainer/BgContainer/Btn_Default"
@onready var btn_bg_dark = $"User Interface/Options/VBoxContainer/BgContainer/Btn_Dark"
@onready var btn_bg_sword = $"User Interface/Options/VBoxContainer/BgContainer/Btn_Sword"
@onready var btn_bg_grass = $"User Interface/Options/VBoxContainer/BgContainer/Btn_Grass"
# --- ACCOUNT MANAGEMENT ---
@onready var create_acc_btn = $"User Interface/Options/VBoxContainer/AccountManagement/CreateAccButton"
@onready var rename_btn = $"User Interface/Options/VBoxContainer/AccountManagement/RenameButton"
@onready var switch_acc_btn =  $"User Interface/Options/VBoxContainer/AccountManagement/SwitchAccButton"


@onready var confirmation_popup = $CustomQuitPopup

func _ready() -> void:
	if redeem_btn and not redeem_btn.pressed.is_connected(_on_redeem_pressed):
		redeem_btn.pressed.connect(_on_redeem_pressed)
	
	var is_full = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	if fullscreen_check:
		fullscreen_check.button_pressed = is_full

	setup_bgm_options()
	if mute_button:
		update_mute_button_visuals()
		if not mute_button.pressed.is_connected(_on_mute_button_pressed):
			mute_button.pressed.connect(_on_mute_button_pressed)

	if volume_slider:
		volume_slider.value = Global.master_volume
		if not volume_slider.value_changed.is_connected(_on_volume_slider_value_changed):
			volume_slider.value_changed.connect(_on_volume_slider_value_changed)

	if btn_bg_default: btn_bg_default.pressed.connect(_on_bg_default_pressed)
	if btn_bg_dark: btn_bg_dark.pressed.connect(_on_bg_dark_pressed)
	if btn_bg_sword: btn_bg_sword.pressed.connect(_on_bg_sword_pressed)
	if btn_bg_grass: btn_bg_grass.pressed.connect(_on_bg_grass_pressed)
	
	if create_acc_btn: create_acc_btn.pressed.connect(_on_create_acc_pressed)
	if rename_btn: rename_btn.pressed.connect(_on_rename_pressed)
	
	if switch_acc_btn:
		if not switch_acc_btn.pressed.is_connected(_on_switch_acc_pressed):
			switch_acc_btn.pressed.connect(_on_switch_acc_pressed)

	if confirmation_popup:
		if not confirmation_popup.confirmed.is_connected(_on_create_acc_confirmed_final):
			confirmation_popup.confirmed.connect(_on_create_acc_confirmed_final)

func _on_switch_acc_pressed():
	Global.save_game()
	
	Global.logout() 
	
	Global.loading_target_scene = "res://Scene/User Interfaces/UI scenes/AccountSelection.tscn"
	
	get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
func _on_rename_pressed():
	Global.is_renaming_mode = true
	
	Global.loading_target_scene = "res://Scene/User Interfaces/UI scenes/NameEntry.tscn"
	
	get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
	
func _on_create_acc_pressed():
	if confirmation_popup:
		confirmation_popup.setup_popup("Create new account? \nThis will log you out.", "Create", "Cancel")
		confirmation_popup.show_popup()
	
func _on_create_acc_confirmed_final():
	# 1. Clear data and generate a new ID in Global
	Global.prepare_new_account_creation()
	
	# 2. Tell the loading screen we are headed to Name Entry
	Global.loading_target_scene = "res://Scene/User Interfaces/UI scenes/NameEntry.tscn"
	
	# 3. Go to the Loading Screen first
	get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
# --- AUDIO LOGIC ---
func _on_mute_button_pressed():
	Global.toggle_mute()
	update_mute_button_visuals()

func update_mute_button_visuals():
	var is_muted = Global.is_muted
	if is_muted:
		mute_button.text = "Unmute"
		if bgm_select:
			bgm_select.disabled = true
			bgm_select.modulate = Color(0.5, 0.5, 0.5, 0.4)
		if volume_slider:
			volume_slider.editable = false
			volume_slider.modulate = Color(0.5, 0.5, 0.5, 0.4)
	else:
		mute_button.text = "Mute All"
		if bgm_select:
			bgm_select.disabled = false
			bgm_select.modulate = Color(1, 1, 1, 1)
		if volume_slider:
			volume_slider.editable = true
			volume_slider.modulate = Color(1, 1, 1, 1)

func setup_bgm_options():
	if not bgm_select: return
	bgm_select.clear()
	var tracks = Global.bgm_tracks.keys()
	for i in range(tracks.size()):
		var track_name = tracks[i]
		bgm_select.add_item(track_name, i)
		if track_name == Global.current_bgm_track_name:
			bgm_select.selected = i
	if not bgm_select.item_selected.is_connected(_on_bgm_selected):
		bgm_select.item_selected.connect(_on_bgm_selected)

func _on_bgm_selected(index: int):
	Global.set_bgm_preference(bgm_select.get_item_text(index))

# --- VOLUME & DISPLAY ---
func _on_volume_slider_value_changed(value: float) -> void:
	Global.master_volume = value
	Global.apply_master_volume(value)
	Global.save_game()
	
func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1280, 720))
		var screen = DisplayServer.window_get_current_screen()
		var screen_rect = DisplayServer.screen_get_usable_rect(screen)
		DisplayServer.window_set_position(screen_rect.position + (screen_rect.size / 2) - (Vector2i(1280, 720) / 2))

# --- BACKGROUND & CHEAT ---
func _on_bg_default_pressed(): Global.set_background("Default")
func _on_bg_dark_pressed(): Global.set_background("Ruins")
func _on_bg_sword_pressed(): Global.set_background("Sword")
func _on_bg_grass_pressed(): Global.set_background("Grass")

func _on_redeem_pressed():
	var code = cheat_input.text.to_upper()
	feedback_lbl.text = Global.try_redeem_code(code)
	cheat_input.text = ""
