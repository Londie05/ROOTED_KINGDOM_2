extends Control

@onready var cheat_input = $VBoxContainer/CheatInput
@onready var redeem_btn = $VBoxContainer/RedeemButton
@onready var feedback_lbl = $VBoxContainer/FeedbackLabel

@onready var bgm_select = $"User Interface/Options/VBoxContainer/BackgroundSound/BGMSelect"
@onready var volume_slider = $"User Interface/Options/VBoxContainer/Volume/Volume Slider"
@onready var fullscreen_check = $"User Interface/Options/VBoxContainer/Fullscreen Check"

@onready var btn_bg_default = $"User Interface/Options/VBoxContainer/BgContainer/Btn_Default"
@onready var btn_bg_dark = $"User Interface/Options/VBoxContainer/BgContainer/Btn_Dark"
@onready var btn_bg_sword = $"User Interface/Options/VBoxContainer/BgContainer/Btn_Sword"

func _ready() -> void:
	if not redeem_btn.pressed.is_connected(_on_redeem_pressed):
		redeem_btn.pressed.connect(_on_redeem_pressed)
	
	var is_full = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	if fullscreen_check:
		fullscreen_check.button_pressed = is_full

	setup_bgm_options()
	
	# --- CONNECT BACKGROUND BUTTONS ---
	if btn_bg_default:
		if not btn_bg_default.pressed.is_connected(_on_bg_default_pressed):
			btn_bg_default.pressed.connect(_on_bg_default_pressed)
			
	if btn_bg_dark:
		if not btn_bg_dark.pressed.is_connected(_on_bg_dark_pressed):
			btn_bg_dark.pressed.connect(_on_bg_dark_pressed)
			
	if btn_bg_sword:
		if not btn_bg_sword.pressed.is_connected(_on_bg_sword_pressed):
			btn_bg_sword.pressed.connect(_on_bg_sword_pressed)
			
	if volume_slider:
		volume_slider.value = Global.master_volume
		if not volume_slider.value_changed.is_connected(_on_volume_slider_value_changed):
			volume_slider.value_changed.connect(_on_volume_slider_value_changed)

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
	var selected_name = bgm_select.get_item_text(index)
	Global.set_bgm_preference(selected_name)

func _on_redeem_pressed():
	var code = cheat_input.text.to_upper()
	var result = Global.try_redeem_code(code)
	feedback_lbl.text = result
	cheat_input.text = ""

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

func _on_bg_default_pressed():
	Global.set_background("Default")

func _on_bg_dark_pressed():
	Global.set_background("Ruins")
	
func _on_bg_sword_pressed():
	Global.set_background("Sword")
	
