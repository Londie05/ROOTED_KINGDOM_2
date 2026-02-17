extends Control
class_name DialogueInterface

signal next_line_requested
signal prev_line_requested

@onready var dialogue_text: RichTextLabel = $"MarginContainer/Control/Dialogue Panel Container/MarginContainer/Dialogue"
@onready var speaker_name_label: Label = $"MarginContainer/Control/Speaker PanelContainer/MarginContainer/Speakername"
@onready var speaker_panel = $"MarginContainer/Control/Speaker PanelContainer"
@onready var next_btn: Button = $MarginContainer/Control/NextButton
@onready var back_btn: Button = $MarginContainer/Control/BackButton

var is_typing = false
var current_text = ""
var typing_tween: Tween
var is_active = true # NEW: To disable UI when the chapter ends

func _ready():
	speaker_panel.visible = false

func show_line(speaker_name: String, text_to_show: String):
	if typing_tween and typing_tween.is_valid():
		typing_tween.kill()
	
	current_text = text_to_show
	dialogue_text.text = current_text
	dialogue_text.visible_ratio = 0.0
	
	if not speaker_name or speaker_name == "":
		speaker_panel.visible = false
	else:
		speaker_name_label.text = speaker_name
		speaker_panel.visible = true

	is_typing = true
	typing_tween = create_tween()
	var duration = current_text.length() * 0.02 
	typing_tween.tween_property(dialogue_text, "visible_ratio", 1.0, duration)
	typing_tween.finished.connect(func(): is_typing = false)

func _on_next_button_pressed() -> void:
	if not is_active: return # Don't do anything if UI is locked
	
	if is_typing:
		# Fast-forward text
		if typing_tween and typing_tween.is_valid():
			typing_tween.kill()
		dialogue_text.visible_ratio = 1.0
		is_typing = false
	else:
		# Send signal to Director (Chapter script)
		next_line_requested.emit()

func _on_back_button_pressed() -> void:
	if not is_active: return
	
	if typing_tween and typing_tween.is_valid():
		typing_tween.kill()
	
	prev_line_requested.emit()

# Call this from Chapter2.gd when the popup shows up!
func set_active(state: bool):
	is_active = state
	next_btn.disabled = !state
	if back_btn: back_btn.disabled = !state
