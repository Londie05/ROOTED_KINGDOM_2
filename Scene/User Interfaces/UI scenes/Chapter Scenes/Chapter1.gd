extends Control

var reward_gems: int = 500
var reward_crystals: int = 10

# --- NODES ---
@onready var end_chapter_popup = $EndChapterPopup
@onready var background: TextureRect = $Background
@onready var beatrice: TextureRect = $CharContainer/Beatrice
@onready var charlotte: TextureRect = $CharContainer/Charlotte
@onready var dialogue_ui = $"Dialogue Interface" 
@onready var quit_button = $QuitButton
# --- VARIABLES ---
var min_line_index: int = 0

var current_line_index: int = 0
var is_chapter_finished: bool = false

# --- THE STORY SCRIPT ---
var story_script = [
	{ "bg": "black", "speaker": "", "text": "Cursed Monsters look at you with lustrous eyes; their mouths drooling an abnormal amount of saliva." },
	{ "speaker": "", "text": "They are clearly craving—at you." },
	{ "speaker": "", "text": "Holding knives and axes, the Cursed Monsters began approaching your position." },
	{ "speaker": "", "text": "A grin can be seen on their faces as they anticipate their eventual satiation, and your inevitable demise." },
	{ "speaker": "", "text": "Pushing your body with your feet little by little, you began dragging yourself back away from them." },
	{ "speaker": "", "text": "Then—" },
	{ "speaker": "", "text": "Your world was engulfed in smoke and obscured your eyes.", "anim": "smoke_effect" },
	{ "speaker": "", "text": "You covered your eyes to prevent the smoke from touching them." },
	{ "speaker": "", "text": "And as you contemplated on your own predicament, you began hearing the sounds of metal clashing..." },
	{ "bg": "battle", "speaker": "", "text": "A battle ensued around you.", "anim": "shake_screen", "action": "start_battle" }, 
	{ "bg": "ruins", "speaker": "", "text": "The smoke suddenly disappeared. Your vision began seeing the light." },
	{ "speaker": "", "text": "You looked around and found the place in ruins. Corpses of dead Cursed Monsters laid on the ground—" },
	{ "speaker": "", "text": "And the remains of wreckage scattered around. It was a full-blown attack." },
	{ "speaker": "", "text": "And emerged before you two ladies, each holding a staff. They looked at you dumbfounded." },
	{ "speaker": "Beatrice", "text": "Have you seen those kinds of clothes?", "show": ["Beatrice"], "anim": "enter_left" },
	{ "speaker": "Charlotte", "text": "Nope. I haven't seen anyone wearing clothes like that at all.", "show": ["Beatrice", "Charlotte"], "anim": "enter_right" },
	{ "speaker": "", "text": "The latte brown-haired and the green-haired woman continued their brainstorming." },
	{ "speaker": "Beatrice", "text": "Perhaps he's from a royal family?", "focus": "Beatrice" },
	{ "speaker": "Charlotte", "text": "Not that either. He lacks the features that would make someone royalty. Appearance-wise, he is completely average.", "focus": "Charlotte" },
	{ "speaker": "Beatrice", "text": "You don't have to say it like that...", "focus": "Beatrice" },
	{ "speaker": "Charlotte", "text": "I mean, his face isn't that attractive...", "focus": "Charlotte" },
	{ "speaker": "", "text": "Hearing their words, your heart broke at the utterances of your mediocrity." },
	{ "speaker": "Hero", "text": "Umm... I'm here, you know?" },
	{ "speaker": "", "text": "The two women look at you dumbfounded once again. But Beatrice went into shock and covered her face in embarrassment.", "anim": "shake_beatrice" },
	{ "speaker": "Charlotte", "text": "Well, what are you doing here anyways?" },
	{ "speaker": "Hero", "text": "Doing here, you say..." },
	{ "speaker": "", "text": "You couldn't make sense of the question. It's not like you went here yourself." },
	{ "speaker": "Hero", "text": "Well, you see, I suddenly got here. I was doing my own thing, then, BOOM! I was suddenly surrounded by Cursed Monsters." },
	{ "speaker": "", "text": "Charlotte sighed and held her forehead on your poor attempt at recalling the events." },
	{ "speaker": "Charlotte", "text": "What kind of explanation is that?" },
	{ "speaker": "", "text": "Meanwhile, Beatrice did something. You saw the pink light glowing from her." },
	{ "speaker": "Beatrice", "text": "He was summoned here. I sensed a huge amount of holy magic in the entire camp.", "focus": "Beatrice" },
	{ "speaker": "Charlotte", "text": "How could Cursed Monsters do that? I haven't encountered a shaman in this camp.", "focus": "Charlotte" },
	{ "speaker": "Beatrice", "text": "The Cursed Monster must have just discovered how to use holy magic recently. He must be their first summonee." },
	{ "speaker": "Charlotte", "text": "Summonee? Don't tell me..." },
	{ "speaker": "Beatrice", "text": "I got the same conclusion. He was summoned to be their 'lunch'." },
	{ "speaker": "Hero", "text": "W-What do you mean dinner?!", "anim": "shake_screen" },
	{ "speaker": "Charlotte", "text": "There have been rumors that Cursed Monsters summoned a person and ate them. In conclusion, you were brought here to be their food." },
	{ "speaker": "Charlotte", "text": "You're a lucky one. You are the proof that that rumor is true. People before you aren't lucky enough to be evidence." },
	{ "speaker": "", "text": "You jolted in shock. Your body began shaking at the thought that you were summoned to be a feast." },
	{ "speaker": "Hero", "text": "Is this how my isekai journey would start?" },
	{ "speaker": "Beatrice & Charlotte", "text": "Isekai?", "anim": "jump_both" }, 
	{ "speaker": "Charlotte", "text": "Anyways, what should we do with him?" },
	{ "speaker": "Beatrice", "text": "Bring him to the Republic, of course. We need proof that the rumors are true." },
	{ "speaker": "Charlotte", "text": "Is he enough to be considered evidence?" },
	{ "speaker": "Beatrice", "text": "Yup. He doesn't possess mana. He's coated in holy magic from the summoning. He's the best evidence we have here." },
	{ "speaker": "Charlotte", "text": "But how are we going to carry him? We travel by flying, you know?" },
	{ "speaker": "Beatrice", "text": "You're right..." },
	{ "speaker": "", "text": "Seeing the opportunity, you raised your hand." },
	{ "speaker": "Hero", "text": "Erm... Thanks for saving me, but maybe you guys could just leave me here?" },
	{ "speaker": "Beatrice", "text": "NO! You're in the Cursed Monster Zone. You're safe with us!", "anim": "shake_beatrice" },
	{ "speaker": "Charlotte", "text": "Beatrice..." },
	{ "speaker": "Beatrice", "text": "You're coming with us, okay?" },
	{ "speaker": "Charlotte", "text": "Give it up, man. She's not gonna let you go." },
	{ "speaker": "Hero", "text": "I'm just a stranger, you know? How can I be certain that you two deserve my trust?" },
	{ "speaker": "Beatrice", "text": "Well, I'm Beatrice, a scavenger. Nice to meet you." },
	{ "speaker": "Hero", "text": "Erm..." },
	{ "speaker": "Charlotte", "text": "And I'm Charlotte, nice to meet you as well!" },
	{ "speaker": "Hero", "text": "It's not like there's a guarantee that I'll be safe on my own here, right?" },
	{ "speaker": "Hero", "text": "Well, I'm..." },
	{ "speaker": "#Name", "text": "...I'm #Name. Nice to meet the two of you." },
	{ "speaker": "Hero", "text": "Looks like I'll leave everything to you, ladies." },
	{ "speaker": "Beatrice", "text": "#Name... thank you, for trusting me." }
]

