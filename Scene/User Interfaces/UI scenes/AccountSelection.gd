extends Control

@onready var account_dropdown: OptionButton = $CenterContainer/VBoxContainer/AccountOptionButton
@onready var play_btn: Button = $CenterContainer/VBoxContainer/PlayButton
@onready var delete_btn: Button = $CenterContainer/VBoxContainer/DeleteButton
@onready var new_acc_btn: Button = $CenterContainer/VBoxContainer/NewAccountButton
@onready var confirmation_popup = $CustomQuitPopup

var selected_acc_id: String = ""

enum DeleteState { NONE, FIRST_ASK, REALLY_SURE }
var current_delete_step = DeleteState.NONE

func _ready():
	Global.load_master_config() #
	_refresh_account_list()
	
	account_dropdown.item_selected.connect(_on_dropdown_selected)
	play_btn.pressed.connect(_on_play_pressed)
	delete_btn.pressed.connect(_on_delete_confirmation_request)
	new_acc_btn.pressed.connect(_on_new_account_confirmation_request)
	
	confirmation_popup.confirmed.connect(_on_popup_confirmed)

func _refresh_account_list():
	account_dropdown.clear()
	if Global.all_accounts.is_empty():
		account_dropdown.add_item("No Accounts Found")
		account_dropdown.disabled = true
		play_btn.disabled = true
		delete_btn.disabled = true
		return

	var index = 0
	for acc_id in Global.all_accounts:
		var acc_name = Global.all_accounts[acc_id]
		account_dropdown.add_item(acc_name)
		account_dropdown.set_item_metadata(index, acc_id)
		index += 1
	
	account_dropdown.disabled = false
	play_btn.disabled = false
	delete_btn.disabled = false
	_on_dropdown_selected(0) 

func _on_dropdown_selected(index: int):
	selected_acc_id = account_dropdown.get_item_metadata(index)

func _on_play_pressed():
	if selected_acc_id == "": return
	Global.current_account_id = selected_acc_id #
	Global.load_game() #
	Global.save_master_config() #
	Global.loading_target_scene = "res://Scene/User Interfaces/UI scenes/main_menu.tscn" #
	get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn") #

# --- POPUP LOGIC ---
var popup_action = ""

func _on_delete_confirmation_request():
	current_delete_step = DeleteState.FIRST_ASK
	popup_action = "delete"
	
	# Added a 2.0 second cooldown to the first step too!
	confirmation_popup.setup_popup(
		"Are you sure you want to delete this account?", 
		"Yes, Delete", 
		"Cancel",
		5.0 
	)
	confirmation_popup.show_popup()

func _on_new_account_confirmation_request():
	popup_action = "create"
	confirmation_popup.setup_popup(
		"Create a new hero registration?", 
		"Confirm", 
        "Wait!"
	) #
	confirmation_popup.show_popup() #

func _on_popup_confirmed():
	if popup_action == "create":
		Global.prepare_new_account_creation()
		
		Global.loading_target_scene = "res://Scene/User Interfaces/UI scenes/NameEntry.tscn"
		
		get_tree().change_scene_to_file("res://Scene/User Interfaces/LoadingScene.tscn")
	
	elif popup_action == "delete":
		match current_delete_step:
			DeleteState.FIRST_ASK:
				current_delete_step = DeleteState.REALLY_SURE
				
				confirmation_popup.setup_popup(
					"ARE YOU REALLY, REALLY SURE?\nThis hero will be gone forever!", 
					"DELETE PERMANENTLY", 
					"Wait, go back!", 
					5.0 
				)
				confirmation_popup.show_popup()
				
			DeleteState.REALLY_SURE:
				Global.delete_account_data(selected_acc_id)
				_refresh_account_list()
				current_delete_step = DeleteState.NONE
