extends MarginContainer

var card_data: CardData 
@onready var visuals = $Visuals

@onready var card_image_node = $Visuals/VBoxContainer/CardImage
@onready var play_button = $Visuals/VBoxContainer/PlayButton

@onready var desc_panel = get_node_or_null("Visuals/DescriptionPanel") 
@onready var desc_label = get_node_or_null("Visuals/DescriptionPanel/DescriptionLabel")
var is_in_hand: bool = true

func _ready():
	if desc_panel:
		desc_panel.hide()
	visuals.pivot_offset = visuals.size / 2

func setup(data: CardData):
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	
	card_data = data
	if data.card_image:
		card_image_node.texture = data.card_image
	
	play_button.text = "Mana cost:" + str(data.mana_cost)
	
	if desc_label:
		desc_label.text = data.description
			
func set_description_visible(should_be_visible: bool):
	if desc_panel:
		desc_panel.visible = should_be_visible
	
func _on_mouse_entered():
	if not is_in_hand: return
	
	z_index = 10 # Appear on top of other cards
	var tween = create_tween().set_parallel(true)
	tween.tween_property(visuals, "scale", Vector2(1.15, 1.15), 0.1)
	tween.tween_property(visuals, "position:y", -20.0, 0.1)

func _on_mouse_exited():
	if not is_in_hand: return
	
	z_index = 0
	var tween = create_tween().set_parallel(true)
	tween.tween_property(visuals, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(visuals, "position:y", 0.0, 0.1)

func animate_play():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func animate_error():
	var tween = create_tween()
	var original_pos = visuals.position.x
	tween.tween_property(visuals, "position:x", original_pos + 10, 0.05)
	tween.tween_property(visuals, "position:x", original_pos - 10, 0.05)
	tween.tween_property(visuals, "position:x", original_pos, 0.05)
	visuals.modulate = Color.RED
	tween.finished.connect(func(): visuals.modulate = Color.WHITE)

func animate_as_active():
	var tween = create_tween()
	
	visuals.modulate = Color(2.03, 1.962, 1.802, 1.0) 
	
	tween.tween_interval(0.8) 
	tween.tween_property(visuals, "modulate", Color(1, 1, 1), 0.2)
