extends Control

# --- NODES ---
@onready var background: TextureRect = $Background
@onready var beatrice: TextureRect = $CharContainer/Beatrice
@onready var charlotte: TextureRect = $CharContainer/Charlotte
@onready var dialogue_ui = $"Dialogue Interface"
@onready var end_chapter_popup = $EndChapterPopup 

var current_line_index: int = 0
var is_chapter_finished: bool = false
# --- THE STORY SCRIPT ---
var story_script = [
	# SCENE 1: SCAVENGING
	{ "bg": "ruins", "speaker": "", "text": "Beatrice and Charlotte began scavenging the camp. You volunteered to help, but they used magic to find objects." },
	{ "speaker": "Beatrice", "text": "You can stop now. We got all we needed.", "show": ["Beatrice", "Charlotte"], "focus": "Beatrice" },
	{ "speaker": "", "text": "This ruined your moment. All you found was a ruined sword from a goblin's corpse." },
	{ "speaker": "Hero", "text": "Where are the things you scavenge? You're only carrying that tiny pouch." },
	{ "speaker": "Beatrice", "text": "All of them are here.", "focus": "Beatrice", "anim": "jump_beatrice" },
	{ "speaker": "Hero", "text": "That's a purse! Only coins would fit in there." },
	{ "speaker": "Beatrice", "text": "We did scavenge, though? Does the word have a different meaning in your world?", "focus": "Beatrice" },
	{ "speaker": "Charlotte", "text": "Honestly, #Name, what are you talking about?", "focus": "Charlotte" },
	{ "speaker": "", "text": "Charlotte took the sword from your hand and placed it in the purse. It vanished inside without poking out." },
	{ "speaker": "Hero", "text": "W-What the hell is that thing??!!" },
	{ "speaker": "Charlotte", "text": "This is Schrodinger's purse. It stores objects endlessly, but it gets heavy emotionally.", "focus": "Charlotte" },
	{ "speaker": "Hero", "text": "Don't you think it should be called a Hawking pouch instead?" },

	# SCENE 2: THE GRASSY FIELD
	{ "bg": "steppe", "speaker": "", "text": "Moments later, you left the camp and started walking through a vast grass field." },
	{ "speaker": "Hero", "text": "How can she tell the path in this field?", "focus": "Hero" },
	{ "speaker": "Charlotte", "text": "She has a mental compass. She uses magic to know the path precisely.", "focus": "Charlotte" },
	{ "speaker": "Hero", "text": "That sounds like a cheat. But isn't it tiring?" },
	{ "speaker": "Charlotte", "text": "She has the highest mental fortitude and a huge mana capacity. She's the real deal.", "focus": "Charlotte" },

	# BATTLE TRANSITION
	{ "speaker": "Beatrice", "text": "Beatrice, there's a group of goblins nearby.", "focus": "Beatrice" },
	{ "speaker": "Charlotte", "text": "Leave it to me.", "focus": "Charlotte", "anim": "exit_right" },
	{ "speaker": "", "text": "[ Stage 1-2 Battle Start ]", "stage": "1-2" },

	# AFTERMATH
	{ "speaker": "", "text": "The smoke faded. Charlotte stood over the goblins, blood on her staff. You began to cower, realizing how weak you are." },
	{ "speaker": "Hero", "text": "CHARLOTTE! THERE'S A GOBLIN RUN—" },
	{ "speaker": "Beatrice", "text": "Don't worry about it. That's intentional. He'll lead us to a better camp.", "focus": "Beatrice" },

	# SCENE 3: THE AMBUSH
	{ "bg": "steppe", "speaker": "", "text": "You felt a wind behind you. You turned around and saw a goblin in adorned clothes holding an orb staff." },
	{ "speaker": "", "text": "You tried to run, but slipped. Translucent chains tied your ankles to the ground.", "anim": "shake_screen" },
	{ "speaker": "Goblin Shaman", "text": "Whatchu doin' here, outsider? Ain't ya supposed to be eaten now?" },
	{ "speaker": "Hero", "text": "AHHHHHHHHHHHHH!", "anim": "shake_screen" },
	{ "speaker": "Beatrice", "text": "YOU GOBLIN—!!!", "anim": "enter_left", "focus": "Beatrice" },
	{ "speaker": "Beatrice", "text": "How do you do? You don't have to answer... but you can trust me. I can handle this.", "focus": "Beatrice" },
	{ "speaker": "Beatrice", "text": "Pardon me but... this day will be your last.", "anim": "float_beatrice" },
	{ "speaker": "", "text": "[ Stage 1-4: Beatrice vs Shaman ]", "stage": "1-4" },
	{ "speaker": "Beatrice", "text": "Impact!", "anim": "white_flash" },

	# SCENE 4: THE AIRBOAT
	{ "bg": "sunset_sky", "speaker": "Charlotte", "text": "I found their airboat!", "show": ["Beatrice", "Charlotte"], "focus": "Charlotte" },
	{ "speaker": "", "text": "You boarded the boat. It elevated through the clouds, revealing a mesmerising view of the Age of Discovery." },
	{ "speaker": "Beatrice", "text": "Can you tell me more about your world?", "focus": "Beatrice" },
	{ "speaker": "Hero", "text": "I'm truly in another world..." }
]

