extends BattleCharacter

signal enemy_selected(node)

var enemy_data: EnemyData # Store the reference to the resource

func _ready():
	super()
	var area = get_node_or_null("ClickArea")
	if area:
		if not area.input_event.is_connected(_on_input_event):
			area.input_event.connect(_on_input_event)
			
func setup_enemy(data: EnemyData):
	if data == null:
		hide()
		return
	
	enemy_data = data # Save the whole resource for easy access
		
	char_name = data.name
	max_health = data.max_health
	current_health = max_health
	base_damage = data.base_damage
	current_shield = data.base_shield
	
	critical_chance = randi_range(data.min_crit_chance, data.max_crit_chance)
	
	# Default/Normal values
	is_aoe = data.is_aoe
	max_aoe_targets = data.aoe_targets
	
	if anim_sprite and data.idle_animation:
		anim_sprite.sprite_frames = data.idle_animation
		anim_sprite.play("default")
		anim_sprite.flip_h = true 
		
		var first_frame = data.idle_animation.get_frame_texture("default", 0)
		if first_frame:
			var t_size = first_frame.get_size()
			var scale_factor = target_height / t_size.y
			anim_sprite.scale = Vector2(scale_factor, scale_factor)
	
	update_ui()
	show()

func decide_attack() -> Dictionary:
	if randf() < enemy_data.secondary_attack_chance:
		return {
			"sfx": enemy_data.attack_sound_2,
			"damage_mult": enemy_data.secondary_damage_mult,
			"is_aoe": enemy_data.secondary_is_aoe, 
			"aoe_targets": enemy_data.secondary_aoe_targets,
			"is_secondary": true,
			"anim_name": enemy_data.secondary_anim,
			"move_to_center": enemy_data.secondary_moves_center,
			"is_vfx_only": enemy_data.secondary_is_vfx_only,
			"vfx_scale": enemy_data.secondary_vfx_scale,  # Pass Scale
			"vfx_offset": enemy_data.secondary_vfx_offset  # Pass Offset
		}
	else:
		return {
			"sfx": enemy_data.attack_sound_1,
			"damage_mult": 1.0,
			"is_aoe": enemy_data.is_aoe, 
			"aoe_targets": enemy_data.aoe_targets,
			"is_secondary": false,
			"anim_name": enemy_data.primary_anim,
			"move_to_center": enemy_data.primary_moves_center,
			"is_vfx_only": enemy_data.primary_is_vfx_only,
			"vfx_scale": enemy_data.primary_vfx_scale,     # Pass Scale
			"vfx_offset": enemy_data.primary_vfx_offset    # Pass Offset
		}

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_viewport().set_input_as_handled()
			enemy_selected.emit(self)

func play_enemy_attack_sequence(decision: Dictionary, targets: Array):
	var start_pos = global_position
	var target_node = targets[0] if not targets.is_empty() else null
	
	# 1. Handle Movement to Target
	if decision["move_to_center"] and target_node: # "move_to_center" now acts as "move_to_target"
		var target_pos = target_node.global_position
		var stop_distance = 100.0 # How far away from the hero to stop
		
		# Calculate point in front of the hero
		var direction = (global_position - target_pos).normalized()
		var destination = target_pos + (direction * stop_distance)
		
		var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
		tween.tween_property(self, "global_position", destination, 0.3)
		await tween.finished
	
	# 2. Play Animation OR Spawn VFX
	if decision["is_vfx_only"]:
		var vfx_sprite = AnimatedSprite2D.new()
		vfx_sprite.sprite_frames = anim_sprite.sprite_frames
		get_tree().current_scene.add_child(vfx_sprite)
		
		# If VFX only, we usually spawn it on the target's position + your custom offset
		var spawn_base_pos = target_node.global_position if target_node else global_position
		vfx_sprite.global_position = spawn_base_pos + decision["vfx_offset"]
		vfx_sprite.scale = decision["vfx_scale"]
		
		vfx_sprite.play(decision["anim_name"])
		vfx_sprite.z_index = 50
		
		shake()
		await get_tree().create_timer(0.4).timeout 
		attack_hit_moment.emit()
			
		await vfx_sprite.animation_finished
		vfx_sprite.queue_free()
		
	else:
		# Standard Physical Animation
		if anim_sprite and anim_sprite.sprite_frames.has_animation(decision["anim_name"]):
			anim_sprite.play(decision["anim_name"])
			await get_tree().create_timer(0.4).timeout 
			attack_hit_moment.emit()
			await anim_sprite.animation_finished
			anim_sprite.play("default") 
		else:
			await get_tree().create_timer(0.4).timeout
			attack_hit_moment.emit()

	# 3. Return to original position
	if decision["move_to_center"]:
		var tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		tween.tween_property(self, "global_position", start_pos, 0.3)
		await tween.finished
		
	attack_finished.emit()
		
