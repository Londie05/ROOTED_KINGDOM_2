extends Node2D

@export var floor_1_enemies: Array[EnemyData] = []
@export var floor_2_enemies: Array[EnemyData] = []
@export var floor_3_enemies: Array[EnemyData] = []
@export var floor_4_enemies: Array[EnemyData] = []
@export var floor_5_enemies: Array[EnemyData] = []
# --- 1. NODE LINKS ---
@onready var slot_container = %CardSlots
@onready var player_team = $PlayerTeam
@onready var enemy_team = $EnemyTeam
@onready var hand_container = %Hand
@onready var energy_label = $CanvasLayer/EnergyLabel
	
var card_scene = preload("res://Scene/CardUI.tscn")

var is_processing_turn: bool = false
var turn_order: Array = []
var current_turn_index: int = 0
var active_character: BattleCharacter = null
var is_battle_paused: bool = false

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


var phases: Array = ["player", "enemy"]
var current_phase_index: int = 0

func _ready():
	# This connects the Global data to your Dummy nodes
	setup_player_team()
	
	# 2. Build the deck (Ensure this uses Global.selected_team)
	build_deck_from_team()
	
	# 3. Setup the enemies
	setup_tower_enemies()
	
	# 4. Start the game
	current_energy = max_energy
	update_energy_ui()
	start_current_phase()
	
func setup_player_team():
	var heroes_in_scene = player_team.get_children() # Dummy1, Dummy2, Dummy3
	
	for i in range(heroes_in_scene.size()):
		var character_node = heroes_in_scene[i]
		
		# If we have a selected hero for this slot index
		if i < Global.selected_team.size():
			var data = Global.selected_team[i]
			character_node.setup_character(data)
		else:
			# If you selected only 1 or 2 heroes, hide the extra dummies
			character_node.queue_free()
			
# --- NEW FUNCTION: DYNAMIC DECK ---
func build_deck_from_team():
	deck.clear()
	# Change 'Global.player_team' to 'Global.selected_team'
	for data in Global.selected_team:
		if data.unique_card:
			deck.append(data.unique_card)
		
		for card in data.common_cards:
			deck.append(card)
	
	deck.shuffle()
	
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
	for enemy in get_alive_enemies():
		var alive_heroes = get_alive_players()
		if alive_heroes.is_empty():
			break
		
		# --- 1. Calculate Damage & Crit ---
		var damage_to_deal = enemy.base_damage
		var is_crit = false
		
		# Roll for Crit (0-100)
		if randi() % 100 < enemy.critical_chance:
			is_crit = true
			damage_to_deal = int(damage_to_deal * 1.5) # 1.5x Damage for Crit
			print("CRITICAL HIT by " + enemy.char_name + "!")

		# --- 2. Handle Target Selection (AOE vs Single) ---
		var targets_to_hit = []
		
		if enemy.is_aoe:
			# AOE: Get multiple random heroes
			alive_heroes.shuffle()
			var hit_count = min(enemy.max_aoe_targets, alive_heroes.size())
			for i in range(hit_count):
				targets_to_hit.append(alive_heroes[i])
		else:
			# Single Target
			targets_to_hit.append(alive_heroes.pick_random())

		# --- 3. Apply Damage ---
		for target in targets_to_hit:
			# Pass the 'is_crit' flag to the character
			target.take_damage(damage_to_deal, is_crit)
			print(enemy.char_name + " dealt " + str(damage_to_deal) + " to " + target.char_name)

		await get_tree().create_timer(0.8).timeout
	
	check_battle_status()
	if not get_alive_players().is_empty():
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
	check_battle_status()
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
	# 1. SAFETY GATES
	if is_processing_turn: return # Stop spamming!
	if phases[current_phase_index] != "player": return
	
	is_processing_turn = true # Lock the turn
	
	# Disable the button visually if you have a reference to it
	# $CanvasLayer/EndTurnButton.disabled = true 

	# 2. Play the cards
	await execute_slotted_actions()
	
	# 3. Move to Enemy Phase
	end_current_phase()
	
	# 4. Unlock after the whole sequence (including enemy AI) is done
	is_processing_turn = false
	# $CanvasLayer/EndTurnButton.disabled = false

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
		# --- 1. DAMAGE LOGIC (Already working) ---
		if data.damage > 0:
			var enemies = get_alive_enemies()
			if not enemies.is_empty():
				var final_damage = data.damage
				var is_crit = randi() % 100 < data.critical_chance
				if is_crit: final_damage = int(final_damage * 1.5)
				
				if data.is_aoe:
					var hits = min(data.aoe_targets, enemies.size())
					for i in range(hits):
						enemies[i].take_damage(final_damage, is_crit)
				else:
					enemies[0].take_damage(final_damage, is_crit)

		# --- 2. SHIELD LOGIC (Fixed for AOE) ---
		if data.shield > 0:
			var targets = get_alive_players()
			if not targets.is_empty():
				if data.is_aoe:
					# Apply shield to everyone (up to Aoe Target limit)
					var hits = min(data.aoe_targets, targets.size())
					for i in range(hits):
						targets[i].add_shield(data.shield)
				else:
					# Single target: prioritize lowest health
					targets.sort_custom(func(a, b): return a.current_health < b.current_health)
					targets[0].add_shield(data.shield)

		# --- 3. HEAL LOGIC (Fixed for AOE) ---
		if data.heal_amount > 0:
			var targets = get_alive_players()
			if not targets.is_empty():
				if data.is_aoe:
					# Apply heal to everyone (Warm Touch fix)
					var hits = min(data.aoe_targets, targets.size())
					for i in range(hits):
						targets[i].heal(data.heal_amount)
				else:
					# Single target: prioritize lowest health
					targets.sort_custom(func(a, b): return a.current_health < b.current_health)
					targets[0].heal(data.heal_amount)

		discard_pile.append(data)
		await get_tree().create_timer(0.5).timeout

	# Cleanup slots
	for child in slot_container.get_children():
		child.queue_free()
	slotted_cards.clear()
	check_battle_status()


