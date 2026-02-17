extends Control

# --- NODES ---
@onready var background: TextureRect = $Background
@onready var beatrice: TextureRect = $CharContainer/Beatrice
@onready var charlotte: TextureRect = $CharContainer/Charlotte
@onready var cursed_monster: TextureRect = $CharContainer/CursedMonster 
@onready var dialogue_ui = $"Dialogue Interface"
@onready var end_chapter_popup = $EndChapterPopup 

var min_line_index: int = 0
var current_line_index: int = 0
var is_chapter_finished: bool = false

# --- THE STORY SCRIPT ---
var story_script = [
	{ "bg": "ruins", "speaker": "", "text": "Beatrice and Charlotte began scavenging the camp. You volunteered to help, but they used magic to find objects." },
	{ "speaker": "Beatrice", "text": "You can stop now. We got all we needed.", "show": ["Beatrice", "Charlotte"], "focus": "Beatrice" },
	{ "speaker": "", "text": "This ruined your moment. All you found was a ruined sword from a Cursed Monster's corpse." },
	{ "speaker": "Hero", "text": "Where are the things you scavenge? You're only carrying that tiny pouch." },
	{ "speaker": "Beatrice", "text": "All of them are here.", "focus": "Beatrice", "anim": "jump_beatrice" },
	{ "speaker": "Hero", "text": "That's a purse! Only coins would fit in there." },
	{ "speaker": "Beatrice", "text": "We did scavenge, though? Does the word have a different meaning in your world?", "focus": "Beatrice" },
	{ "speaker": "Charlotte", "text": "Honestly, #Name, what are you talking about?", "focus": "Charlotte" },
	{ "speaker": "", "text": "Charlotte took the sword from your hand and placed it in the purse. It vanished inside without poking out." },
	{ "speaker": "Hero", "text": "W-What the hell is that thing??!!" },
	{ "speaker": "Charlotte", "text": "This is Schrodinger's purse. It stores objects endlessly, but it gets heavy emotionally.", "focus": "Charlotte" },
	{ "speaker": "Hero", "text": "Don't you think it should be called a Hawking pouch instead?" },

	{ "bg": "steppe", "speaker": "", "text": "Moments later, you left the camp and started walking through a vast grass field." },
	{ "speaker": "Hero", "text": "How can she tell the path in this field?", "focus": "Hero" },
	{ "speaker": "Charlotte", "text": "She has a mental compass. She uses magic to know the path precisely.", "focus": "Charlotte" },
	{ "speaker": "Hero", "text": "That sounds like a cheat. But isn't it tiring?" },
	{ "speaker": "Charlotte", "text": "She has the highest mental fortitude and a huge mana capacity. She's the real deal.", "focus": "Charlotte" },

	{ "speaker": "Beatrice", "text": "Beatrice, there's a group of Cursed Monsters nearby.", "focus": "Beatrice" },
	{ "speaker": "Charlotte", "text": "Leave it to me.", "focus": "Charlotte", "anim": "exit_right" },
	{ "speaker": "", "text": "[ Stage 1-2 Battle Start ]", "stage": "1-2" },

	{ "speaker": "", "text": "The smoke faded. Charlotte stood over the Cursed Monsters, blood on her staff. You began to cower, realizing how weak you are." },
	{ "speaker": "Hero", "text": "CHARLOTTE! THERE'S A CURSED MONSTER RUN—" },
	{ "speaker": "Beatrice", "text": "Don't worry about it. That's intentional. He'll lead us to a better camp.", "focus": "Beatrice" },

	{ "bg": "steppe", "speaker": "", "text": "You felt a wind behind you. You turned around and saw a Cursed Monster in adorned clothes holding an orb staff." },
	{ "speaker": "", "text": "You tried to run, but slipped. Translucent chains tied your ankles to the ground.", "anim": "shake_screen" },
	{ "speaker": "Cursed Monster", "text": "Whatchu doin' here, outsider? Ain't ya supposed to be eaten now?", "show": ["CursedMonster"], "focus": "CursedMonster" },
	{ "speaker": "Hero", "text": "AHHHHHHHHHHHHH!", "anim": "shake_screen" },
	{ "speaker": "Beatrice", "text": "YOU CURSED MONSTER—!!!", "anim": "enter_left", "show": ["Beatrice", "CursedMonster"], "focus": "Beatrice" },
	{ "speaker": "Beatrice", "text": "How do you do? You don't have to answer... but you can trust me. I can handle this.", "focus": "Beatrice" },
	{ "speaker": "Beatrice", "text": "Pardon me but... this day will be your last.", "anim": "float_beatrice" },
	{ "speaker": "", "text": "[ Stage 1-4: Beatrice vs Cursed Monster ]", "stage": "1-4" },
	{ "speaker": "Beatrice", "text": "Impact!", "anim": "white_flash" },

	{ "bg": "sunset_sky", "speaker": "Charlotte", "text": "I found their airboat!", "show": ["Beatrice", "Charlotte"], "focus": "Charlotte" },
	{ "speaker": "", "text": "You boarded the boat. It elevated through the clouds, revealing a mesmerising view of the Age of Discovery." },
	{ "speaker": "Beatrice", "text": "Can you tell me more about your world?", "focus": "Beatrice" },
	{ "speaker": "Hero", "text": "I'm truly in another world..." }
]

