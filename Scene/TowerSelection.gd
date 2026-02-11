extends Control

@onready var desc_label = $DescriptionPanel/Label
@onready var start_btn = $StartBattleButton 

var selected_floor: int = 0 

const GEM_ICON_PATH = "res://Asset/Backgrounds/gem_1.webp"
const CRYSTAL_ICON_PATH = "res://Asset/Backgrounds/gem_3.webp"

func _ready():
	var container = $ScrollContainer/VBox
	
	container.get_node("Floor1").pressed.connect(_on_floor_selected.bind(1, "Floor 1"))
	container.get_node("Floor2").pressed.connect(_on_floor_selected.bind(2, "Floor 2"))
	container.get_node("Floor3").pressed.connect(_on_floor_selected.bind(3, "Floor 3"))
	container.get_node("Floor4").pressed.connect(_on_floor_selected.bind(4, "Floor 4"))
	container.get_node("Floor5").pressed.connect(_on_floor_selected.bind(5, "Floor 5"))
	container.get_node("Floor6").pressed.connect(_on_floor_selected.bind(6, "Floor 6"))
	container.get_node("Floor7").pressed.connect(_on_floor_selected.bind(7, "Floor 7"))
	container.get_node("Floor8").pressed.connect(_on_floor_selected.bind(8, "Floor 8"))
	container.get_node("Floor9").pressed.connect(_on_floor_selected.bind(9, "Floor 9"))
	container.get_node("Floor10").pressed.connect(_on_floor_selected.bind(10, "Floor 10"))
	container.get_node("Floor11").pressed.connect(_on_floor_selected.bind(11, "Floor 11"))
	container.get_node("Floor12").pressed.connect(_on_floor_selected.bind(12, "Floor 12"))
	container.get_node("Floor13").pressed.connect(_on_floor_selected.bind(13, "Floor 13"))
	container.get_node("Floor14").pressed.connect(_on_floor_selected.bind(14, "Floor 14"))
	container.get_node("Floor15").pressed.connect(_on_floor_selected.bind(15, "Floor 15"))
	container.get_node("Floor16").pressed.connect(_on_floor_selected.bind(16, "Floor 16"))
	container.get_node("Floor17").pressed.connect(_on_floor_selected.bind(17, "Floor 17"))
	container.get_node("Floor18").pressed.connect(_on_floor_selected.bind(18, "Floor 18"))
	container.get_node("Floor19").pressed.connect(_on_floor_selected.bind(19, "Floor 19"))
	container.get_node("Floor20").pressed.connect(_on_floor_selected.bind(20, "Floor 20"))
	container.get_node("Floor21").pressed.connect(_on_floor_selected.bind(21, "Floor 21: On Going..."))
	
	start_btn.text = "Choose Characters"
	start_btn.pressed.connect(_on_choose_characters_pressed)
	
	start_btn.disabled = true
	start_btn.modulate = Color(0.5, 0.5, 0.5) 
	
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	$ScrollContainer/VBox/Floor1.grab_focus()
	
	lock_floors()

func _on_floor_selected(floor_num: int, description: String):
	selected_floor = floor_num
	Global.current_tower_floor = floor_num
	
	start_btn.disabled = false
	start_btn.modulate = Color(1, 1, 1) 
	
	var reward = Global.floor_rewards.get(floor_num, {"small": 0, "crystal": 0})
	var is_cleared = Global.floors_cleared.has(floor_num)
	var text = "[b]" + description + "[/b]\n\n"
	
	if is_cleared:
		text += "Rewards: [color=green][CLAIMED][/color]\n"
		text += "[color=gray]"
		if reward["small"] > 0:
			text += "[img=25]%s[/img] %d  " % [GEM_ICON_PATH, reward["small"]]
		if reward["crystal"] > 0:
			text += "[img=25]%s[/img] %d" % [CRYSTAL_ICON_PATH, reward["crystal"]]
		text += "[/color]"
	else:
		text += "Rewards:\n"
		if reward["small"] > 0:
			text += "[img=25]%s[/img] %d  " % [GEM_ICON_PATH, reward["small"]]
		if reward["crystal"] > 0:
			text += "[img=25]%s[/img] %d" % [CRYSTAL_ICON_PATH, reward["crystal"]]
	
	desc_label.text = text

func _on_choose_characters_pressed():
	# CHANGE 4: Extra safety check
	if selected_floor == 0:
		return 
	print("Select a character")
	
	Global.from_tower_mode = true
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
