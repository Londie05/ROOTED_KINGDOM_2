extends Control

@onready var default_art = $Default_Art
@onready var ruins_art = $Ruins_Art
@onready var swort_art = $Swort_Art
@onready var grass_art = $Grass_Art

func _ready():
	
	Global.background_changed.connect(_on_bg_changed)
   
	_update_visibility(Global.current_bg_name)

func _on_bg_changed(bg_name: String):
	_update_visibility(bg_name)

func _update_visibility(bg_name: String):
	if default_art and ruins_art and swort_art:
		default_art.visible = (bg_name == "Default")
		ruins_art.visible = (bg_name == "Ruins")
		swort_art.visible = (bg_name == "Sword")
		grass_art.visible = (bg_name == "Grass")
		print("MasterBackground: Initialized to ", bg_name)
