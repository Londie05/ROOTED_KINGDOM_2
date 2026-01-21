extends Node2D

# --- 1. NODE LINKS ---
# We use % for unique names or standard paths. 
# Make sure these match your Scene Tree exactly!
@onready var slot_container = %CardSlots
@onready var player_team = $PlayerTeam
@onready var enemy_team = $EnemyTeam
@onready var hand_container = %Hand
@onready var energy_label = $CanvasLayer/EnergyLabel

var turn_order: Array = []
var current_turn_index: int = 0
var active_character: BattleCharacter = null
var is_battle_paused: bool = false

# Preload your Card Resources
var charlotte_slash = preload("res://Resources/Common cards resources/slash.tres")
var charlotte_heal = preload("res://Resources/Common cards resources/Warm Touch.tres")
var charlotte_slash_aoe = preload("res://Resources/Signature cards/charlotte_ultimate.tres")

var beatrix_fireball_aoe = preload("res://Resources/Common cards resources/Magic Blast.tres")
var beatrix_shield = preload("res://Resources/Common cards resources/Shield.tres")

# The Deck System
var deck: Array = []
var discard_pile: Array = []
var hand_size: int = 5
var round_number: int = 1

# Energy System
var max_energy: int = 6 # Starting at 6 as requested
var current_energy: int = 6

# Card Slots
var slotted_cards: Array = [] # Tracks CardData in slots
var max_slots: int = 3

# Preload your assets for later
var card_scene = preload("res://Scene/CardUI.tscn")

var phases: Array = ["player", "enemy"]
var current_phase_index: int = 0

func _ready():
	# 1. Build Deck
	# Charlotte cards
	for i in range(4): deck.append(charlotte_slash)
	for i in range(3): deck.append(charlotte_heal)
	for i in range(3): deck.append(charlotte_slash_aoe)
	# Beatrix cards
	for i in range(1): deck.append(beatrix_fireball_aoe)
	for i in range(2): deck.append(beatrix_shield)
	deck.shuffle()

	# 2. Start the game at the Player Phase
	current_phase_index = 0
	start_current_phase()
	
	# 3. Energy Mechanics: Start at 6
	max_energy = 6
	current_energy = max_energy
	update_energy_ui()
	
	
# --- 3. THE CORE LOOP ---
func _process(_delta: float):
	# If the battle is paused (someone is taking a turn), do nothing
	if is_battle_paused:
		return
	

# --- 4. TURN LOGIC ---
func start_current_phase():
	var phase = phases[current_phase_index]
	
	if phase == "player":
		# 1. Start of Player Phase: Refill Energy & Reset Max
		if current_phase_index == 0:
			current_energy = max_energy
		
		# 2. Highlight all heroes to show it's their collective turn
		for hero in player_team.get_children():
			hero.modulate = Color(1.2, 1.2, 1.2)
			
		update_energy_ui()
		spawn_cards() # Draw 5 cards for the whole team
		
	elif phase == "enemy":
		# 3. Dim heroes, highlight enemy
		for hero in player_team.get_children():
			hero.modulate = Color(0.5, 0.5, 0.5)
		
		await get_tree().create_timer(1.0).timeout
		execute_enemy_ai()

func execute_enemy_ai():
	var heroes = player_team.get_children()

	for enemy in get_alive_enemies():
		if heroes.is_empty():
			break

		var target = heroes.pick_random()
		var damage_to_deal = enemy.base_damage
		target.take_damage(damage_to_deal)

		print(enemy.char_name + " dealt " + str(damage_to_deal) + " damage to " + target.char_name)
		await get_tree().create_timer(0.8).timeout

	end_current_phase()


# --- 3. THE 5-CARD DRAW SYSTEM ---
func spawn_cards():
	# 1. Discard unplayed cards first
	for child in hand_container.get_children():
		if child.get("card_data") != null:
			discard_pile.append(child.card_data)
		child.queue_free()
	
	await get_tree().process_frame
	
	# 2. Draw exactly 5 cards
	for i in range(5):
		if deck.is_empty():
			reshuffle_discard_into_deck()
		if not deck.is_empty():
			create_card_instance(deck.pop_front())
	
	update_energy_ui()

