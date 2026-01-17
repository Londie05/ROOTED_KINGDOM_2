extends Node2D

# --- 1. NODE LINKS ---
# We use % for unique names or standard paths. 
# Make sure these match your Scene Tree exactly!
@onready var player_team = $PlayerTeam
@onready var enemy_team = $EnemyTeam
@onready var hand_container = %Hand
@onready var energy_label = $CanvasLayer/EnergyLabel

var turn_order: Array = []
var current_turn_index: int = 0
var active_character: BattleCharacter = null
var is_battle_paused: bool = false

# Preload your Card Resources
var attack30 = preload("res://Attack30.tres")
var attack50 = preload("res://Attack50.tres")
var shield25 = preload("res://Shield25.tres")

# The Deck System
var deck: Array = []
var discard_pile: Array = []
var hand_size: int = 5
var round_number: int = 1

# Energy System
var max_energy: int = 3
var current_energy: int = 3


# Preload your assets for later
var card_scene = preload("res://CardUI.tscn")

func _ready():
	# 1. BUILD THE DECK (This was missing!)
	for i in range(4): deck.append(attack30)
	for i in range(3): deck.append(attack50)
	for i in range(3): deck.append(shield25)
	deck.shuffle()

	# 2. Setup Turn Order: [Beatrix, Charlotte, Enemy]
	turn_order = player_team.get_children() + enemy_team.get_children()
	
	# 3. Energy Mechanics: Start at 6
	max_energy = 6
	current_energy = max_energy
	update_energy_ui()
	
	# 4. Start the first turn
	start_current_turn()
	
# --- 3. THE CORE LOOP ---
func _process(_delta: float):
	# If the battle is paused (someone is taking a turn), do nothing
	if is_battle_paused:
		return
	

# --- 4. TURN LOGIC ---
func start_current_turn():
	active_character = turn_order[current_turn_index]
	
	# IF IT IS THE START OF THE PLAYER'S LINEUP (Beatrix)
	if current_turn_index == 0:
		# Reset energy only once per full round
		current_energy = max_energy 
		update_energy_ui()
		
	# CHECK FOR STUN
	if active_character.is_stunned:
		print(active_character.char_name + " is stunned and skips!")
		active_character.is_stunned = false # Remove stun for next time
		await get_tree().create_timer(1.0).timeout
		end_current_turn()
		return

	highlight_active_character()
	
	if active_character.is_enemy:
		await get_tree().create_timer(1.0).timeout
		execute_enemy_ai()
	else:
		# At the start of a Hero's turn, they get their cards
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
	current_turn_index += 1
	
	# If everyone has gone, restart the round list
	if current_turn_index >= turn_order.size():
		current_turn_index = 0
		advance_round() # Call the helper function instead of manual math
	
	start_current_turn()

func _on_card_played(data: CardData, card_node: Node):
	# SAFETY GATE: If it's the enemy's turn, stop the player from clicking!
	if active_character == null or active_character.is_enemy:
		print("Wait your turn! It's the enemy's move.")
		return

	if current_energy < data.energy_cost: return
	
	# 1. Anti-Spam: Disable the button immediately
	card_node.get_node("VBoxContainer/PlayButton").disabled = true
	
	current_energy -= data.energy_cost
	update_energy_ui()
	
	# 2. Apply Effects
	var enemy = enemy_team.get_child(0)
	if data.damage > 0: enemy.take_damage(data.damage)
	if data.stuns_enemy: enemy.is_stunned = true
	if data.heal_amount > 0: active_character.heal(data.heal_amount)
	
	# 3. Cleanup Card
	discard_pile.append(data)
	card_node.queue_free()
	
	# 4. AUTO-END TURN: Move to the next person in line
	print("Action finished, moving to next turn...")
	await get_tree().create_timer(0.5).timeout # Small pause to see the result
	end_current_turn()
		
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
	
	var is_player_turn = active_character != null and not active_character.is_enemy

	for card in hand_container.get_children():
		if card.get("card_data") != null:
			var cost = card.card_data.energy_cost
			var btn = card.get_node("VBoxContainer/PlayButton")
			
			# If it's the enemy turn OR we don't have enough energy
			if not is_player_turn or cost > current_energy:
				btn.disabled = true
				card.modulate = Color(0.5, 0.5, 0.5) # Darken the card
			else:
				btn.disabled = false
				card.modulate = Color(1, 1, 1) # Normal color

func reshuffle_discard_into_deck():
	if discard_pile.is_empty():
		print("WARNING: No cards left in deck OR discard pile!")
		return
		
	print("--- Reshuffling Discard Pile into Deck ---")
	deck = discard_pile.duplicate()
	discard_pile.clear()
	deck.shuffle()
	
func highlight_active_character():
	for character in turn_order:
		if character == active_character:
			character.modulate = Color(1.2, 1.2, 1.2) # Brighten
			character.scale = Vector2(1.1, 1.1) # Slightly larger
		else:
			character.modulate = Color(0.5, 0.5, 0.5) # Dim
			character.scale = Vector2(1.0, 1.0) # Normal size

func advance_round():
	round_number += 1
	max_energy += 1 # Increases by 1 every full round (Hero1 -> Hero2 -> Enemy)
	print("Round " + str(round_number) + "! Max Energy is now " + str(max_energy))
	# Note: We don't need update_energy_ui() here because spawn_cards() calls it next!
