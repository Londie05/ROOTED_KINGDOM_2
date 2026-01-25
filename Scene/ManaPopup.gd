extends Label

func setup(amount: int):
	text = "+" + str(amount)
	
	# Create a "Tween" to animate the movement and fade out
	var tween = create_tween()
	
	# 1. Float Up: Move 50 pixels up over 0.8 seconds
	tween.tween_property(self, "global_position:y", global_position.y - 80, 1.5)\
		.set_trans(Tween.TRANS_CUBIC)\
		.set_ease(Tween.EASE_OUT)
	
	# 2. Fade Out: Transition alpha to 0 at the same time
	tween.parallel().tween_property(self, "modulate:a", 0, 1.5)
	
	# 3. Cleanup: Delete the node once finished
	tween.finished.connect(queue_free)