func create_card_instance(data: CardData):
	var new_card = card_scene.instantiate()
	hand_container.add_child(new_card)
	new_card.setup(data)
	
	# Connect the button click
	new_card.get_node("VBoxContainer/PlayButton").pressed.connect(_on_card_played.bind(data, new_card))

func end_current_phase():
	current_phase_index += 1
	
	# If the enemy just finished, go back to player and increase max energy
	if current_phase_index >= phases.size():
		current_phase_index = 0
		advance_round()
	
	start_current_phase()

func _on_card_played(data: CardData, card_node: Node):
	# SAFETY GATES (Updated for Phase system)
	if phases[current_phase_index] != "player": return
	if slotted_cards.size() >= max_slots: return 
	if current_energy < data.energy_cost: return

	# 1. Deduct energy
	current_energy -= data.energy_cost
	
	# 2. Move card logic
	slotted_cards.append(data)
	card_node.get_parent().remove_child(card_node)
	slot_container.add_child(card_node)
	
	# --- THE FIX: RESET VISUALS ---
	card_node.modulate = Color(1, 1, 1) # Force the card to be bright in the slot
	card_node.get_node("VBoxContainer/PlayButton").disabled = true # Keep button off
	
	update_energy_ui() # Refresh the hand to dim other cards you can no longer afford
		
# --- 2. THE TURN PROGRESSION ---
func _on_end_turn_button_pressed():
	# Only allow if it's the player's phase
	if phases[current_phase_index] != "player": return
	
	# Play the cards in the slots
	await execute_slotted_actions()
	
	# Move to Enemy Phase
	end_current_phase()

func update_energy_ui():
	if energy_label:
		energy_label.text = "Energy: " + str(current_energy) + "/" + str(max_energy)
	
	# Check if it's currently the player's phase
	var is_player_phase = phases[current_phase_index] == "player"

	for card in hand_container.get_children():
		# Safety check to ensure the child is a CardUI and has data
		if "card_data" in card and card.card_data != null:
			var cost = card.card_data.energy_cost
			var btn = card.get_node("VBoxContainer/PlayButton")
			
			# Logic: Dim if it's NOT our turn OR if we can't afford it
			if not is_player_phase or cost > current_energy:
				btn.disabled = true
				card.modulate = Color(0.4, 0.4, 0.4) # Slightly darker dim
			else:
				btn.disabled = false
				card.modulate = Color(1, 1, 1) # Full brightness


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
	# Cap max energy at 10 so the game stays challenging
	print("Round " + str(round_number) + "! Max Energy: " + str(max_energy))

func execute_slotted_actions():
	for data in slotted_cards:

		if data.damage > 0:
			var enemies = get_alive_enemies()
			if enemies.is_empty():
				return
			# AOE DAMAGE
			if data.is_aoe == true :
				var hits = min(data.aoe_targets, enemies.size())
				for i in range(hits):
					enemies[i].take_damage(data.damage)
			else:
				# Single target
				enemies[0].take_damage(data.damage)

		# Shield cards: give shield to the lowest-health hero
		if data.shield > 0:
			var targets = player_team.get_children()
			targets.sort_custom(func(a, b):
				return a.current_health < b.current_health
			)

			var receiver = targets[0]
			receiver.current_shield += data.shield
			receiver.update_ui()
			print("Granted " + str(data.shield) + " shield to " + receiver.char_name)

		# Heal cards
		if data.heal_amount > 0:
			var targets2 = player_team.get_children()
			targets2.sort_custom(func(a, b):
				return a.current_health < b.current_health
			)
			targets2[0].heal(data.heal_amount)

		discard_pile.append(data)
		await get_tree().create_timer(0.5).timeout

	# Clear slots
	for child in slot_container.get_children():
		child.queue_free()

	slotted_cards.clear()



func _on_restart_button_pressed():
	get_tree().reload_current_scene()


func get_alive_enemies() -> Array:
	var alive = []
	for enemy in enemy_team.get_children():
		if is_instance_valid(enemy) and enemy.current_health > 0:
			alive.append(enemy)
	return alive
