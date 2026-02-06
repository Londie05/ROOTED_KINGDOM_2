extends CanvasLayer

signal confirmed
signal cancelled

@onready var message_label = $CenterContainer/PopupBox/MarginContainer/VBoxContainer/Label
@onready var confirm_btn = $CenterContainer/PopupBox/MarginContainer/VBoxContainer/HBoxContainer/ConfirmButton
@onready var cancel_btn = $CenterContainer/PopupBox/MarginContainer/VBoxContainer/HBoxContainer/CancelButton

func _ready() -> void:
	hide()

func setup_popup(message: String, confirm_text: String, cancel_text: String):
	message_label.text = message
	confirm_btn.text = confirm_text
	cancel_btn.text = cancel_text

func show_popup():
	show()

func _on_confirm_button_pressed() -> void:
	confirmed.emit()
	hide()

func _on_cancel_button_pressed() -> void:
	cancelled.emit()
	hide()
