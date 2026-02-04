extends Node2D

@onready var stage_count_label = $CanvasLayer/StageCount

@export var floor_1_enemies: Array[EnemyData] = []
@export var floor_2_enemies: Array[EnemyData] = []
@export var floor_3_enemies: Array[EnemyData] = []
@export var floor_4_enemies: Array[EnemyData] = []
@export var floor_5_enemies: Array[EnemyData] = []
@export var floor_6_enemies: Array[EnemyData] = []
@export var floor_7_enemies: Array[EnemyData] = []
@export var floor_8_enemies: Array[EnemyData] = []
@export var floor_9_enemies: Array[EnemyData] = []
@export var floor_10_enemies: Array[EnemyData] = []
@export var floor_11_enemies: Array[EnemyData] = []
@export var floor_12_enemies: Array[EnemyData] = []
@export var floor_13_enemies: Array[EnemyData] = []
@export var floor_14_enemies: Array[EnemyData] = []
@export var floor_15_enemies: Array[EnemyData] = []
@export var floor_16_enemies: Array[EnemyData] = []
@export var floor_17_enemies: Array[EnemyData] = []
@export var floor_18_enemies: Array[EnemyData] = []
@export var floor_19_enemies: Array[EnemyData] = []
@export var floor_20_enemies: Array[EnemyData] = []
# --- 1. NODE LINKS ---
@onready var slot_container = %CardSlots
@onready var player_team = $PlayerTeam
@onready var enemy_team = $EnemyTeam
@onready var hand_container = %Hand
@onready var mana_label = $CanvasLayer/EnergyLabel

@onready var global_info_button = $CanvasLayer/GlobalInfoButton
var is_info_mode_on: bool = false

var mana_popup_scene = preload("res://Scene/ManaPopup.tscn") 
var card_scene = preload("res://Scene/CardUI.tscn")

var is_processing_turn: bool = false
var turn_order: Array = []
var current_turn_index: int = 0
var active_character: BattleCharacter = null
var is_battle_paused: bool = false

# The Deck System
var deck: Array = []
var discard_pile: Array = []
var hand_size: int = 6
var round_number: int = 1

var max_mana: int = 20     # Hard Cap
var current_mana: int = 4  # Starting Mana
var mana_regen: int = 4

# Card Slots
var slotted_nodes: Array = []
var max_slots: int = 3


var phases: Array = ["player", "enemy"]
var current_phase_index: int = 0

# Sound effects
@onready var sfx_player = $CanvasLayer/SFXPlayer
@onready var bgm_player = $CanvasLayer/BGMPlayer

var battle_themes: Array[String] = [
	"res://Asset/Sound effects/background effect1.mp3",
	"res://Asset/Sound effects/background effect2.mp3"
]

func _ready():
	for child in hand_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame 
	
	var btn = get_node_or_null("CanvasLayer/GlobalInfoButton")
	if btn:
		if not btn.pressed.is_connected(_on_global_info_button_pressed):
			btn.pressed.connect(_on_global_info_button_pressed)
	else:
		print("WARNING: 'GlobalInfoButton' not found in Battlefield Scene")
	
	if Global.current_tower_floor == 10:
		bgm_player.stream = load("res://Asset/Sound effects/background effect3.mp3")
	else:
		var random_track_path = battle_themes.pick_random()
		bgm_player.stream = load(random_track_path)
	
	# Play the selected track
	bgm_player.play()
	
	if stage_count_label:
		# This uses your existing global variable to show "Stage: 1", "Stage: 2", etc.
		stage_count_label.text = "Stage: " + str(Global.current_tower_floor)
		
	setup_player_team()
	build_deck_from_team()
	setup_tower_enemies()
	update_mana_ui()
	start_current_phase()
	
func setup_player_team():
	var heroes_in_scene = player_team.get_children() # Dummy1, Dummy2, Dummy3
	
	for i in range(heroes_in_scene.size()):
		var character_node = heroes_in_scene[i]
		
		if i < Global.selected_team.size():
			var data = Global.selected_team[i]
			character_node.setup_character(data)
		else:
			character_node.queue_free()
			
func build_deck_from_team():
	deck.clear()
	for data in Global.selected_team:
		if data.unique_card:
			deck.append(data.unique_card)
		
		for card in data.common_cards:
			deck.append(card)
	
	deck.shuffle()
	
# --- 3. THE CORE LOOP ---
func _process(_delta: float):
	if is_battle_paused:
		return
	

