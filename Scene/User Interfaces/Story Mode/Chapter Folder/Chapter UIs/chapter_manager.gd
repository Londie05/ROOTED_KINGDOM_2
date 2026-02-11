extends Control

@onready var chapter_list = $"."
# Called when the node enters the scene tree for the first time.
#func _ready() -> void:
#	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
func chapter_selector(chapter_position: int): 
	get_tree().change_scene_to_packed(chapter_list.get_child(chapter_position).chp_scene)
	Global.declare_chapter(chapter_list.get_child(chapter_position).chp_number)
	Global.from_story_mode = true
	

func _on_chapter_panel_pressed() -> void:
	chapter_selector(0) # Chapter 1
