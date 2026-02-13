extends Node

@onready var _d_bg = $"../Dialog Manager/Dialogue Background"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func main_play_collage(_index: int): # changes Background in a collage-like pattern
	_play_collage(_index)
	# pass # Add some play_collage() which is from below
	
func _play_collage(_num: int):
	if _d_bg.check_if_background_isnot_empty():
		# _d_bg.set_dialogue_background("Nothingness")
		if _num == 0:
			# bg_anim.play("Fade In")
			pass
	else:
		_d_bg.background_node.texture = null
		print("Image Unavaiable")
		
func main_play_reaction(_line_num: int): # play_reaction() main
	# play_reaction(_line_num, $"Character Manager/Character Sprite")
	pass # Add some play_reaction() which is from below

func play_reaction(_num: int): # This is basically Sprite Manager
	if _num == 0: 
		pass # remove this when adding a _character.react()
	else:
		pass#_character.react("")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
