extends Control

@export var Stage: PackedScene
@export var Stage_number: int
@export var Stage_img: Texture
@export_enum("Story", "Battle") var Scene_type: String
@export var Objective: String
@export var availability: bool

@onready var stage_confirm = $"../../../../Stage Confimation"
@onready var stage_image = $"Interface/Stage Image"
@onready var stage_frame = $Interface/Frame

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	stage_image.img.texture = Stage_img
	if Scene_type == "Story":
		stage_frame.texture = preload("res://Asset/User Interface/stage_slot_frame_story.png")
	elif Scene_type == "Battle":
		stage_frame.texture = preload("res://Asset/User Interface/stage_slot_frame_tower.png")
	else:
		print("Scene_type is null or the texture of the Frame is absent.")
	
	if availability:
		$"Interface/Stage Button".disabled = false
		$Interface/Label.visible = false
	else:
		$Interface/Label.visible = true
		$"Interface/Stage Button".disabled = true
		
	# $"Stage Slot bg".texture = Stage_img
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _on_stage_button_pressed() -> void:
	stage_confirm.visible = true
	Global.declare_stage(Stage_number)
	stage_confirm.title.text = "Stage " + str(Global._CURRENTLY_PLAYING_CHAPTER) + " - " + str(Stage_number)
	
	stage_confirm.image.texture = Stage_img
	if Stage != null:
		if Scene_type == "Story":
			stage_confirm.stage_scene = Stage
	elif Scene_type == "Battle":
		stage_confirm.stage_scene = preload("res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn")
	else:
		stage_confirm.stage_scene = null	
	
	if Objective != null:
		if Scene_type == "Story":
			stage_confirm.objective.visible = false
		elif Scene_type == "Battle":
			stage_confirm.objective.visible = true
			stage_confirm.objective.text = Objective
	else:
		stage_confirm.objective.visible = false
			
