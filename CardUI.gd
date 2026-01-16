extends PanelContainer

@onready var name_label = $VBoxContainer/NameLabel
@onready var desc_label = $VBoxContainer/DescriptionLabel

var card_data: CardData # This refers to the Resource we made in Part 1

func setup(data: CardData):
	card_data = data
	name_label.text = data.card_name
	
	if data.damage > 0:
		desc_label.text = "Deal " + str(data.damage) + " DMG"
	elif data.shield > 0:
		desc_label.text = "Gain " + str(data.shield) + " SHLD"
