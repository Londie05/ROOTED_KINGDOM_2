extends Control

@onready var desc_label = $DescriptionPanel/Label
@onready var start_btn = $StartBattleButton
@onready var container = $ScrollContainer/VBox

var selected_floor: int = 0 

const GEM_ICON_PATH = "res://Asset/Backgrounds/gem_1.webp"
const CRYSTAL_ICON_PATH = "res://Asset/Backgrounds/gem_3.webp"

func _ready():
	# Loop through all 21 floors to connect signals automatically
	for i in range(1, 22):
		var node_name = "Floor" + str(i)
		if container.has_node(node_name):
			var btn = container.get_node(node_name)
			var floor_desc = "Floor" + str(i)
			if i == 21:
				floor_desc = "Floor 21: On Going..."
			
			btn.pressed.connect(_on_floor_selected.bind(i, floor_desc))
	
	$StartBattleButton/Label.text = "Choose Characters"
	start_btn.pressed.connect(_on_choose_characters_pressed)
	
	# Initial button state
	start_btn.disabled = true
	start_btn.modulate = Color(0.5, 0.5, 0.5) 
	
	lock_floors()
	
	# Wait for UI to initialize before scrolling
	await get_tree().process_frame
	await get_tree().process_frame
	
	focus_and_scroll_to_latest_floor()

func focus_and_scroll_to_latest_floor():
	var next_floor = 1
	
	# FILTER out the Strings (Chapters) so we only look at Integers (Floors)
	var tower_only_clears = Global.floors_cleared.filter(func(f): return f is int)
	
	if tower_only_clears.size() > 0:
		next_floor = tower_only_clears.max() + 1
		
	if next_floor > 21:
		next_floor = 21
		
	var target_btn_name = "Floor" + str(next_floor)
	
	if container.has_node(target_btn_name):
		var target_btn = container.get_node(target_btn_name)
		target_btn.grab_focus()
		$ScrollContainer.ensure_control_visible(target_btn)
		
		var desc = "Floor " + str(next_floor)
		if next_floor == 21:
			desc = "Floor 21: On Going..."
		_on_floor_selected(next_floor, desc)
		
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
	else:
		text += "Rewards:\n"
	
	if reward["small"] > 0:
		text += "[img=25]%s[/img] %d  " % [GEM_ICON_PATH, reward["small"]]
	if reward["crystal"] > 0:
		text += "[img=25]%s[/img] %d" % [CRYSTAL_ICON_PATH, reward["crystal"]]
	
	if is_cleared:
		text += "[/color]"
	
	desc_label.text = text

func _on_choose_characters_pressed():
	if selected_floor == 0:
		return 
	
	Global.from_tower_mode = true
	get_tree().change_scene_to_file("res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/start_battle.tscn")

func lock_floors():
	# 1. Find the highest floor actually cleared in the list
	var max_cleared = 0
	for f in Global.floors_cleared:
		if f is int:
			max_cleared = max(max_cleared, f)
	
	# 2. The player is allowed to play any floor up to max_cleared + 1
	var unlock_limit = max_cleared + 1

	for i in range(1, 1):
		var node_name = "Floor" + str(i)
		if container.has_node(node_name):
			var btn = container.get_node(node_name)
			
			# A floor is unlocked if its number is <= our limit
			var is_unlocked = (i <= unlock_limit)
			
			btn.disabled = not is_unlocked
			
			# Visual feedback
			if is_unlocked:
				btn.modulate = Color(1, 1, 1) # Bright
			else:
				btn.modulate = Color(0.3, 0.3, 0.3) # Darkened
