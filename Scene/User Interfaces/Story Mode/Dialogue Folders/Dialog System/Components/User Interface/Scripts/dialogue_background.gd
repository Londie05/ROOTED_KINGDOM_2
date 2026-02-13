extends Control

@onready var background_node = $Background
@onready var bg_anim = $"Background/Background Animation"

const bg_options = Global.background_options
const bg_anim_select = Global.bg_anim_options
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_dialogue_background(select: bg_options):
	if select == bg_options.Nothingness:
		background_node.texture = preload("res://Asset/User Interface/%Storymode%/black_background.jpg")
	elif select == bg_options.Rolling_Plains:
		background_node.texture = preload("res://Asset/User Interface/%Storymode%/Rollings Plains.jpg")

func set_dialogue_background_as_cutscene(cutscene: int):
	if cutscene == 1:
		background_node.texture = preload("res://Asset/User Interface/%Storymode%/scene 1.jpg")
	elif cutscene == 2:
		background_node.texture = preload("res://Asset/User Interface/%Storymode%/scene 2.jpg")
		
func set_bg_animation(Animate: bg_anim_select):
	if Animate == bg_anim_select.Fade_transition:
		if bg_anim.animation_finished:
			bg_anim.play("Fade In")
		else:
			bg_anim.play("Fade Out")
			set_bg_animation(Animate)
	elif Animate == bg_anim_select.Fade_In:
		bg_anim.play("Fade In")
	elif Animate == bg_anim_select.Fade_Out:
		bg_anim.play("Fade Out")

func check_if_background_isnot_empty():
	if background_node.texture != null:
		return true
# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass
