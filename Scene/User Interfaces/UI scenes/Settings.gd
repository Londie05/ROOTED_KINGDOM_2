extends Node2D

@onready var cheat_input = $VBoxContainer/CheatInput
@onready var redeem_btn = $VBoxContainer/RedeemButton
@onready var feedback_lbl = $VBoxContainer/FeedbackLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	redeem_btn.pressed.connect(_on_redeem_pressed)

# --- 1. REDEEM CODE LOGIC ---
func _on_redeem_pressed():
	var code = cheat_input.text.to_upper() 
	var result = Global.try_redeem_code(code)
	
	
	feedback_lbl.text = result
	cheat_input.text = ""
