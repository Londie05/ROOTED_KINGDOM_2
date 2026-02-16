extends AnimatedSprite2D

func play_effect(frames: SpriteFrames, anim_name: String):
	self.sprite_frames = frames
	if sprite_frames.has_animation(anim_name):
		play(anim_name)
	else:
		play("default") # Fallback
	
	# Automatically delete when the animation finishes
	animation_finished.connect(queue_free)
