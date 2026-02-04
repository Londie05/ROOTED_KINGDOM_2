extends Node2D
class_name BattleCharacter

@export var damage_node: PackedScene

@export var char_name: String = ""
@export var is_enemy: bool = false
@export var target_height: float = 350.0

var current_health: int = 100
var current_shield: int = 0
var max_health: int = 100
var base_damage: int = 10

var critical_chance: int = 0
var is_aoe: bool = false
var max_aoe_targets: int = 1

# --- NODES ---
@onready var anim_sprite = $AnimSprite
@onready var hp_label = $HealthBar/HPLabel
@onready var hp_bar = $HealthBar
@onready var shield_label = $ShieldLabel

var is_locked_target: bool = false

# For stun
var stun_turns_left: int = 0
var original_color: Color = Color.WHITE

func _ready():
	# Capture the starting color so we can reset after stun
	original_color = modulate
	await get_tree().process_frame
	update_ui()

func spawn_popup(amount: int, color: Color, is_critical: bool = false):
	if damage_node == null: return
	
	var popup = damage_node.instantiate()
	get_tree().current_scene.add_child(popup)
	
	if anim_sprite:
		var spawn_pos = anim_sprite.global_position
		spawn_pos.y -= (target_height / 2.0)
		popup.setup(amount, spawn_pos, color, is_critical)
	
func setup_character(data: CharacterData):
	if data == null:
		hide()
		return
		
	char_name = data.name
	max_health = data.max_health
	current_health = max_health
	base_damage = data.base_damage
	
	if anim_sprite and data.idle_animation:
		anim_sprite.sprite_frames = data.idle_animation
		anim_sprite.play("default")
		
		var first_frame_texture = data.idle_animation.get_frame_texture("default", 0)
		if first_frame_texture:
			var texture_size = first_frame_texture.get_size()
			var scale_factor = target_height / texture_size.y
			anim_sprite.scale = Vector2(scale_factor, scale_factor)
	
	show()
	update_ui()

func flash_character(flash_color: Color):
	if anim_sprite:
		anim_sprite.modulate = flash_color
		var tween = create_tween()
		tween.tween_property(anim_sprite, "modulate", Color.WHITE, 0.55)

func take_damage(amount: int, is_critical: bool = false):
	var damage_to_hp = amount
	
	if current_shield > 0:
		if current_shield >= amount:
			current_shield -= amount
			damage_to_hp = 0
		else:
			damage_to_hp = amount - current_shield
			current_shield = 0
	
	current_health -= damage_to_hp
	flash_character(Color(2.5, 0.5, 0.5))
	spawn_popup(amount, Color.RED, is_critical)
	
	update_ui()
	if current_health <= 0:
		current_health = 0
		die()

func heal(amount: int):
	current_health = min(max_health, current_health + amount)
	flash_character(Color(0.5, 2.5, 0.5))
	spawn_popup(amount, Color.GREEN)
	update_ui()

func add_shield(amount: int):
	current_shield += amount
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

func set_target_lock(should_lock: bool):
	is_locked_target = should_lock
	if anim_sprite and anim_sprite.material:
		var mat = anim_sprite.material
		var tween = create_tween()
		if should_lock:
			tween.tween_method(set_outline_thickness, 0.0, 3.0, 0.2)
			mat.set_shader_parameter("line_color", Color(1.0, 0.9, 0.3, 1.0))
		else:
			tween.tween_method(set_outline_thickness, 3.0, 0.0, 0.2)
		
func set_outline_thickness(value: float):
	if anim_sprite and anim_sprite.material:
		anim_sprite.material.set_shader_parameter("line_thickness", value)
		
func apply_stun(duration: int):
	print("--- DEBUG: apply_stun called for ", char_name, " with duration: ", duration)
	if duration <= 0: 
		print("--- DEBUG: Stun failed because duration is 0 or less")
		return
	
	stun_turns_left += duration
	modulate = Color(0.3, 1.0, 1.0, 0.8) 
	print("--- DEBUG: ", char_name, " stun_turns_left is now: ", stun_turns_left)

func process_stun_turn() -> bool:
	if stun_turns_left > 0:
		stun_turns_left -= 1
		print("--- DEBUG: Processing stun for ", char_name, ". Remaining: ", stun_turns_left)
		
		if stun_turns_left <= 0:
			modulate = original_color
			print("--- DEBUG: ", char_name, " is no longer stunned.")
		return true # Yes, skip turn
	return false # No, attack normally
