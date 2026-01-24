# Enemy.gd
extends BattleCharacter

func setup_enemy(data: EnemyData):
	if data == null:
		hide()
		return
		
	# 1. Assign Stats from Resource
	char_name = data.name
	max_health = data.max_health # This is where your 333 comes from!
	current_health = max_health
	base_damage = data.base_damage
	current_shield = data.base_shield
	
	# 2. Update Visuals
	if sprite_2d and data.enemy_sprite:
		sprite_2d.texture = data.enemy_sprite
		sprite_2d.flip_h = true 

		var texture_size = sprite_2d.texture.get_size()
		var scale_factor = target_height / texture_size.y
		sprite_2d.scale = Vector2(scale_factor, scale_factor)
	
	# This call now correctly sets max_value to 333 and value to 333
	update_ui() 
	show()
