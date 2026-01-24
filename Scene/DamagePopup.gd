extends Label

func setup(amount: int, start_pos: Vector2, type_color: Color):
	top_level = true
	text = str(amount)
	global_position = start_pos
	
	# This sets the font color programmatically
	add_theme_color_override("font_color", type_color)
	
	# Animate
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Floating up and fading out
	tween.tween_property(self, "global_position:y", global_position.y - 80, 0.6)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "modulate:a", 0.0, 0.6).set_delay(0.3)
	tween.chain().tween_callback(queue_free)