# --- 4. TURN LOGIC ---
func start_current_phase():
	var phase = phases[current_phase_index]
	
	if phase == "player":
		if current_phase_index == 0:
			var old_mana = current_mana
			current_mana = min(current_mana + mana_regen, max_mana)
			
			# Calculate how much we actually gained (in case of cap)
			var actual_gain = current_mana - old_mana
			if actual_gain > 0:
				spawn_mana_popup(actual_gain)
		
		# Highlight heroes
		for hero in player_team.get_children():
			hero.modulate = Color(1.2, 1.2, 1.2)
			
		spawn_cards() 
		update_mana_ui()
		
	elif phase == "enemy":
		# Dim heroes
		for hero in player_team.get_children():
			hero.modulate = Color(0.5, 0.5, 0.5)
		
		await get_tree().create_timer(1.0).timeout
		execute_enemy_ai()

func execute_enemy_ai():
	for enemy in get_alive_enemies():
		var alive_heroes = get_alive_players()
		if alive_heroes.is_empty():
			break
		
		if enemy.has_method("process_stun_turn"):
			if enemy.process_stun_turn():
				# If true, they are stunned. 
				# Wait a bit so the player sees they skipped their turn.
				print(enemy.name + " skips turn due to stun.")
				await get_tree().create_timer(0.5).timeout
				continue # Skip to the next enemy immediately
				
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
			target.take_damage(damage_to_deal, is_crit)
			print(enemy.char_name + " dealt " + str(damage_to_deal) + " to " + target.char_name)

		await get_tree().create_timer(0.8).timeout
	
	check_battle_status()
	if not get_alive_players().is_empty():
		end_current_phase()


func spawn_cards():
	var current_cards_in_hand = hand_container.get_child_count()
	
	var cards_to_draw = hand_size - current_cards_in_hand
	
	print("Hand has " + str(current_cards_in_hand) + " cards. Drawing " + str(cards_to_draw) + " new cards.")
	
	if cards_to_draw <= 0:
		update_mana_ui()
		return

	for i in range(cards_to_draw):
		if deck.is_empty():
			reshuffle_discard_into_deck()
		
		if not deck.is_empty():
			create_card_instance(deck.pop_front())
			await get_tree().create_timer(0.1).timeout
	
	update_mana_ui()

func create_card_instance(data: CardData):
	var new_card = card_scene.instantiate()
	hand_container.add_child(new_card)
	new_card.setup(data)
	
	new_card.modulate.a = 0
	new_card.position.y += 50
	
	var tween = create_tween().set_parallel(true)
	tween.tween_property(new_card, "modulate:a", 1.0, 0.3)
	tween.tween_property(new_card, "position:y", 0, 0.3).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	if new_card.has_method("toggle_info_capability"):
		new_card.toggle_info_capability(true)
	new_card.get_node("Visuals/VBoxContainer/PlayButton").pressed.connect(_on_card_played.bind(data, new_card))
	
func end_current_phase():
	check_battle_status()
	current_phase_index += 1
	
	if current_phase_index >= phases.size():
		current_phase_index = 0
		advance_round()
	
	start_current_phase()

func _on_card_played(data: CardData, card_node: Node):
	if phases[current_phase_index] != "player": return
	
	if current_mana < data.mana_cost:
		if card_node.has_method("animate_error"):
			card_node.animate_error() # Visual feedback for "No Mana"
		return

	# If we have mana, play the card
	if card_node.has_method("animate_play"):
		card_node.animate_play()
		
	if slotted_nodes.size() >= max_slots: return 
	if current_mana < data.mana_cost: return

	# 1. Deduct Mana
	current_mana -= data.mana_cost
	
	if card_node.has_method("set_description_visible"):
		card_node.set_description_visible(false)
	
	# 2. Add to Slot Logic
	slotted_nodes.append(card_node)
	
	# 3. Move Visuals to Slot
	card_node.get_parent().remove_child(card_node)
	slot_container.add_child(card_node)
	
	var btn = card_node.get_node("Visuals/VBoxContainer/PlayButton")
	
	if btn.pressed.is_connected(_on_card_played):
		btn.pressed.disconnect(_on_card_played)
	
	btn.pressed.connect(return_card_to_hand.bind(data, card_node))
	
	btn.text = "Return"
	btn.disabled = false 
	card_node.modulate = Color(1, 1, 1) 
	
	update_mana_ui()
	