# --- CORE FUNCTIONS ---

func _ready():
	if quit_button:
		quit_button.pressed.connect(_on_quit_attempt)
		
	if dialogue_ui:
		dialogue_ui.next_line_requested.connect(_load_next_line)
		dialogue_ui.prev_line_requested.connect(_load_prev_line)
	
	# Initial state
	background.modulate = Color.BLACK
	beatrice.visible = false
	charlotte.visible = false
	
	# --- RESUME LOGIC ---
	if Global.just_finished_battle:
		Global.just_finished_battle = false 
		current_line_index = Global.story_line_resume_index + 1
		min_line_index = current_line_index
		
		# <--- ADD THIS LINE HERE to trigger the flash when returning
		_trigger_white_flash() 
		
	else:
		current_line_index = 0
	
	_load_current_line()

func _trigger_white_flash():
	var flash = ColorRect.new()
	flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	flash.color = Color.WHITE
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE 
	add_child(flash)
	
	# Fade out
	var tween = create_tween()
	tween.tween_property(flash, "modulate:a", 0.0, 1.0) # Fades out in 1.0 second
	tween.tween_callback(flash.queue_free) # Delete it when done
	
func _on_quit_attempt():
	# We repurpose the EndChapterPopup for a "Quit Confirmation"
	# setup_popup(Title, ConfirmText, CancelText, BlurValue)
	
	# Disconnect existing signals to prevent double-firing or wrong logic
	if end_chapter_popup.confirmed.is_connected(_on_next_chapter_pressed):
		end_chapter_popup.confirmed.disconnect(_on_next_chapter_pressed)
	if end_chapter_popup.cancelled.is_connected(_on_back_to_menu_pressed):
		end_chapter_popup.cancelled.disconnect(_on_back_to_menu_pressed)
		
	# Connect NEW signals for quitting
	end_chapter_popup.setup_popup("Quit Chapter? Your progress won't be saved", "Yes, Quit", "Stay", 1.0)
	
	end_chapter_popup.confirmed.connect(_confirm_quit)
	end_chapter_popup.cancelled.connect(_cancel_quit)
	
	end_chapter_popup.show_popup()

