extends BattleCharacter

func setup_enemy(data: EnemyData):
	if data == null:
		hide()
		return
		
	# 1. Setup Stats
	char_name = data.name
	max_health = data.max_health
	current_health = max_health
	base_damage = data.base_damage
	current_shield = data.base_shield
	
	# 2. Setup AI Rules
	critical_chance = randi_range(data.min_crit_chance, data.max_crit_chance)
	is_aoe = data.is_aoe
	max_aoe_targets = data.aoe_targets
	
	# 3. FIX: Setup Animation & Scaling
	# We use 'sprite_frames' now, not 'texture'
	if anim_sprite and data.idle_animation:
		anim_sprite.sprite_frames = data.idle_animation
		anim_sprite.play("default")
		anim_sprite.flip_h = true # Flip enemies to face left
		
		# CALCULATE SIZE
		# We get the size of the first frame of the animation
		var first_frame = data.idle_animation.get_frame_texture("default", 0)
		if first_frame:
			var t_size = first_frame.get_size()
			# This math ensures they grow/shrink to match your Target Height
			var scale_factor = target_height / t_size.y
			anim_sprite.scale = Vector2(scale_factor, scale_factor)
	
	update_ui()
	show()
