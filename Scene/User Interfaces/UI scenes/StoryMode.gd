extends Control

@onready var desc_panel = $ChapterDescriptionPanel
@onready var title_label = $ChapterDescriptionPanel/TitleLabel
@onready var reward_label = $ChapterDescriptionPanel/RewardLabel
@onready var start_button = $ChapterDescriptionPanel/StartButton

var selected_scene_path: String = ""
var selected_chapter_id: String = "" # Used for badges

func _ready():
	desc_panel.visible = false
	start_button.pressed.connect(_on_start_pressed)
	_update_clear_badges()
	
	# AUTOMATIC CONNECTION: This ensures every button in your list works!
	var container = $ScrollContainer/HBoxContainer
	for child in container.get_children():
		if child.has_signal("pressed"):
			# Disconnect old ones if they exist to avoid double-firing
			if child.pressed.is_connected(handle_chapter_click):
				child.pressed.disconnect(handle_chapter_click)
			# Connect the button to the handler and pass the button itself as an argument
			child.pressed.connect(handle_chapter_click.bind(child))

func handle_chapter_click(button_node):
	# DEBUG: Run the game and check the Output console to see if this prints!
	print("Clicked: ", button_node.chapter_title)
	
	var clicked_id = button_node.chapter_title.replace(" ", "")
	
	if desc_panel.visible and selected_chapter_id == clicked_id:
		desc_panel.visible = false
		selected_chapter_id = ""
		return
	
	desc_panel.visible = true
	title_label.text = button_node.chapter_title
	reward_label.text = "Rewards: " + button_node.rewards 
	selected_scene_path = button_node.target_scene
	selected_chapter_id = clicked_id

func _on_start_pressed():
	if selected_scene_path == "":
		print("No chapter selected!")
		return
		
	Global.loading_target_scene = selected_scene_path
	
	# Set the Chapter Number for Loading Screen logic
	if "Chapter1" in selected_scene_path or "Chapter 1" in selected_scene_path:
		Global._CURRENTLY_PLAYING_CHAPTER = 1
	elif "Chapter2" in selected_scene_path or "Chapter 2" in selected_scene_path:
		Global._CURRENTLY_PLAYING_CHAPTER = 2
	elif "Chapter3" in selected_scene_path or "Chapter 3" in selected_scene_path:
		Global._CURRENTLY_PLAYING_CHAPTER = 3
	
	get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")

func _update_clear_badges():
	var container = $ScrollContainer/HBoxContainer
	
	for i in range(1, 5): # Check chapters 1 through 4
		var key = "Chapter" + str(i)
		var chapter_node = container.get_node_or_null(key)
		
		if chapter_node:
			var badge_panel = chapter_node.get_node("ClearedBadgePanel")
			var badge_label = badge_panel.get_node("ClearedBadgeLabel")
			var block_panel = chapter_node.get_node("Panel") 
			
			if Global.story_chapters_cleared.has(key):
				badge_label.text = "[center][color=green]Chapter cleared[/color][/center]"
				block_panel.visible = false 
				badge_panel.visible = true
			else:
				badge_label.text = "[center][color=red]Not cleared[/color][/center]"
				badge_panel.visible = true

				if i == 1:
					block_panel.visible = false
				else:
					var prev_key = "Chapter" + str(i - 1)
					if Global.story_chapters_cleared.has(prev_key):
						block_panel.visible = false # Unlock it!
					else:
						block_panel.visible = true # Stay blocked!

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/start_battle.tscn")
