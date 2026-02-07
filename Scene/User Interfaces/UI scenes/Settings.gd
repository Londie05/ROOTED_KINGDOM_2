extends Control

@onready var cheat_input = $VBoxContainer/CheatInput
@onready var redeem_btn = $VBoxContainer/RedeemButton
@onready var feedback_lbl = $VBoxContainer/FeedbackLabel

# references to your new UI elements
@onready var bgm_select = $"User Interface/Options/VBoxContainer/BackgroundSound/BGMSelect"
@onready var volume_slider = $"User Interface/Options/VBoxContainer/Volume/Volume Slider"

func _ready() -> void:
	redeem_btn.pressed.connect(_on_redeem_pressed)
	
	var is_full = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	$"User Interface/Options/VBoxContainer/Fullscreen Check".button_pressed = is_full

	setup_bgm_options()
	
	if volume_slider:
		volume_slider.value = Global.master_volume
		
func setup_bgm_options():
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
