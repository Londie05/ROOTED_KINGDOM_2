extends Button

# DOCUMENTION
# Panel's Mouse > Filter is set to ignore                                        

@export var title: String
@export var image: Texture
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Title.text = title
	$Image.texture = image