func _confirm_quit():
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/StoryMode.tscn")
	
func _cancel_quit():
	# Just hide the popup, the game continues
	end_chapter_popup.hide() 
	# Re-enable UI if you disabled it
	if dialogue_ui.has_method("set_active"):
		dialogue_ui.set_active(true)
		
func _load_next_line():
	if is_chapter_finished: return 
	
	# Check if CURRENT line was a battle trigger
	var current_data = story_script[current_line_index]
	if "action" in current_data and current_data["action"] == "start_battle":
		start_story_battle()
		return # Stop loading next line, we are leaving the scene
	
	if current_line_index < story_script.size() - 1:
		current_line_index += 1
		_load_current_line()
	else:
		_show_completion_popup()

func start_story_battle():
	Global.current_game_mode = Global.GameMode.STORY
	Global.from_tower_mode = false 
	Global.last_story_scene_path = self.scene_file_path 
	Global.story_line_resume_index = current_line_index
	
	Global.current_battle_stage = "1-1"
	
	Global.loading_target_scene = "res://Scene/User Interfaces/CharacterScenes/CharacterSelection.tscn"
	get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
	
func _load_prev_line():
	if is_chapter_finished: return # Safety Lock
	
	if current_line_index > min_line_index:
		current_line_index -= 1
		_load_current_line()

func _load_current_line():
	if current_line_index >= story_script.size(): return
	
	var data = story_script[current_line_index]
	
	# --- CHECK FOR BATTLE ---
	if "action" in data and data["action"] == "start_battle":
		dialogue_ui.show_line(data.get("speaker", ""), data["text"])
	else:
		var display_text = data["text"].replace("#Name", Global.player_name)
		var display_speaker = data["speaker"].replace("#Name", Global.player_name)
		if display_speaker == "Hero":
			display_speaker = Global.player_name
		dialogue_ui.show_line(display_speaker, display_text)
			
	# 2. Handle Backgrounds
	if "bg" in data:
		background.modulate = Color.WHITE 
		match data["bg"]:
			"black":
				background.modulate = Color.BLACK
			"ruins":
				background.texture = load("res://Asset/User Interface/%Storymode%/scene 1.jpg")
			"battle":
				background.texture = load("res://Asset/User Interface/%Storymode%/scene 2.jpg")
			"forest":
				background.texture = load("res://Asset/User Interface/%Storymode%/black_background.jpg")

	# Handle Character Visibility
	if "show" in data:
		beatrice.visible = "Beatrice" in data["show"]
		charlotte.visible = "Charlotte" in data["show"]
	
	# Handle Focus/Darkening
	if "focus" in data:
		_apply_focus(data["focus"])
	
	# Handle Animations
	if "anim" in data:
		_play_anim(data["anim"])

