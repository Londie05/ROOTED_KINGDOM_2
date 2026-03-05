extends Label

func setup(amount: int, start_pos: Vector2, type_color: Color, is_critical: bool = false):
	top_level = true
	text = str(amount)
	
	# --- ADJUSTED SPREAD ---
	# Tightened horizontal spawn range (formerly -70 to 70)
	var random_x = randf_range(-35, 35) 
	var random_y = randf_range(-15, 5)
	global_position = start_pos + Vector2(random_x, random_y)
	
	var final_color = type_color
	var final_scale = Vector2(0.9, 0.9) 
	
	if is_critical:
		text = str(amount) + "!"
		final_color = Color.GOLD
		final_scale = Vector2(1.3, 1.3)
		z_index = 20
	
	add_theme_color_override("font_color", final_color)
	scale = final_scale
	
	var tween = create_tween().set_parallel(true)
	
	# --- ADJUSTED DRIFT ---
	# Reduced the drift multiplier (formerly 1.5x) to 0.5x so they stay closer
	# Lowered vertical float to -90 (formerly -130)
	var drift_out_x = random_x * 0.5 
	tween.tween_property(self, "global_position", global_position + Vector2(drift_out_x, -90), 0.7)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	# Fading and shrinking
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_delay(0.3)
	tween.tween_property(self, "scale", Vector2(0.6, 0.6), 0.5).set_delay(0.3)

	tween.chain().tween_callback(queue_free)
