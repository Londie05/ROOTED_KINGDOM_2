extends TextureRect

func _ready():
	# 1. Load the saved background immediately
	update_texture(Global.current_bg_name)
	
	# 2. Listen for changes from the Settings menu
	Global.background_changed.connect(_on_background_changed)

func update_texture(bg_name: String):
	if Global.background_textures.has(bg_name):
		texture = Global.background_textures[bg_name]

func _on_background_changed(new_texture):
	texture = new_texture