# --- POPUP LOGIC ---
func _show_completion_popup():
	if is_chapter_finished: return
	is_chapter_finished = true
	
	var reward_text = ""
	
	# --- ANTI-FARMING LOGIC ---
	if not Global.floors_cleared.has("Chapter1"): 
		Global.small_gems += reward_gems
		Global.crystal_gems += reward_crystals
		
		Global.floors_cleared.append("Chapter1")
		
		Global.save_game()
		
		reward_text = "\nREWARDS EARNED:\n+%d Gems\n+%d Crystals" % [reward_gems, reward_crystals]
	else:
		reward_text = "\n(Chapter already cleared - No rewards)"

	# --- UI LOGIC ---
	if dialogue_ui.has_method("set_active"):
		dialogue_ui.set_active(false)

	end_chapter_popup.setup_popup(
		"Chapter 1 Complete!" + reward_text, 
		"Next Chapter", 
		"Back to Selection", 
		1.0
	)
	
	if not end_chapter_popup.confirmed.is_connected(_on_next_chapter_pressed):
		end_chapter_popup.confirmed.connect(_on_next_chapter_pressed)
	if not end_chapter_popup.cancelled.is_connected(_on_back_to_menu_pressed):
		end_chapter_popup.cancelled.connect(_on_back_to_menu_pressed)
	
	end_chapter_popup.show_popup()

func _on_next_chapter_pressed():
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/Chapter Scenes/Chapter2.tscn")	

func _on_back_to_menu_pressed():
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/StoryMode.tscn")

# --- VISUAL EFFECTS ---

func _apply_focus(speaker_name: String):
	var tween = create_tween().set_parallel(true)
	var dark = Color(0.5, 0.5, 0.5, 1.0)
	var bright = Color.WHITE
	
	tween.tween_property(beatrice, "modulate", bright if speaker_name == "Beatrice" else dark, 0.3)
	tween.tween_property(charlotte, "modulate", bright if speaker_name == "Charlotte" else dark, 0.3)

func _play_anim(anim_name: String):
	var tween = create_tween()
	match anim_name:
		"white_flash": # <--- Add this option here too so you can use it in script
			_trigger_white_flash()
			
		"enter_left":
			beatrice.position.x = -300
			beatrice.visible = true
			tween.tween_property(beatrice, "position:x", 150, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		"enter_right":
			charlotte.position.x = 1300
			charlotte.visible = true
			tween.tween_property(charlotte, "position:x", 850, 0.5).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_OUT)
		"shake_screen":
			var orig_pos = position
			for i in range(6):
				tween.tween_property(self, "position", orig_pos + Vector2(randf_range(-10,10), randf_range(-10,10)), 0.05)
			tween.tween_property(self, "position", orig_pos, 0.05)
		"shake_beatrice":
			var b_pos = beatrice.position.x
			tween.tween_property(beatrice, "position:x", b_pos + 20, 0.05)
			tween.tween_property(beatrice, "position:x", b_pos - 20, 0.05)
			tween.tween_property(beatrice, "position:x", b_pos, 0.05)
		"jump_both":
			var b_y = beatrice.position.y
			var c_y = charlotte.position.y
			var t = create_tween().set_parallel(true)
			t.tween_property(beatrice, "position:y", b_y - 30, 0.1).set_trans(Tween.TRANS_SINE)
			t.tween_property(charlotte, "position:y", c_y - 30, 0.1).set_trans(Tween.TRANS_SINE)
			t.chain().tween_property(beatrice, "position:y", b_y, 0.1)
			t.parallel().tween_property(charlotte, "position:y", c_y, 0.1)
