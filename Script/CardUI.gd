extends MarginContainer

var card_data: CardData 
@onready var visuals = $Visuals

@onready var card_image_node = $Visuals/VBoxContainer/CardImage
@onready var play_button = $Visuals/VBoxContainer/PlayButton

# We use "get_node_or_null" to prevent the game from crashing if the name is wrong
@onready var desc_panel = get_node_or_null("Visuals/DescriptionPanel") 
@onready var desc_label = get_node_or_null("Visuals/DescriptionPanel/DescriptionLabel")

func _ready():
	if desc_panel:
		desc_panel.hide()
	else:
		# This prints a helpful error instead of crashing!
		print("ERROR: Could not find 'DescriptionPanel' in CardUI.tscn")

func setup(data: CardData):
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	card_data = data
	if data.card_image:
		card_image_node.texture = data.card_image
	
	play_button.text = "Place (" + str(data.mana_cost) + ")"
	
	if desc_label:
		desc_label.text = data.description
	elif desc_panel:
		var potential_label = desc_panel.get_node_or_null("VBoxContainer/DescriptionLabel")
		if potential_label:
			potential_label.text = data.description
			
func set_description_visible(should_be_visible: bool):
	desc_panel.visible = should_be_visible
	
func _on_mouse_entered():
	# Scale up slightly and move up 10 pixels
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	tween.tween_property(self, "position:y", -10.0, 0.1).as_relative()

func _on_mouse_exited():
	# Reset scale and position
	var tween = create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(self, "position:y", 0.0, 0.1)

func animate_play():
	# A quick "pop" effect when played
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func animate_error():
	# Shake the card left and right if you can't afford it
	var tween = create_tween()
	var original_pos = position.x
	tween.tween_property(self, "position:x", original_pos + 10, 0.05)
	tween.tween_property(self, "position:x", original_pos - 10, 0.05)
	tween.tween_property(self, "position:x", original_pos, 0.05)
	modulate = Color.RED
	tween.finished.connect(func(): modulate = Color.WHITE)

func animate_as_active():
	# 1. Kill any existing tweens to avoid conflicts
	var tween = create_tween()
	
	# 2. Make it glow bright Yellow/Gold
	# (Values above 1.0 create a "Glow" if you have HDR/WorldEnvironment, 
	# otherwise it just turns bright yellow)
	visuals.modulate = Color(2.03, 1.962, 1.802, 1.0) 
	
	# 3. Stay highlighted for a moment, then fade back
	tween.tween_interval(0.8) 
	tween.tween_property(visuals, "modulate", Color(1, 1, 1), 0.2)
