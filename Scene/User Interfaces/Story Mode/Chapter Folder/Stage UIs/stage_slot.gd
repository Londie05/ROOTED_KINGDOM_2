extends Control

@export var Stage: PackedScene
@export var Stage_number: String
@export var Stage_img: Texture
@export_enum("Story", "Battle") var Scene_type: String
@export var Objective: String

@onready var stage_confirm = $"../../Stage Confimation"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"Stage Button".text = Stage_number
	$"Stage Slot bg".texture = Stage_img
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass

func _on_stage_button_pressed() -> void:
	stage_confirm.visible = true
	stage_confirm.title.text = Stage_number
	if Stage != null:
		stage_confirm.stage_scene = Stage
	else:
		stage_confirm.stage_scene = null	
	
	if Objective != null:
		if Scene_type == "Story":
			stage_confirm.objective.visible = false
		elif Scene_type == "Battle":
			stage_confirm.objective.visible = true
			stage_confirm.objective.text = Objective
			
