extends Control

@onready var cheat_input = $VBoxContainer/CheatInput
@onready var redeem_btn = $VBoxContainer/RedeemButton
@onready var feedback_lbl = $VBoxContainer/FeedbackLabel

func _ready() -> void:
	redeem_btn.pressed.connect(_on_redeem_pressed)
	
	var is_full = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
	$"User Interface/Options/VBoxContainer/Fullscreen Check".button_pressed = is_full

func _on_redeem_pressed():
	var code = cheat_input.text.to_upper() 
	var result = Global.try_redeem_code(code)
	feedback_lbl.text = result
	cheat_input.text = ""

func _on_volume_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_fullscreen_check_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		DisplayServer.window_set_size(Vector2i(1280, 720)) 
		var screen = DisplayServer.window_get_current_screen()
		var screen_rect = DisplayServer.screen_get_usable_rect(screen)
		DisplayServer.window_set_position(screen_rect.position + (screen_rect.size / 2) - (Vector2i(1280, 720) / 2))
