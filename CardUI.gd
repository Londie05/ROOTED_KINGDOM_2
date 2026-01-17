extends PanelContainer # Matches your screenshot!

var card_data: CardData 

# These paths MUST match your Scene Tree names exactly!
@onready var name_label = $VBoxContainer/NameLabel
@onready var description_label = $VBoxContainer/DescriptionLabel
@onready var card_image_node = $VBoxContainer/CardImage
@onready var play_button = $VBoxContainer/PlayButton

func setup(data: CardData):
	card_data = data
	
	# We use get_node here to avoid the "null instance" timing error
	get_node("VBoxContainer/NameLabel").text = data.card_name
	get_node("VBoxContainer/DescriptionLabel").text = data.description
	
	if data.card_image:
		get_node("VBoxContainer/CardImage").texture = data.card_image
	
	get_node("VBoxContainer/PlayButton").text = "Play (" + str(data.energy_cost) + ")"
