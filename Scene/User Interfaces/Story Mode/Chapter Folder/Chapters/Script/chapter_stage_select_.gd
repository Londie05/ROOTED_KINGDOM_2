extends Control

@export var chp_number: int
@export var chp_title: String

@onready var stage_confirm_for_select = $"Stage Confimation"

@onready var stage_list = $"Stage Manager/ScrollContainer/HBoxContainer".get_children()
@onready var stage_node_list = $"Stage Manager/ScrollContainer/HBoxContainer"

func number_of_stage():
	print(str(stage_list.size()))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"UI Manager/Chapter Number".text = "Chapter " + str(chp_number)
	$"UI Manager/Chapter Title".text = chp_title
	stage_confirm_for_select.visible = false
	# number_of_stage()
	for stage in stage_list:
		var Stage_name = str(chp_number) + "-" + str(stage.Stage_number)
		stage.get_node("Interface/Stage Button").text = str(chp_number) + " - " + str(stage.Stage_number)
		if not Global.stages_cleared.has(Stage_name):
			stage.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/Story Mode/Chapter Folder/Chapter UIs/chapter_selection.tscn")
	Global.reset_current_playing_on_stage()
	Global.from_story_mode = false
