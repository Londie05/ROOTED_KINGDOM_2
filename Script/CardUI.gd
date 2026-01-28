extends PanelContainer

var card_data: CardData 

@onready var card_image_node = $VBoxContainer/CardImage
@onready var play_button = $VBoxContainer/PlayButton

# We use "get_node_or_null" to prevent the game from crashing if the name is wrong
@onready var desc_panel = get_node_or_null("DescriptionPanel") 
@onready var desc_label = get_node_or_null("DescriptionPanel/DescriptionLabel")

func _ready():
	if desc_panel:
		desc_panel.hide()
	else:
		# This prints a helpful error instead of crashing!
		print("ERROR: Could not find 'DescriptionPanel' in CardUI.tscn")

func setup(data: CardData):
	card_data = data
	if data.card_image:
		card_image_node.texture = data.card_image
	
	play_button.text = "Play (" + str(data.mana_cost) + ")"
	
	if desc_label:
		desc_label.text = data.description
	elif desc_panel:
		var potential_label = desc_panel.get_node_or_null("VBoxContainer/DescriptionLabel")
		if potential_label:
			potential_label.text = data.description

# --- THE FUNCTION CALLED BY BATTLEMANAGER ---
func set_description_visible(is_visible: bool):
	if desc_panel:
		desc_panel.visible = is_visible
