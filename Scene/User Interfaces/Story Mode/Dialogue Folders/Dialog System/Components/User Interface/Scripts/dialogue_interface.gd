extends Control

@onready var Dialogue_ui = $PanelContainer/Dialogue
@onready var Dialogue_speaker = $PanelContainer2/Speakername
@onready var dialogue_panel = $PanelContainer
@onready var speaker_panel = $PanelContainer2

var animate_text:= true
var animation_speed:= 30

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogue_ui.visible_ratio = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animate_text:
		if Dialogue_ui.visible_ratio < 1.0:
			Dialogue_ui.visible_ratio += (1.0/Dialogue_ui.text.length()) * (animation_speed * delta)
		else:
			animate_text = false