func return_card_to_hand(data: CardData, card_node: Node):
	if is_processing_turn: return
	
	# 1. Refund Mana
	current_mana += data.mana_cost
	current_mana = min(current_mana, max_mana)

	# 2. Remove from Slot Logic
	slotted_nodes.erase(data)
	
	# 3. Move Visuals back to Hand
	card_node.get_parent().remove_child(card_node)
	hand_container.add_child(card_node)
	
	
	# 4. SWAP SIGNAL: Change button from "Return" to "Play"
	var btn = card_node.get_node("Visuals/VBoxContainer/PlayButton")
	
	if btn.pressed.is_connected(return_card_to_hand):
		btn.pressed.disconnect(return_card_to_hand)
		
	btn.pressed.connect(_on_card_played.bind(data, card_node))
	
	# Visual Reset
	btn.text = "Play"
	
	update_mana_ui()
		
# --- 2. THE TURN PROGRESSION ---
func _on_end_turn_button_pressed():
	if is_processing_turn: return # Stop spamming!
	if phases[current_phase_index] != "player": return
	
	is_processing_turn = true # Lock the turn
	
	# 2. Play the cards
	await execute_slotted_actions()
	
	# 3. Move to Enemy Phase
	end_current_phase()
	
	# 4. Unlock after the whole sequence (including enemy AI) is done
	is_processing_turn = false

func update_mana_ui():
	if mana_label:
		mana_label.text = "Mana: " + str(current_mana) + "/" + str(max_mana)
	
	var is_player_phase = phases[current_phase_index] == "player"

	for card in hand_container.get_children():
		if "card_data" in card and card.card_data != null:
			var cost = card.card_data.mana_cost
			var btn = card.get_node("Visuals/VBoxContainer/PlayButton")
			var content = card.get_node("Visuals/VBoxContainer") # The visual content
			
			if not is_player_phase or cost > current_mana:
				btn.disabled = true
				content.modulate = Color(0.4, 0.4, 0.4) 
			else:
				btn.disabled = false
				content.modulate = Color(1, 1, 1)

	# Slotted cards should always be bright
	for card in slot_container.get_children():
		card.modulate = Color(1, 1, 1)
		var btn = card.get_node("Visuals/VBoxContainer/PlayButton")
		var content = card.get_node("Visuals/VBoxContainer")
		content.modulate = Color(1, 1, 1)
		btn.disabled = false


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

func execute_slotted_actions():
	is_processing_turn = true
	
	for card_node in slotted_nodes:
		if not is_instance_valid(card_node): continue
		
		var data = card_node.card_data # Get the resource from the node
		
		# --- ANIMATION START ---
		if card_node.has_method("animate_as_active"):
			card_node.animate_as_active()
		
		# Give a tiny pause for the card to "pop" before the sound/damage
		await get_tree().create_timer(0.2).timeout
		# --- ANIMATION END ---

		if data.sound_effect and sfx_player:
			sfx_player.stream = data.sound_effect
			sfx_player.play()
		
		# 1. Damage Logic
		if data.damage > 0:
			var targets = get_targets_for_action(data.is_aoe, data.aoe_targets)
			if not targets.is_empty():
				var final_damage = Global.get_card_damage(data)
				var is_crit = randi() % 100 < data.critical_chance
				for target in targets:
					target.take_damage(final_damage if not is_crit else int(final_damage * 1.5), is_crit)

		# 2. Shield
		if data.shield > 0:
			var targets = get_alive_players()
			if not targets.is_empty():
				var final_shield = Global.get_card_shield(data)
				if data.is_aoe:
					var hits = min(data.aoe_targets, targets.size())
					for i in range(hits):
						targets[i].add_shield(final_shield)
				else:
					targets.sort_custom(func(a, b): return a.current_health < b.current_health)
					targets[0].add_shield(final_shield)
					
		# 3. Mana
		if data.mana_gain > 0:
			var gain = Global.get_card_mana(data)
			current_mana = min(current_mana + gain, max_mana)
			spawn_mana_popup(gain)
			update_mana_ui()
			
		# 4. Heal
		if data.heal_amount > 0:
			var targets = get_alive_players()
			if not targets.is_empty():
				var final_heal = Global.get_card_heal(data)
				if data.is_aoe:
					var hits = min(data.aoe_targets, targets.size())
					for i in range(hits):
						targets[i].heal(final_heal)
				else:
					targets.sort_custom(func(a, b): return a.current_health < b.current_health)
					targets[0].heal(final_heal)
		
		# 5. Stun Logic
		if data.stuns_enemy:
			print("--- DEBUG: Card '", data.card_name, "' has stuns_enemy = TRUE")
			var targets = get_targets_for_action(data.is_aoe, data.aoe_targets)
			
			if not targets.is_empty():
				for target in targets:
					if target.has_method("apply_stun"):
						print("--- DEBUG: Calling apply_stun on ", target.char_name)
						target.apply_stun(data.stun_duration)
			else:
				print("--- DEBUG: Stun failed - No targets found!")
						
		discard_pile.append(data)
		await get_tree().create_timer(1).timeout

	for child in slot_container.get_children():
		child.queue_free()
		
	slotted_nodes.clear()
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
		6: selected_floor_data = floor_6_enemies
		7: selected_floor_data = floor_7_enemies
		8: selected_floor_data = floor_8_enemies
		9: selected_floor_data = floor_9_enemies
		10: selected_floor_data = floor_10_enemies
		11: selected_floor_data = floor_11_enemies
		12: selected_floor_data = floor_12_enemies
		13: selected_floor_data = floor_13_enemies
		14: selected_floor_data = floor_14_enemies
		15: selected_floor_data = floor_15_enemies
		16: selected_floor_data = floor_16_enemies
		17: selected_floor_data = floor_17_enemies
		18: selected_floor_data = floor_18_enemies
		19: selected_floor_data = floor_19_enemies
		20: selected_floor_data = floor_20_enemies
		
	for node in enemy_nodes:
		node.hide()
		node.current_health = 0 # Ensure hidden ones are "dead" for the logic

	for i in range(selected_floor_data.size()):
		if i < enemy_nodes.size():
			var enemy_resource = selected_floor_data[i]
			enemy_nodes[i].setup_enemy(enemy_resource)
			enemy_nodes[i].show() 
	
	for i in range(selected_floor_data.size()):
		if i < enemy_nodes.size():
			var enemy_resource = selected_floor_data[i]
			var enemy_node = enemy_nodes[i] 
			
			enemy_node.setup_enemy(enemy_resource)
			enemy_node.show()
			
			if not enemy_node.enemy_selected.is_connected(_on_enemy_clicked):
				enemy_node.enemy_selected.connect(_on_enemy_clicked)
				
