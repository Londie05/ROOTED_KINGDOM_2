extends CanvasLayer

signal confirmed
signal cancelled

@onready var message_label = $CenterContainer/PopupBox/MarginContainer/VBoxContainer/Label
@onready var confirm_btn = $CenterContainer/PopupBox/MarginContainer/VBoxContainer/HBoxContainer/ConfirmButton
@onready var cancel_btn = $CenterContainer/PopupBox/MarginContainer/VBoxContainer/HBoxContainer/CancelButton

var cooldown_timer: float = 0.0
var original_confirm_text: String = ""

func _ready() -> void:
	set_process(false) 
	hide()

func setup_popup(message: String, confirm_text: String, cancel_text: String, wait_time: float = 0.0):
	message_label.text = message
	confirm_btn.text = confirm_text
	cancel_btn.text = cancel_text
	original_confirm_text = confirm_text
	
	if wait_time > 3.0:
		message_label.add_theme_color_override("font_color", Color.RED)
	else:
		message_label.remove_theme_color_override("font_color")
	
	if wait_time > 0:
		cooldown_timer = wait_time
		confirm_btn.disabled = true
		set_process(true)
		_update_button_text()
	else:
		confirm_btn.disabled = false
		set_process(false)

func _process(delta: float) -> void:
	if cooldown_timer > 0:
		cooldown_timer -= delta
		_update_button_text()
		if cooldown_timer <= 0:
			confirm_btn.disabled = false
			confirm_btn.text = original_confirm_text
			set_process(false)

func _update_button_text():
	confirm_btn.text = original_confirm_text + " (" + str(ceil(cooldown_timer)) + "s)"

func show_popup():
	show()

func _on_confirm_button_pressed() -> void:
	hide() 
	confirmed.emit()

func _on_cancel_button_pressed() -> void:
	hide()
	cancelled.emit()

func show_reward_auto_close(message: String, duration: float = 2.0):
	message_label.text = message
	
	confirm_btn.hide()
	cancel_btn.hide()
	
	show()
	
	await get_tree().create_timer(duration).timeout
	hide()
	
	confirm_btn.show()
	cancel_btn.show()
	
