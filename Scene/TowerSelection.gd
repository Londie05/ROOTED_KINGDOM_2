extends Control

@onready var desc_label = $DescriptionPanel/Label
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
	container.get_node("Floor5").pressed.connect(_on_floor_selected.bind(5, "Floor 5: The Mid-Boss"))
	container.get_node("Floor6").pressed.connect(_on_floor_selected.bind(6, "Floor 6: The benevolent"))
	container.get_node("Floor7").pressed.connect(_on_floor_selected.bind(7, "Floor 7: The benevolent"))
	container.get_node("Floor8").pressed.connect(_on_floor_selected.bind(8, "Floor 8: The benevolent"))
	container.get_node("Floor9").pressed.connect(_on_floor_selected.bind(9, "Floor 9: The benevolent"))
	container.get_node("Floor10").pressed.connect(_on_floor_selected.bind(10, "Floor 10: The benevolent"))
	container.get_node("Floor11").pressed.connect(_on_floor_selected.bind(11, "Floor 11: One Grunt"))
	container.get_node("Floor12").pressed.connect(_on_floor_selected.bind(12, "Floor 12: Two Grunts"))
	container.get_node("Floor13").pressed.connect(_on_floor_selected.bind(13, "Floor 13: The Trio"))
	container.get_node("Floor14").pressed.connect(_on_floor_selected.bind(14, "Floor 14: The four enemies"))
	container.get_node("Floor15").pressed.connect(_on_floor_selected.bind(15, "Floor 15: The Mid-Boss"))
	container.get_node("Floor16").pressed.connect(_on_floor_selected.bind(16, "Floor 16: The benevolent"))
	container.get_node("Floor17").pressed.connect(_on_floor_selected.bind(17, "Floor 17: The benevolent"))
	container.get_node("Floor18").pressed.connect(_on_floor_selected.bind(18, "Floor 18: The benevolent"))
	container.get_node("Floor19").pressed.connect(_on_floor_selected.bind(19, "Floor 19: The benevolent"))
	container.get_node("Floor20").pressed.connect(_on_floor_selected.bind(20, "Floor 20: The benevolent"))
	container.get_node("Floor21").pressed.connect(_on_floor_selected.bind(21, "Floor 21: On Going"))
	$StartBattleButton.text = "Choose Characters" 
	$StartBattleButton.pressed.connect(_on_choose_characters_pressed)
	
	lock_floors()

func _on_floor_selected(floor_num: int, description: String):
	selected_floor = floor_num
	Global.current_tower_floor = floor_num
	
	var reward = Global.floor_rewards.get(floor_num, {"small": 0, "crystal": 0})
	
	# --- NEW: Check if already cleared ---
	var is_cleared = Global.floors_cleared.has(floor_num)
	
	var text = "[b]" + description + "[/b]\n\n"
	
	if is_cleared:
		# Notification for already gotten rewards
		text += "Rewards: [color=green][CLAIMED][/color]\n"
		# Optional: Show what the rewards were but gray them out
		text += "[color=gray]"
		if reward["small"] > 0:
			text += "[img=25]%s[/img] %d  " % [GEM_ICON_PATH, reward["small"]]
		if reward["crystal"] > 0:
			text += "[img=25]%s[/img] %d" % [CRYSTAL_ICON_PATH, reward["crystal"]]
		text += "[/color]"
	else:
		# Standard reward display
		text += "Rewards:\n"
		if reward["small"] > 0:
			text += "[img=25]%s[/img] %d  " % [GEM_ICON_PATH, reward["small"]]
		if reward["crystal"] > 0:
			text += "[img=25]%s[/img] %d" % [CRYSTAL_ICON_PATH, reward["crystal"]]
	
	desc_label.text = text

func _on_choose_characters_pressed():
	Global.from_tower_mode = true # Preparing for battle!
	get_tree().change_scene_to_file("res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/start_battle.tscn")

func lock_floors():
	var container = $ScrollContainer/VBox
	
	for i in range(1, 22):
		var node_name = "Floor" + str(i)
			
		if container.has_node(node_name):
			var btn = container.get_node(node_name)
			var is_unlocked = false
			if i == 1:
				is_unlocked = true
			elif Global.floors_cleared.has(i - 1):
				is_unlocked = true
			
			btn.disabled = not is_unlocked
			
			if is_unlocked:
				btn.modulate = Color(1, 1, 1) 
			else:
				btn.modulate = Color(0.5, 0.5, 0.5) 
