extends Node2D

# --- 1. NODE LINKS ---
# We use % for unique names or standard paths. 
# Make sure these match your Scene Tree exactly!
@onready var player_team = $PlayerTeam
@onready var enemy_team = $EnemyTeam
@onready var hand_container = %Hand

@onready var beatrix_bar = $CanvasLayer/ActionPanel/BeatrixBar
@onready var charlotte_bar = $CanvasLayer/ActionPanel/CharlotteBar
@onready var enemy_bar = $CanvasLayer/ActionPanel/EnemyBar

# Preload your Card Resources
var attack30 = preload("res://Attack30.tres")
var attack50 = preload("res://Attack50.tres")
var shield25 = preload("res://Shield25.tres")

# The Deck System
var deck: Array = []
var discard_pile: Array = []
var hand_size: int = 5

# Energy System
var max_energy: int = 3
var current_energy: int = 3
@onready var energy_label = $CanvasLayer/EnergyLabel # Create this label in your UI!

# --- 2. GAME VARIABLES ---
var active_character: BattleCharacter = null
var is_battle_paused: bool = false

# Preload your assets for later
var card_scene = preload("res://CardUI.tscn")

func _ready():
	# 1. Build the deck by adding the cards we preloaded above
	for i in range(4): deck.append(attack30)
	for i in range(3): deck.append(attack50)
	for i in range(3): deck.append(shield25)
	
	# 2. Shuffle the deck so it's random
	deck.shuffle()
	
	# 3. Set energy to full at the start
	current_energy = max_energy
	update_energy_ui()
	
# --- 3. THE CORE LOOP ---
func _process(delta: float):
	# If the battle is paused (someone is taking a turn), do nothing
	if is_battle_paused:
		return
	
	run_initiative_tick(delta)

func run_initiative_tick(delta: float):
	# Get everyone currently in the folders
	var all_characters = player_team.get_children() + enemy_team.get_children()
	
	for character in all_characters:
		# Add speed to their meter. Multiplying by 5 makes it fast enough to see.
		character.action_meter += character.base_speed * delta * 5
		
		# Update the visual Progress Bars
		update_action_ui(character)
		
		# Check if this character reached 100% (Turn Start!)
		if character.action_meter >= 100:
			start_turn(character)
			break # Stop the loop so only one person goes at a time

# --- 4. TURN LOGIC ---
func start_turn(character: BattleCharacter):
	is_battle_paused = true
	active_character = character
	print("--- TURN START: " + character.char_name + " ---")
	
	if character.is_enemy:
		# Small delay so the player can see the bar hit 100%
		await get_tree().create_timer(0.8).timeout
		execute_enemy_ai()
	else:
		# It's a hero! 
		# In Part 2, we will replace this with drawing cards.
		# For now, we print and wait for a "fake" turn completion
		spawn_cards()

func execute_enemy_ai():
	var targets = player_team.get_children()
	if targets.size() > 0:
		var target = targets.pick_random()
		target.take_damage(randi_range(15, 25))
		print("Enemy attacked " + target.char_name)
	
	# We MUST wait and then call end_current_turn 
	# or the Enemy will stay at 100% forever!
	await get_tree().create_timer(1.0).timeout
	end_current_turn()

func spawn_cards():
	print("Drawing cards for " + active_character.char_name)
	
	# 1. Clear previous hand UI
	for child in hand_container.get_children():
		child.queue_free()
	
	# 2. IMPORTANT: Check if deck is empty BEFORE the loop starts
	if deck.is_empty():
		reshuffle_discard_into_deck()
	
	# 3. Reset energy
	current_energy = max_energy
	update_energy_ui()
	
	# 4. Draw cards
	for i in range(hand_size):
		# Double check inside the loop in case we run out mid-draw
		if deck.is_empty():
			reshuffle_discard_into_deck()
			
		if not deck.is_empty():
			var data = deck.pop_front()
			create_card_instance(data)

func create_card_instance(data: CardData):
	var new_card = card_scene.instantiate()
	hand_container.add_child(new_card)
	new_card.setup(data)
	
	# Connect the button click
	new_card.get_node("VBoxContainer/PlayButton").pressed.connect(_on_card_played.bind(data, new_card))

func end_current_turn():
	if active_character:
		active_character.action_meter = 0 # Reset the winner to 0
		update_action_ui(active_character) # Update their bar visually
	
	active_character = null
	is_battle_paused = false # THIS restarts the ActionPanel bars!
	print("--- TURN END: Clock Resumed ---")

# --- 5. UI UPDATES ---
func update_action_ui(character: BattleCharacter):
	if character.char_name == "Beatrix":
		beatrix_bar.value = character.action_meter
	elif character.char_name == "Charlotte":
		charlotte_bar.value = character.action_meter
	elif character.char_name == "Enemy":
		enemy_bar.value = character.action_meter


func _on_card_played(data: CardData, card_node: Node):
	# 1. Check if we have enough energy
	# (We'll assume cards cost 1 energy for now)
	if not active_character or active_character.is_enemy:
		return
	
	# 2. Spend Energy
	if current_energy < data.energy_cost:
		print("Not enough energy for this card!")
		return
	
	# 3. Deduct the specific cost and update UI
	current_energy -= data.energy_cost
	update_energy_ui()
	
	# 4. Apply Effects
	var enemy = enemy_team.get_child(0)
	if data.damage > 0:
		enemy.take_damage(data.damage)
	if data.shield > 0:
		active_character.add_shield(data.shield)
	
# ... existing code ...
	# 5. Add to discard pile (THIS WAS MISSING)
	discard_pile.append(data)
	
	# Then remove card from hand
	card_node.queue_free()
	
	# 6. Check if enemy is dead
	if enemy.current_health <= 0:
		print("Victory!")
		return
	
	# 7. OPTIONAL: Auto-end turn if 0 energy
	if current_energy <= 0:
		print("Out of energy! Ending turn...")
		await get_tree().create_timer(0.6).timeout
		_on_end_turn_button_pressed()
	
func _on_end_turn_button_pressed():
	# Safety checks
	if is_battle_paused == false: return
	if active_character == null or active_character.is_enemy: return
	
	# --- THE FIX STARTS HERE ---
	for child in hand_container.get_children():
		# 1. Take the data from the unplayed card and put it in the discard pile
		if child.get("card_data") != null:
			discard_pile.append(child.card_data)
		
		# 2. Now it is safe to remove the card from the screen
		child.queue_free()
	# --- THE FIX ENDS HERE ---
	
	end_current_turn()

func update_energy_ui():
	if energy_label:
		energy_label.text = "Energy: " + str(current_energy) + "/" + str(max_energy)
	
	# Loop through all cards currently in the hand
	for card in hand_container.get_children():
		# SAFETY CHECK: Only proceed if the card actually has data loaded
		if card.get("card_data") != null:
			var cost = card.card_data.energy_cost
			var btn = card.get_node("VBoxContainer/PlayButton")
			
			if cost > current_energy:
				btn.disabled = true
				card.modulate = Color(0.5, 0.5, 0.5)
			else:
				btn.disabled = false
				card.modulate = Color(1, 1, 1)

func reshuffle_discard_into_deck():
	if discard_pile.is_empty():
		print("WARNING: No cards left in deck OR discard pile!")
		return
		
	print("--- Reshuffling Discard Pile into Deck ---")
	deck = discard_pile.duplicate()
	discard_pile.clear()
	deck.shuffle()
