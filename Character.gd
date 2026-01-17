extends Node2D
class_name BattleCharacter
# This script lives on every character (Beatrix, Charlotte, Enemy)

@export var char_name: String = ""
@export var base_speed: int = 10
@export var is_enemy: bool = false

var current_health: int = 100
var current_shield: int = 0
var action_meter: float = 0.0 # This fills up from 0 to 100

var is_stunned: bool = false # NEW: Tracks if the character skips a turn

# These must exist as children inside each character node!
@onready var hp_bar = $HealthBar
@onready var shield_label = $ShieldLabel

# Add this function to handle healing
func heal(amount: int):
	current_health = min(100, current_health + amount)
	update_ui()
	
func _ready():
	hp_bar.max_value = 100
	hp_bar.value = current_health
	shield_label.text = "Shield: 0"

func take_damage(amount: int):
	var damage_to_health = amount - current_shield
	current_shield = max(0, current_shield - amount)
	
	if damage_to_health > 0:
		current_health -= damage_to_health
	
	update_ui()

func update_ui():
	hp_bar.value = current_health
	shield_label.text = "Shield: " + str(current_shield)
