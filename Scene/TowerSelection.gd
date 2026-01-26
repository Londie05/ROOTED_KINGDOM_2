extends Control

@onready var desc_label = $DescriptionPanel/Label # Make sure this is a RichTextLabel!
var selected_floor = 1

# --- ICON PATHS (UPDATE THESE!) ---
const GEM_ICON_PATH = "res://Asset/Backgrounds/gem_1.webp"
const CRYSTAL_ICON_PATH = "res://Asset/Backgrounds/gem_3.webp"

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
	Global.current_tower_floor = floor_num
	
	# 1. Get the reward data from Global
	var reward = Global.floor_rewards.get(floor_num, {"small": 0, "crystal": 0})
	
	# 2. Build the Text with Icons
	# We use [img=30] to set the size of the icon to 30 pixels
	var text = "[b]" + description + "[/b]\n\n"
	text += "Rewards:\n"
	
	if reward["small"] > 0:
		text += "[img=25]%s[/img] %d  " % [GEM_ICON_PATH, reward["small"]]
		
	if reward["crystal"] > 0:
		text += "[img=25]%s[/img] %d" % [CRYSTAL_ICON_PATH, reward["crystal"]]
	
	# 3. Update the Label
	desc_label.text = text

func _on_choose_characters_pressed():
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/start_battle.tscn")
