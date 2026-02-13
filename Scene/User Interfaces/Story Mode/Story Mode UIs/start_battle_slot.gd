extends Button

# DOCUMENTION
# Panel's Mouse > Filter is set to ignore                                        

@export var title: String
@export var image: Texture
@export_enum("Story Mode", "Tower Mode") var mode
@export var availability: bool


@onready var CURRENT_STAGE_LEVEL = $"MarginContainer/Control/Current Stage-Level"
@onready var title_label = $MarginContainer/Control/Title
@onready var image_rect = $Image
@onready var availability_label = $"Availability Label"
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title_label.text = title
	image_rect.texture = image
	if mode == 0:
		CURRENT_STAGE_LEVEL.text = "Current Stage " + " - " + Global.stages_unlocked.back()
	elif mode == 1:	
		CURRENT_STAGE_LEVEL.text = "Current Tower Floor Level: " + str(Global.current_tower_floor)
	else:
		print("mode is null")
	
	# THIS DECIDEDS IF THE BUTTON IS CLICKABLE OR NOT
	if availability:
		availability_label.visible = false
		$".".disabled = false
	else:
		availability_label.visible = true
		$".".disabled = true
