extends Node2D

@export var chp_number: int
@export var chp_title: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$"UI Manager/Chapter Number".text = "Chapter " + str(chp_number)
	$"UI Manager/Chapter Title".text = chp_title

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/Story Mode/Chapter Folder/Chapter UIs/chapter_selection.tscn")