func _on_restart_button_pressed():
	get_tree().reload_current_scene()


func get_alive_enemies() -> Array:
	var alive = []
	for enemy in enemy_team.get_children():
		if is_instance_valid(enemy) and enemy.current_health > 0:
			alive.append(enemy)
	return alive

func setup_tower_enemies():
	var enemy_nodes = enemy_team.get_children()
	var selected_floor_data: Array[EnemyData] = []
	
	match Global.current_tower_floor:
		1: selected_floor_data = floor_1_enemies
		2: selected_floor_data = floor_2_enemies
		3: selected_floor_data = floor_3_enemies
		4: selected_floor_data = floor_4_enemies
		5: selected_floor_data = floor_5_enemies
		
	for node in enemy_nodes:
		node.hide()
		node.current_health = 0 # Ensure hidden ones are "dead" for the logic

	for i in range(selected_floor_data.size()):
		if i < enemy_nodes.size():
			var enemy_resource = selected_floor_data[i]
			enemy_nodes[i].setup_enemy(enemy_resource)
			enemy_nodes[i].show() # Explicitly show the 4th dummy

func check_battle_status():
	# get_alive_enemies() already filters out dead/invalid units
	var alive_enemies = get_alive_enemies()
	var alive_players = get_alive_players()
	
	# 1. Check if Player Lost (All heroes dead)
	if alive_players.is_empty():
		print("Defeat! All heroes have fallen.")
		await get_tree().create_timer(1.0).timeout
		GlobalMenu.show_loss_menu() # Trigger the loss UI
		return
		
	# Only trigger victory if there are NO alive enemies left
	if alive_enemies.is_empty():
		if Global.current_tower_floor > 0:
			print("Victory! All enemies defeated.")
			Global.mark_floor_cleared(Global.current_tower_floor) #
			GlobalMenu.show_victory_menu() 
	
func get_alive_players() -> Array:
	var alive = []
	for hero in player_team.get_children():
		# Check if the hero node exists and has health > 0
		if is_instance_valid(hero) and hero.current_health > 0:
			alive.append(hero)
	return alive
	
func _on_menu_button_pressed() -> void:
	GlobalMenu.show_pause_menu()
