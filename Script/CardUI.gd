extends PanelContainer # Matches your screenshot!

var card_data: CardData 

# These paths MUST match your Scene Tree names exactly!
@onready var card_image_node = $VBoxContainer/CardImage
@onready var play_button = $VBoxContainer/PlayButton

func setup(data: CardData):
	card_data = data

	
	if data.card_image:
		get_node("VBoxContainer/CardImage").texture = data.card_image
	
	get_node("VBoxContainer/PlayButton").text = "Play (" + str(data.energy_cost) + ")"