func _ready():
	if dialogue_ui:
		dialogue_ui.next_line_requested.connect(_load_next_line)
		dialogue_ui.prev_line_requested.connect(_load_prev_line)
	
	_load_current_line()

func _load_next_line():
	if is_chapter_finished: return 
	
	if current_line_index < story_script.size() - 1:
		current_line_index += 1
		_load_current_line()
	else:
		_show_completion_popup()

func _load_prev_line():
	if is_chapter_finished: return 
	
	if current_line_index > 0:
		current_line_index -= 1
		_load_current_line()

func _load_current_line():
	if current_line_index < 0 or current_line_index >= story_script.size():
		return
	var data = story_script[current_line_index]
	
	# Text with Global Name replacement
	var d_text = data["text"].replace("#Name", Global.player_name)
	var d_speaker = data["speaker"].replace("Hero", Global.player_name)
	
	dialogue_ui.show_line(d_speaker, d_text)
	
	# Handle Backgrounds
	if "bg" in data:
		_change_bg(data["bg"])
	
	# Handle Focus/Characters
	if "show" in data:
		beatrice.visible = "Beatrice" in data["show"]
		charlotte.visible = "Charlotte" in data["show"]
	
	if "focus" in data:
		_apply_focus(data["focus"])
	
	# Check for Battle Stage
	if "stage" in data:
		print("Logic for Battle Stage " + data["stage"] + " goes here!")

func _change_bg(bg_name):
	match bg_name:
		"ruins": background.texture = preload("res://Asset/User Interface/tower_mod_background_v2.jpg")
		"steppe": background.texture = preload("res://Asset/User Interface/%Storymode%/black_background.jpg")
		"sunset_sky": background.texture = preload("res://Asset/User Interface/%Storymode%/Rollings Plains.jpg")

func _apply_focus(speaker):
	var dark = Color(0.6, 0.6, 0.6)
	beatrice.modulate = Color.WHITE if speaker == "Beatrice" else dark
	charlotte.modulate = Color.WHITE if speaker == "Charlotte" else dark

func _show_completion_popup():
	# Prevent the popup from being set up multiple times if spammed
	if is_chapter_finished: return
	is_chapter_finished = true 
	
	end_chapter_popup.setup_popup("Chapter 2 Complete!", "Next Chapter", "Back to Menu", 1.0)
	
	if not end_chapter_popup.confirmed.is_connected(_on_next_pressed):
		end_chapter_popup.confirmed.connect(_on_next_pressed)
	if not end_chapter_popup.cancelled.is_connected(_on_back_pressed):
		end_chapter_popup.cancelled.connect(_on_back_pressed)
	
	end_chapter_popup.show_popup()

func _play_anim(anim_name):
	pass
func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/StoryMode.tscn")
	
func _on_next_pressed():
	pass
	#get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/Chapter Scenes/Chapter3.tscn")
	
