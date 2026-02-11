extends Node2D

@onready var ui_ctrl = $"User Interface"
@onready var d_interface = $"Dialog Manager/Dialogue Interface"
@onready var bg_anim = $"Dialog Manager/Background/Background Animation"
@onready var d_bg = $"Dialog Manager/Background"
# @onready var Character_Manager = $CharacterManger
# @onready var character_1 = $"Dialog Manager/Character Manager/Character"

@export_file("*.json") var JSON_file: String
# @onready var Dialogue_UI = $"Dialog Manager/Dialogue Layer/Dialogue Interface"

var json_as_text
var Dialogue_data
var Dialogue_access
var Dialogue_speaker
var Dialogue_array: Array
var Dialogue_array_name: String
var Dialogue_lines_arr
var Speaker_index:= 0
var Dialogue_index:= 0
var Dialogue_stanza_index:= 0
var Dialogue_stanza
var Dialogue_stanza_num
var Dialogue_stanza_dict
var Dialogue_stanza_dict_name
var Dialogue_lines_arr_value # -- AS LINES THIS TIME ARE IN ARRAYS 
var dialogue_lines_arr_value_index:= 0
var lines # For managing lines; not the lines themselves

var UI_ARE_HIDDEN:= false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if JSON_file != "":
		load_JSON()

func load_JSON():
	json_as_text = FileAccess.get_file_as_string(JSON_file)
	Dialogue_data = JSON.parse_string(json_as_text)
	if Dialogue_data == null:
		print("ERROR: JSON failed to parse. Check for typos/missing commas in the file.")
		return
		
	Dialogue_stanza = Dialogue_data.get("Dialogue", [])
	play_dialogue()

func play_dialogue():
	# character_1.slide("center")
	# Dialogue_stanza_name = Dialogue_stanza_name_arr[Dialogue_stanza_index]
	# Dialogue_stanza 
	#= Dialogue_access[Dialogue_stanza_index] # Array with Dictionary value
	if Dialogue_stanza_index <= Dialogue_stanza.size() - 1:
		#Dialogue_speaker = Dialogue_access[0]
		#Dialogue_array = Dialogue_speaker.keys()
		# Dialogue_array_name = Dialogue_array[Speaker_index]
		# Dialogue_lines_arr = Dialogue_speaker[Dialogue_array_name]
		
		Dialogue_stanza_num = Dialogue_stanza[Dialogue_stanza_index] # Stanza contents (Speakers)
		Dialogue_array = Dialogue_stanza_num.keys()
		
		# Dialogue_lines_arr = Dialogue_stanza_num[Dialogue_stanza_num] # Narrator's lines
		# Dialogue_lines_arr_value = Dialogue_lines_arr[Dialogue_index]
		
		# Dialogue_lines_arr_value = Dialogue_lines_arr[dialogue_lines_arr_value_index
		
		if Speaker_index <= Dialogue_array.size() - 1: # Speaker Condition
			#print(Speaker_index)
			Dialogue_array_name = Dialogue_array[Speaker_index] # Speaker
			Dialogue_lines_arr = Dialogue_stanza_num[Dialogue_array_name] # Narrator's lines
			
			if typeof(Dialogue_lines_arr) == TYPE_STRING:
				Dialogue_lines_arr = [Dialogue_lines_arr]
				
			if Dialogue_array_name == "Narrator" or Dialogue_array_name == "":
				d_interface.speaker_panel.visible = false
			else:
				d_interface.speaker_panel.visible = true
				
			if Dialogue_index <= Dialogue_lines_arr.size() - 1: # Dialogue
				Dialogue_lines_arr_value = Dialogue_lines_arr[Dialogue_index]
				
				#if dialogue_lines_arr_value_index <= Dialogue_lines_arr.size() - 1:
				main_play_reaction(Dialogue_index)
				main_play_collage(Dialogue_index)
				d_interface.animate_text = true
				d_interface.Dialogue_ui.visible_ratio = 0.0
				d_interface.Dialogue_speaker.text = Dialogue_array_name
				d_interface.Dialogue_ui.text = Dialogue_lines_arr_value.replace("{{Name}}", Global.player_name)
				# print(Dialogue_lines_arr_value)
				Dialogue_index += 1
				#else:
				#	if dialogue_lines_arr_value_index > Dialogue_lines_arr.size():
				#	dialogue_lines_arr_value_index = 0
				#Dialogue_index += 1
			else:
				if Dialogue_index > Dialogue_lines_arr.size() - 1:
					Dialogue_index = 0
					Speaker_index += 1
					print("Complete Lines!")
					play_dialogue()
		else:
			if Speaker_index > Dialogue_array.size() - 1:
				Speaker_index = 0
				Dialogue_stanza_index += 1
				print("Complete Speaker!")
				play_dialogue()
	else:
		if Dialogue_stanza_index > Dialogue_stanza.size() - 1:
			print("Complete Stanzas!")
			finish_chapter()
# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
	# pass

func main_play_reaction(_line_num: int): # play_reaction() main
	# play_reaction(_line_num, $"Character Manager/Character Sprite")
	pass # Add some play_reaction() which is from below

func play_reaction(_num: int): # This is basically Sprite Manager
	if _num == 0: 
		pass # remove this when adding a _character.react()
	else:
		pass#_character.react("")

func main_hide(value: bool):	
	$"Dialog Manager/Dialogue Interface".visible = value
	$"User Interface".visible = value
	
func main_play_collage(_index: int): # changes Background in a collage-like pattern
	# play_collage(_index, "res://icon.svg")
	pass # Add some play_collage() which is from below
	
func play_collage(_num: int, _bg: String):
	if _bg != "":
		d_bg.texture = load(_bg)
		if _num == 0:
			# bg_anim.play("Fade In")
			pass
	else:
		_bg = ""
		print("Image Unavaiable")
	
func finish_chapter():
	Global.bring_to_current_chapter_ui()
	Global.set_stage_unlocked(StoryMode.next_stage())
# Inputs
# func _input(event: InputEvent) -> void:
	
# Signals
func _on_hide_pressed() -> void:
	if !UI_ARE_HIDDEN:
		main_hide(false)
		UI_ARE_HIDDEN = true

func _on_skip_pressed() -> void:
	finish_chapter()

func _on_invisibile_button_pressed() -> void:
	if !UI_ARE_HIDDEN:
		play_dialogue()
	else:
		UI_ARE_HIDDEN = false
		main_hide(true)