func check_battle_status():
	# get_alive_enemies() already filters out dead/invalid units
	var alive_enemies = get_alive_enemies()
	var alive_players = get_alive_players()
	
	# 1. Check if Player Lost (All heroes dead)
	if alive_players.is_empty():
		print("Defeat! All heroes have fallen.")
		await get_tree().create_timer(1.0).timeout
		fade_out_music()
		GlobalMenu.show_loss_menu() # Trigger the loss UI
		return
		
	# Only trigger victory if there are NO alive enemies left
	if alive_enemies.is_empty():
		if Global.current_tower_floor > 0:
			print("Victory! All enemies defeated.")
			Global.mark_floor_cleared(Global.current_tower_floor) #
			fade_out_music()
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

func spawn_mana_popup(amount: int):
	if mana_label == null: return
	
	var popup = mana_popup_scene.instantiate()
	# Add it to the CanvasLayer so it stays on top of the UI
	$CanvasLayer.add_child(popup)
	
	# Position it right on top of the Mana Label
	popup.global_position = mana_label.global_position + Vector2(20, -20)
	popup.setup(amount)

func _on_global_info_button_pressed():
	is_info_mode_on = !is_info_mode_on
	
	var btn = get_node_or_null("CanvasLayer/GlobalInfoButton")
	if btn:
		btn.text = "Hide Card Info" if is_info_mode_on else "Show Card Info"

	# SAFE LOOP: Only touches valid cards
	for card in hand_container.get_children():
		# Check if the card is valid and has the script attached
		if is_instance_valid(card) and card.has_method("set_description_visible"):
			card.set_description_visible(is_info_mode_on)

func _on_enemy_clicked(clicked_enemy):
	# 1. Unlock all enemies first
	for enemy in get_alive_enemies():
		enemy.set_target_lock(false)
	
	# 2. Lock the one we clicked
	clicked_enemy.set_target_lock(true)
	

func get_targets_for_action(is_aoe: bool, num_targets: int) -> Array:
	var alive_enemies = get_alive_enemies()
	var targets = []
	
	if alive_enemies.is_empty():
		return targets

	# Find if someone is locked
	var locked_enemy = null
	for e in alive_enemies:
		if e.is_locked_target:
			locked_enemy = e
			break
	
	if is_aoe:
		# If locked, they are target #1
		if locked_enemy:
			targets.append(locked_enemy)
		
		# Fill the rest with others
		for e in alive_enemies:
			if e != locked_enemy and targets.size() < num_targets:
				targets.append(e)
	else:
		if locked_enemy:
			targets.append(locked_enemy)
		else:
			targets.append(alive_enemies[0])
			
	return targets
	
func fade_out_music():
	var tween = create_tween()
	tween.tween_property(bgm_player, "volume_db", -80.0, 1.5)
	tween.tween_callback(bgm_player.stop)
