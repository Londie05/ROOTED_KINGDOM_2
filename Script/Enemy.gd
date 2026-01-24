# Enemy.gd
extends BattleCharacter

func setup_enemy(data: EnemyData):
	if data == null:
		hide()
		return
		
	char_name = data.name
	max_health = data.max_health
	current_health = max_health
	base_damage = data.base_damage
	current_shield = data.base_shield
	
	# --- NEW: Set Random Crit and AOE from Data ---
	critical_chance = randi_range(data.min_crit_chance, data.max_crit_chance)
	is_aoe = data.is_aoe
	max_aoe_targets = data.aoe_targets
	# ----------------------------------------------
	
	# Update Visuals
	if sprite_2d and data.enemy_sprite:
		sprite_2d.texture = data.enemy_sprite
		sprite_2d.flip_h = true 
		var texture_size = sprite_2d.texture.get_size()
		var scale_factor = target_height / texture_size.y
		sprite_2d.scale = Vector2(scale_factor, scale_factor)
	
	update_ui() 
	show()
