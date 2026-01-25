extends Control

@onready var desc_label = $DescriptionPanel/Label
var selected_floor = 1

func _ready():
	# Ensure "VBox" matches your Scene Tree exactly (case sensitive!)
	var container = $ScrollContainer/VBox
	
	container.get_node("Floor1").pressed.connect(_on_floor_selected.bind(1, "Floor 1: One Grunt"))
	container.get_node("Floor2").pressed.connect(_on_floor_selected.bind(2, "Floor 2: Two Grunts"))
	container.get_node("Floor3").pressed.connect(_on_floor_selected.bind(3, "Floor 3: The Trio"))
	container.get_node("Floor4").pressed.connect(_on_floor_selected.bind(4, "Floor 4: The four enemies"))
	container.get_node("Floor6").pressed.connect(_on_floor_selected.bind(6, "Floor 6: The benevolent"))
	container.get_node("Floor7").pressed.connect(_on_floor_selected.bind(7, "Floor 7: The benevolent"))
	container.get_node("Floor8").pressed.connect(_on_floor_selected.bind(8, "Floor 8: The benevolent"))
	container.get_node("Floor9").pressed.connect(_on_floor_selected.bind(9, "Floor 9: The benevolent"))
	container.get_node("Floor10").pressed.connect(_on_floor_selected.bind(10, "Floor 10: The benevolent"))

	# Redirect the button to the Character Selection scene
	$StartBattleButton.text = "Choose Characters" # Optional: Change button text
	$StartBattleButton.pressed.connect(_on_choose_characters_pressed)

func _on_floor_selected(floor_num: int, description: String):
	selected_floor = floor_num
	desc_label.text = description
	Global.current_tower_floor = floor_num

func _on_choose_characters_pressed():
	# Navigate to Character Selection
	get_tree().change_scene_to_file("res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn")
