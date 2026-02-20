extends TextureButton

@export var chapter_title: String = "Chapter 1"
@export var rewards: String = ""
@export_file("*.tscn") var target_scene: String = ""

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	# Set pivot to center for the scale effect
	pivot_offset = size / 2 

func _on_mouse_entered():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_BACK)

func _on_mouse_exited():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
