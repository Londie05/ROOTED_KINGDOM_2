extends AnimatedSprite2D

class_name _CharacterSprite
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func react(emote: String):
	if emote == "idle":
		$".".play("idle")
	elif emote == "talking":
		$".".play("talking")
	else:
		$".".stop()
