extends Label

# Added 'is_critical' to the setup arguments
func setup(amount: int, start_pos: Vector2, type_color: Color, is_critical: bool = false):
	top_level = true
	text = str(amount)
	global_position = start_pos
	
	# Default styling
	var final_color = type_color
	var final_scale = Vector2(1, 1)
	
	# --- CRITICAL HIT LOGIC ---
	if is_critical:
		text = str(amount) + "!"
		final_color = Color.GOLD     # Override color to Gold for Crits
		final_scale = Vector2(1.5, 1.5) # Make it bigger
		z_index = 20                 # Ensure it pops over everything
	
	# Apply your specific coloring method
	add_theme_color_override("font_color", final_color)
	
	# Apply scale
	scale = final_scale
	
	# Animate (Your original Tween logic)
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Floating up
	tween.tween_property(self, "global_position:y", global_position.y - 80, 0.6)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	# Fading out
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_delay(0.3)
	
	# Optional: Extra "shake" for crits
	if is_critical:
		var shake = create_tween()
		shake.tween_property(self, "scale", final_scale * 1.3, 0.1)
		shake.tween_property(self, "scale", final_scale, 0.1)

	tween.chain().tween_callback(queue_free)
