extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	# pass


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/main_menu.tscn")

func _on_tower_mode_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/TowerSelection.tscn")

func _on_story_mode_pressed() -> void:
	if Global.stages_unlocked.size() - 1 == 0:
		Global.declare_chapter(1)
		Global.declare_stage(1)
		Global.from_story_mode = true
		Global.loading_target_scene = "res://Scene/User Interfaces/Story Mode/Dialogue Folders/Dialogue Stages/Story Stages/Chapter 1/Stages_Scenes/Stage_Scene_1-1.tscn"
		get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
	else:
		get_tree().change_scene_to_file("res://Scene/User Interfaces/Story Mode/Chapter Folder/Chapter UIs/chapter_selection.tscn")
