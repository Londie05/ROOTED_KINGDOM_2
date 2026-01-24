extends Node2D
class_name BattleCharacter

@export var damage_node: PackedScene

@export var char_name: String = ""
@export var is_enemy: bool = false
@onready var sprite_2d = $Sprite2D
@export var target_height: float = 350.0 

var current_health: int = 100
var current_shield: int = 0
var max_health: int = 100
var base_damage: int = 10

@onready var hp_label = $HealthBar/HPLabel
@onready var hp_bar = $HealthBar
@onready var shield_label = $ShieldLabel

func _ready():
	update_ui()

func spawn_popup(amount: int, color: Color):
	if damage_node == null: return
	
	var popup = damage_node.instantiate()
	get_tree().current_scene.add_child(popup)
	
	# Calculate the head position (using the fix from before)
	var spawn_pos = sprite_2d.global_position
	spawn_pos.y -= (target_height / 2.0)
	
	popup.setup(amount, spawn_pos, color)
	
# THIS IS THE FUNCTION YOUR MANAGER IS LOOKING FOR
func setup_character(data: CharacterData):
	if data == null: 
		hide()
		return
		
	char_name = data.name
	max_health = data.max_health
	current_health = max_health
	base_damage = data.base_damage
	
	if sprite_2d and data.character_sprite:
		sprite_2d.texture = data.character_sprite
		var texture_size = sprite_2d.texture.get_size()
		var scale_factor = target_height / texture_size.y
		sprite_2d.scale = Vector2(scale_factor, scale_factor)
	
	show()
	update_ui()

func flash_character(flash_color: Color):
	if sprite_2d:
		sprite_2d.modulate = flash_color 
		
		var tween = create_tween()
		tween.tween_property(sprite_2d, "modulate", Color.WHITE, 0.55)


func take_damage(amount: int):
	var damage_to_hp = amount
	
	if current_shield > 0:
		if current_shield >= amount:
			current_shield -= amount
			damage_to_hp = 0
		else:
			damage_to_hp = amount - current_shield
			current_shield = 0
	
	current_health -= damage_to_hp
	
	# Trigger your existing flash effect
	flash_character(Color(2.5, 0.5, 0.5)) 
	
	# --- THE FIX: CALLING THE POPUP ---
	spawn_popup(amount, Color.RED)
	
	update_ui()
	if current_health <= 0:
		die()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	
	# Flash GREEN on heal
	flash_character(Color(0.5, 2.5, 0.5))
	spawn_popup(amount, Color.GREEN)

	update_ui()

func add_shield(amount: int):
	current_shield += amount
	
	# Flash CYAN/BLUE on shield
	flash_character(Color(0.5, 1.0, 2.5))
	spawn_popup(amount, Color.CYAN)
	update_ui()

func update_ui():
	if hp_bar:
		hp_bar.max_value = max_health 
		hp_bar.value = current_health
	if hp_label:
		hp_label.text = str(current_health) 
	if shield_label:
		shield_label.text = "Shield: " + str(current_shield)


func die():
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0, 0.5)
	tween.tween_callback(queue_free)
