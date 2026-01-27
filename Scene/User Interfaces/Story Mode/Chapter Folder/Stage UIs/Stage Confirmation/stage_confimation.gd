extends Control

var stage_scene: PackedScene
@onready var title = $"Panel/Stage Titles/Stage Title Label"
@onready var objective = $Panel/Objective
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass


func _on_back_pressed() -> void:
	objective.visible = false
	$".".visible = false
	stage_scene = null


func _on_play_pressed() -> void:
	if stage_scene != null:
		get_tree().change_scene_to_packed(stage_scene)
	else:
		print("Scene Unavaiable")
