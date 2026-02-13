extends Node

@onready var _d_bg = $"../Dialog Manager/Dialogue Background"
@onready var chr_1 = $"../Dialog Manager/Character Manager/Character"
@onready var chr_2 = $"../Dialog Manager/Character Manager/Character2"
@onready var chr_3 = $"../Dialog Manager/Character Manager/Character3"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# pass # Replace with function body.
	print("Character1 position at _ready:", chr_2.position)

func main_play_collage(_index: int): # changes Background in a collage-like pattern
	_play_collage(_index)
	# pass # Add some play_collage() which is from below
	
func _play_collage(_num: int):
	if _d_bg.check_if_background_isnot_empty():
		if _num == 0:
			_d_bg.set_dialogue_background(Global.background_options.Rolling_Plains)
		elif _num == 5:
			pass
		elif _num == 66:
			pass
		elif _num == 79:
			pass
	else:
		_d_bg.background_node.texture = null
		print("Image Unavaiable")

func set_character_to_darken(_value: String):
	var characters = [chr_1, chr_2, chr_3]
	
	for character in characters:
		if character != null:
			if character.get_character_name() == _value or character.do_value_have_other_name(_value):
				if character.isDarken:
					character.darken(false)
				print(_value)
			else:
				if !character.isDarken:
					character.darken(true)
		else:
			print("NUll bruh")

func main_play_reaction(_line_num: int): # play_reaction() main
	play_reaction(_line_num)
	# pass # Add some play_reaction() which is from below
func play_reaction(_num: int): # This is basically Sprite Manager
	if _num == 5: 
		# pass # remove this when adding a _character.react()
		chr_1.set_character_animation_resource(Global.Character_Animations["Beatrice"])
		chr_2.set_character_animation_resource(Global.Character_Animations["Charlotte"])
		chr_1.do_emerge(true)
		chr_2.do_emerge(true)
		chr_1.fade("fade_in")
		chr_2.fade("fade_in")
		chr_1.idle()
		chr_2.idle()
		# chr_2.slide("Center")
	else:
		pass#_character.react("")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
