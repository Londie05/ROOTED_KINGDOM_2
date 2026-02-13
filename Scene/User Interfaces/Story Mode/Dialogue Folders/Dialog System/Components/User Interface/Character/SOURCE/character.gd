extends Control

@onready var Reactions = $Reactions
@onready var Character = $"."
@onready var PropertyAnim = $PropertyAnimations

var property_fx = [
	"Left",
	"Right",
	"Center",
	"Fade_In",
	"Fade_Out"
]
var character_name = ""
var isDarken:= false
# THIS IS HOW THIS WOULD WORK
# EACH ANIMATION WILL BE CALLED IN DIALOGUE SYSTEM PROGRAM
# EACH ANIMATION ARE CALLED IN THE SAME MANNER, MEANING THE NAMING CONVENTION
# MUST BE CONSISTENT ACROSS ALL ANIMATIONS

# PROPERTY ANIMATION IS THERE JUST IN CASE IT IS REQUIRES; BECAUSE IT IS REQUIRED

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#Reactions.sprite_frames = preload("res://Asset/Backgrounds/background 1.jpg")
	do_emerge(false)

func set_character_animation_resource(path: String):
	Reactions.sprite_frames = load(path)

# REACTIONS
func idle(): # DEFAULT
	Reactions.play("default")
	
func happy():
	Reactions.play("happy")

func mad():
	Reactions.play("mad")

# PROPERTY ANIMATIONS
# SET CHARACTER NAME
func set_character_name(value: String):
	if value != "":
		character_name = value
	else:
		character_name = ""
# SET POSITION
func set_character_position(x: float, y: float):
	Character.position = Vector2(x, y)

func set_speaker_effect_on_character(value: String):
	if value == Reactions.sprite_frames.character_name:
		darken(false)
	else:
		darken(true)

func get_character_name():
	if Reactions.sprite_frames.character_name != null:
		return Reactions.sprite_frames.character_name
	else:
		return ""

func do_value_have_other_name(value: String):
	if Reactions.sprite_frames.other_name != []:
		for names in Reactions.sprite_frames.other_name:
			if names == value:
				return true
	else:
		return []
# RESET
func reset():
	PropertyAnim.play("RESET")
# Slide
func slide(towards: String):
	if towards.to_lower() == "center":
		if Character.position.x > 400:
			PropertyAnim.play("slide_to_center_from_left")
		elif Character.position.x < 400:
			PropertyAnim.play("slide_to_center_from_right")
	elif towards.to_lower() == "left":
		PropertyAnim.play("slide_to_left")
	elif towards.to_lower() == "right":
		PropertyAnim.play("slide_to_right")
# Fade
func fade(value: String):
	if value.to_lower() == "fade_in":
		PropertyAnim.play("fade_in")
	elif value.to_lower() == "fade_out":
		PropertyAnim.play("fade_out")
# Darken
func darken(value: bool):
	if value and !isDarken:
		PropertyAnim.play("darkens")
	else:
		PropertyAnim.play("revert_dark")
	isDarken = value
# Emerge_and_disappear
func do_emerge(value: bool):
	if value:
		Character.modulate.a = 1
	else:
		Character.modulate.a = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass
