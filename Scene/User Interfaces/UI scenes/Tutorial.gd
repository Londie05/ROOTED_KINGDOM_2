extends Control

@onready var content_list = $Panel/HBoxContainer/ScrollContainer/VBoxContainer
@onready var scroll_container = $Panel/HBoxContainer/ScrollContainer

@onready var btn_tutorial = $Panel/HBoxContainer/Panel/VBoxContainer/TutorialManual
@onready var btn_character = $Panel/HBoxContainer/Panel/VBoxContainer/CharacterManual
@onready var btn_upgrades = $Panel/HBoxContainer/Panel/VBoxContainer/UpgradesManual
@onready var btn_play = $Panel/HBoxContainer/Panel/VBoxContainer/PlayManual
@onready var btn_tower = $Panel/HBoxContainer/Panel/VBoxContainer/TowerManual

@onready var btn_back = $"Button Manager/Back"

func _ready():
	btn_play.pressed.connect(show_page_play)
	btn_tutorial.pressed.connect(show_page_tutorial)
	btn_character.pressed.connect(show_page_character)
	btn_upgrades.pressed.connect(show_page_upgrades)
	btn_tower.pressed.connect(show_page_tower)
	

	show_page_tutorial()


func clear_page():
	for child in content_list.get_children():
		child.queue_free()
	scroll_container.scroll_vertical = 0

func add_title(text: String):
	var label = Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", 36) 
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	content_list.add_child(label)
	add_spacer(10)

func add_text(text: String):
	var label = Label.new()
	label.text = text
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.modulate = Color(0.9, 0.9, 0.9) 
	content_list.add_child(label)
	add_spacer(10)

func add_image(image_path: String):
	var texture = load(image_path)
	if texture:
		var rect = TextureRect.new()
		rect.texture = texture
		rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rect.custom_minimum_size.y = 200 
		content_list.add_child(rect)
		add_spacer(10)

func add_spacer(height: int):
	var spacer = Control.new()
	spacer.custom_minimum_size.y = height
	content_list.add_child(spacer)

func show_page_tutorial():
	await get_tree().process_frame

	clear_page()
	add_title("Settings Overview")
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Settings folder/Screenshot 2026-02-09 215913.png") 
	
	add_title("1. Audio Controls")
	add_text("• Volume Slider: Adjusts the overall master volume of the game")
	add_text("• Background Music: A dropdown menu that allows you to switch between different music tracks, such as 'Music 1' through 'Music 4' or 'None'")
	add_text("• Mute All: Instantly silences all game audio. When active, the button will change its text to 'Unmute'.")
	
	add_spacer(10)
	add_title("2. Visuals & Display")
	add_text("• Choose Background: Use the thumbnails to change the game's background style")
	add_text("• Full Screen Toggle: Switches the game between Windowed mode and Full Screen mode")
	
	add_title("Extra")
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Settings folder/Screenshot 2026-02-10 001352.png")
	add_text("You can click the Icon profile to hide your name and gems")


func show_page_character():
	await get_tree().process_frame

	clear_page()
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Character Folder/Screenshot 2026-02-09 224437.png")
	add_text("Each Hero has their own 1 Ultimate and 3 common cards with different damage and effects. If you want to increase the effects of the heor cards, Click the upgrade button to level the hero and its own cards")
	
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Character Folder/Screenshot 2026-02-09 224448.png")
	add_text("If you see the Hero grey, which means you haven't unlocked that hero. Click the Unlock to buy it (Make sure your gem is enough so you can buy it) ")

func show_page_upgrades():
	await get_tree().process_frame

	clear_page()
	add_title("Upgrades & Progression")
	
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Upgrades folder/Screenshot 2026-02-09 221601.png") 
	add_text("Each time your Hero's Level up it increases its Max HP. Each upgrade here adds a permanent +5 HP to your Hero, which is vital for surviving. (You can use your Crystal to upgrade your Hero)")

	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Upgrades folder/Screenshot 2026-02-09 221822.png") 
	add_text("This are the cards that the hero owns. You can upgrade the card to increase its stats. This is a way to increase the damage, heal, or any other stats that can help you in battle")

	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Upgrades folder/Screenshot 2026-02-09 221829.png")
	add_text("It will show the stats that will upgrade in your card, using small gems here directly increases these numbers—whether it's Damage, Shielding, or Healing based on that card growth. (As the level goes high, the cost will increase)")

	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Upgrades folder/Screenshot 2026-02-09 224126.png") 
	add_text("If you the Hero is gray, which means you haven't unlock that Hero. You can go to 'Buy Hero' button to go to the shop to buy that Hero")

func show_page_play():
	await get_tree().process_frame

	clear_page()
	add_title("Battle System")
	
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Battle Manual/Screenshot 2026-02-09 235105.png")
	add_text("Access the Tower Mode from the main menu to begin your battle and view available challenges.")
	

	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Battle Manual/Screenshot 2026-02-09 235115.png")
	add_text("Select your desired floor from the list. Once a floor is highlighted, click 'Choose Character' to proceed to team selection. (You can also see the reward of the floor at the right side)")
	

	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Battle Manual/Screenshot 2026-02-09 235130.png") 
	add_text("Pick a Hero to lead your party. If a character is currently locked, you can unlock them instantly using Gems.")
	
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Battle Manual/Screenshot 2026-02-09 235141.png")
	add_text("Confirm your selection and press 'Start Battle' to enter the combat arena.")
	
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Battle Manual/Screenshot 2026-02-09 235315.png")
	add_text("Your hand contains the skills available for this turn. Analyze your cards to plan the most effective sequence of attacks and defenses.")
	
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Battle Manual/Screenshot 2026-02-09 235333.png")
	add_text("Manage your resources carefully. Each card displays a Mana cost; ensure your current Mana (shown on the right) is sufficient before attempting to play a card into a slot.")
	
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Battle Manual/Screenshot 2026-02-09 235323.png")
	add_text("Toggle 'Show Card Info' to view detailed descriptions, status effects, and specific mechanics for each card in your hand.")
	
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Battle Manual/Screenshot 2026-02-09 235440.png")
	add_text("When multiple enemies are present, click on a specific monster to lock your focus. This ensures all single-target abilities hit your intended mark.")
	
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Battle Manual/Screenshot 2026-02-09 235451.png")
	add_text("Use the Menu button to pause the action, adjust audio and visuals, or safely exit back to the tower.")
	
	
func show_page_tower():
	await get_tree().process_frame

	clear_page()
	add_title("Modes")
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Modes folder/Screenshot 2026-02-09 233028.png")
	add_text("There are two modes, The story mode and the tower mode")
	add_title("The Tower Mode")
	add_image("res://Scene/User Interfaces/UI scenes/Manual images/Modes folder/Screenshot 2026-02-09 233109.png")
	add_text("The tower has so much floors that you can challenge to earn rewards. (Note: That the Difficulty increases as you go up)")