func _ready():
	if dialogue_ui:
		dialogue_ui.next_line_requested.connect(_load_next_line)
		dialogue_ui.prev_line_requested.connect(_load_prev_line)
	
	if Global.just_finished_battle:
		Global.just_finished_battle = false
		current_line_index = Global.story_line_resume_index + 1
		min_line_index = current_line_index
	else:
		current_line_index = 0
		min_line_index = 0
		
	# Initial visibility
	cursed_monster.visible = false
	_load_current_line()

func _load_next_line():
	if is_chapter_finished: return 
	
	var current_data = story_script[current_line_index]
	if "stage" in current_data:
		start_story_battle(current_data["stage"])
		return

	if current_line_index < story_script.size() - 1:
		current_line_index += 1
		_load_current_line()
	else:
		_show_completion_popup()

func _load_prev_line():
	if is_chapter_finished: return 
	if current_line_index > min_line_index:
		current_line_index -= 1
		_load_current_line()

func _load_current_line():
	if current_line_index < 0 or current_line_index >= story_script.size():
		return
		
	var data = story_script[current_line_index]
	
	var d_text = data["text"].replace("#Name", Global.player_name)
	var d_speaker = data["speaker"].replace("Hero", Global.player_name)
	
	dialogue_ui.show_line(d_speaker, d_text)
	
	if "bg" in data: _change_bg(data["bg"])
	
	if "show" in data:
		beatrice.visible = "Beatrice" in data["show"]
		charlotte.visible = "Charlotte" in data["show"]
		cursed_monster.visible = "CursedMonster" in data["show"]
	
	if "focus" in data: _apply_focus(data["focus"])
	if "anim" in data: _play_anim(data["anim"])

func _apply_focus(speaker):
	var dark = Color(0.5, 0.5, 0.5)
	beatrice.modulate = Color.WHITE if speaker == "Beatrice" else dark
	charlotte.modulate = Color.WHITE if speaker == "Charlotte" else dark
	cursed_monster.modulate = Color.WHITE if speaker == "CursedMonster" else dark

func _play_anim(anim_name):
	var tween = create_tween()
	match anim_name:
		"jump_beatrice":
			tween.tween_property(beatrice, "position:y", beatrice.position.y - 40, 0.1)
			tween.tween_property(beatrice, "position:y", beatrice.position.y, 0.1)
		
		"exit_right":
			tween.tween_property(charlotte, "position:x", 1500, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		
		"enter_left":
			beatrice.position.x = -500
			beatrice.visible = true
			tween.tween_property(beatrice, "position:x", 150, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		
		"float_beatrice":
			# Infinite floating effect
			var float_tween = create_tween().set_loops()
			float_tween.tween_property(beatrice, "position:y", beatrice.position.y - 20, 1.0).set_trans(Tween.TRANS_SINE)
			float_tween.tween_property(beatrice, "position:y", beatrice.position.y, 1.0).set_trans(Tween.TRANS_SINE)

		"shake_screen":
			var orig_pos = self.position
			for i in range(6):
				tween.tween_property(self, "position", orig_pos + Vector2(randf_range(-10,10), randf_range(-10,10)), 0.05)
			tween.tween_property(self, "position", orig_pos, 0.05)
		
		"white_flash":
			var flash = ColorRect.new()
			flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			flash.color = Color.WHITE
			add_child(flash)
			tween.tween_property(flash, "modulate:a", 0, 0.5)
			tween.tween_callback(flash.queue_free)

func _change_bg(bg_name):
	match bg_name:
		"ruins": background.texture = preload("res://Asset/User Interface/tower_mod_background_v2.jpg")
		"steppe": background.texture = preload("res://Asset/User Interface/%Storymode%/black_background.jpg")
		"sunset_sky": background.texture = preload("res://Asset/User Interface/%Storymode%/Rollings Plains.jpg")

func start_story_battle(stage_id: String):
	Global.current_game_mode = Global.GameMode.STORY
	Global.last_story_scene_path = self.scene_file_path 
	Global.story_line_resume_index = current_line_index
	Global.current_battle_stage = stage_id
	Global.loading_target_scene = "res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn"
	get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")

func _show_completion_popup():
	if is_chapter_finished: return
	is_chapter_finished = true 
	end_chapter_popup.setup_popup("Chapter 2 Complete!", "Next Chapter", "Back to Menu", 1.0)
	if not end_chapter_popup.confirmed.is_connected(_on_next_pressed):
		end_chapter_popup.confirmed.connect(_on_next_pressed)
	if not end_chapter_popup.cancelled.is_connected(_on_back_pressed):
		end_chapter_popup.cancelled.connect(_on_back_pressed)
	end_chapter_popup.show_popup()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/StoryMode.tscn")
	
func _on_next_pressed():
	# get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/Chapter Scenes/Chapter3.tscn")
	pass
