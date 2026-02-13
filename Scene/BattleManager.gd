extends Control

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

var max_mana: int = 20      # Hard Cap
var current_mana: int = 4   # Starting Mana
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
	
	bgm_player.play()
	
	if stage_count_label:
		stage_count_label.text = "Floor: " + str(Global.current_tower_floor)
		
	setup_player_team()
	build_deck_from_team()
	setup_tower_enemies()
	update_mana_ui()
	start_current_phase()
	
func setup_player_team():
	var heroes_in_scene = player_team.get_children() 
	
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

# --- 4. TURN LOGIC ---
func start_current_phase():
	var phase = phases[current_phase_index]
	
	if phase == "player":
		if current_phase_index == 0:
			var old_mana = current_mana
			current_mana = min(current_mana + mana_regen, max_mana)
			
			var actual_gain = current_mana - old_mana
			if actual_gain > 0:
				spawn_mana_popup(actual_gain)
		
		for hero in player_team.get_children():
			hero.modulate = Color(1.2, 1.2, 1.2)
			
		spawn_cards() 
		update_mana_ui()
		
	elif phase == "enemy":
		for hero in player_team.get_children():
			hero.modulate = Color(0.5, 0.5, 0.5)
		
		await get_tree().create_timer(1.0).timeout
		execute_enemy_ai()

func execute_enemy_ai():
	for enemy in get_alive_enemies():
		var alive_heroes = get_alive_players()
		if alive_heroes.is_empty(): break
		
		if enemy.has_method("process_stun_turn"):
			if enemy.process_stun_turn():
				await get_tree().create_timer(0.5).timeout
				continue 

		# 1. Get the full attack info from the enemy
		var attack_decision = enemy.decide_attack()
		
		# 2. Play Sound
		if attack_decision["sfx"] and sfx_player:
			sfx_player.stream = attack_decision["sfx"]
			sfx_player.play()

		# 3. Handle Target Selection (using the decision's AoE settings)
		var targets_to_hit = []
		if attack_decision["is_aoe"]:
			alive_heroes.shuffle()
			var hit_count = min(attack_decision["aoe_targets"], alive_heroes.size())
			for i in range(hit_count):
				targets_to_hit.append(alive_heroes[i])
		else:
			targets_to_hit.append(alive_heroes.pick_random())

		# 4. Apply Damage
		await get_tree().create_timer(0.2).timeout
		var damage_to_deal = int(enemy.base_damage * attack_decision["damage_mult"])
		
		# We still check crit here using the enemy's calculated crit chance
		var is_crit = randi() % 100 < enemy.critical_chance
		if is_crit: damage_to_deal = int(damage_to_deal * 1.5)

		for target in targets_to_hit:
			target.take_damage(damage_to_deal, is_crit)

		await get_tree().create_timer(0.8).timeout
	
	check_battle_status()
	if not get_alive_players().is_empty():
		end_current_phase()

func spawn_cards():
	var current_cards_in_hand = hand_container.get_child_count()
	var cards_to_draw = hand_size - current_cards_in_hand
	
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
	if sfx_player:
		sfx_player.stop()
		
	check_battle_status()
	current_phase_index += 1
	
	if current_phase_index >= phases.size():
		current_phase_index = 0
		advance_round()
	
	start_current_phase()

func _on_card_played(data: CardData, card_node: Node):
	if phases[current_phase_index] != "player": return
	if slotted_nodes.size() >= max_slots: return 
	if current_mana < data.mana_cost:
		if card_node.has_method("animate_error"):
			card_node.animate_error() 
		return
	
	# 1. Pay Mana FIRST
	current_mana -= data.mana_cost
	
	# 2. Move the card to the slot BEFORE calling update_mana_ui
	if card_node.has_method("set_description_visible"):
		card_node.set_description_visible(false)
	
	if "is_in_hand" in card_node:
		card_node.is_in_hand = false

	slotted_nodes.append(card_node) 
	card_node.get_parent().remove_child(card_node)
	slot_container.add_child(card_node)
	
	# 3. Reset the color of THIS specific card immediately
	# We target the 'content' node specifically since that's what turned dark
	var content = card_node.get_node_or_null("Visuals/VBoxContainer")
	if content:
		content.modulate = Color(1, 1, 1)
	card_node.modulate = Color(1, 1, 1)

	# 4. Now update the rest of the hand
	update_mana_ui()
	
	# 5. Handle the button logic
	var btn = card_node.get_node("Visuals/VBoxContainer/PlayButton")
	if btn.pressed.is_connected(_on_card_played):
		btn.pressed.disconnect(_on_card_played)
	
	btn.pressed.connect(return_card_to_hand.bind(data, card_node))
	btn.text = "Return"
	
func return_card_to_hand(data: CardData, card_node: Node):
	if is_processing_turn: return
	
	current_mana += data.mana_cost
	current_mana = min(current_mana, max_mana)

	slotted_nodes.erase(card_node) 
	
	card_node.get_parent().remove_child(card_node)
	hand_container.add_child(card_node)
	
	if "is_in_hand" in card_node:
		card_node.is_in_hand = true
	
	if card_node.has_method("set_description_visible"):
		# Show description again if the global info toggle is ON
		card_node.set_description_visible(is_info_mode_on)
	
	var btn = card_node.get_node("Visuals/VBoxContainer/PlayButton")
	if btn.pressed.is_connected(return_card_to_hand):
		btn.pressed.disconnect(return_card_to_hand)
		
	btn.pressed.connect(_on_card_played.bind(data, card_node))
	
	btn.text = "Play (" + str(data.mana_cost) + ")"
	
	update_mana_ui()
		
func _on_end_turn_button_pressed():
	if is_processing_turn: return 
	if phases[current_phase_index] != "player": return
	
	is_processing_turn = true 
	
	await execute_slotted_actions()
	
	end_current_phase()
	
	is_processing_turn = false

func update_mana_ui():
	if mana_label:
		mana_label.text = "Mana: " + str(current_mana) + "/" + str(max_mana)
	
	var is_player_phase = phases[current_phase_index] == "player"

	for card in hand_container.get_children():
		if "card_data" in card and card.card_data != null:
			var cost = card.card_data.mana_cost
			var btn = card.get_node("Visuals/VBoxContainer/PlayButton")
			var content = card.get_node("Visuals/VBoxContainer") 
			
			if not is_player_phase or cost > current_mana:
				btn.disabled = true
				content.modulate = Color(0.4, 0.4, 0.4) 
			else:
				btn.disabled = false
				content.modulate = Color(1, 1, 1)

	for card in slot_container.get_children():
		card.modulate = Color(1, 1, 1)
		var btn = card.get_node_or_null("Visuals/VBoxContainer/PlayButton")
		var content = card.get_node_or_null("Visuals/VBoxContainer")
		if content:
			content.modulate = Color(1, 1, 1) # Force it to white
		if btn:
			btn.disabled = false

func reshuffle_discard_into_deck():
	if discard_pile.is_empty():
		return
		
	deck = discard_pile.duplicate()
	discard_pile.clear()
	deck.shuffle()
	
func advance_round():
	round_number += 1

func execute_slotted_actions():
	is_processing_turn = true
	
	for card_node in slotted_nodes:
		if get_alive_enemies().is_empty():
			break 
		
		if not is_instance_valid(card_node): continue
		
		var data = card_node.card_data 
		
		if card_node.has_method("animate_as_active"):
			card_node.animate_as_active()
		
		await get_tree().create_timer(0.2).timeout

		if data.sound_effect and sfx_player:
			sfx_player.stream = data.sound_effect
			sfx_player.play()
		
		# Damage Logic
		if data.damage > 0:
			var targets = get_targets_for_action(data.is_aoe, data.aoe_targets)
			if not targets.is_empty():
				var final_damage = Global.get_card_damage(data)
				var is_crit = randi() % 100 < data.critical_chance
				for target in targets:
					target.take_damage(final_damage if not is_crit else int(final_damage * 1.5), is_crit)
		
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
					
		if data.mana_gain > 0:
			var gain = Global.get_card_mana(data)
			current_mana = min(current_mana + gain, max_mana)
			spawn_mana_popup(gain)
			update_mana_ui()
			
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
		
		if data.stuns_enemy:
			var targets = get_targets_for_action(data.is_aoe, data.aoe_targets)
			if not targets.is_empty():
				for target in targets:
					if target.has_method("apply_stun"):
						target.apply_stun(data.stun_duration)
						
		discard_pile.append(data)
		
		if get_alive_enemies().is_empty():
			await get_tree().create_timer(1.2).timeout 
			break
			
		await get_tree().create_timer(1).timeout
		
	for child in slot_container.get_children():
		child.queue_free()
		
	slotted_nodes.clear()
	
	check_battle_status()


func get_alive_enemies() -> Array:
	var alive = []
	for enemy in enemy_team.get_children():
		if is_instance_valid(enemy) and enemy.current_health > 0:
			alive.append(enemy)
	return alive

func setup_tower_enemies():
	var enemy_nodes = enemy_team.get_children()
	var selected_floor_data: Array[EnemyData] = []
	
	# --- 1. CALCULATE GROWTH ---
	var growth_percent = 0.05 
	var growth_multiplier = 1.0 + (Global.current_tower_floor * growth_percent)
	
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
		node.current_health = 0 

	for i in range(selected_floor_data.size()):
		if i < enemy_nodes.size():
			var enemy_resource = selected_floor_data[i]
			
			# Load base stats
			enemy_nodes[i].setup_enemy(enemy_resource)
			
			# Apply scaling
			var new_max_hp = int(enemy_nodes[i].max_health * growth_multiplier)
			var new_dmg = int(enemy_nodes[i].base_damage * growth_multiplier)
			
			enemy_nodes[i].max_health = new_max_hp
			enemy_nodes[i].current_health = new_max_hp 
			enemy_nodes[i].base_damage = new_dmg
			
			if enemy_nodes[i].has_method("update_ui"):
				enemy_nodes[i].update_ui()
			
			print("Stage ", Global.current_tower_floor, " | Enemy HP: ", new_max_hp, " (Mult: ", growth_multiplier, ")")
			
			enemy_nodes[i].show() 
			
			if not enemy_nodes[i].enemy_selected.is_connected(_on_enemy_clicked):
				enemy_nodes[i].enemy_selected.connect(_on_enemy_clicked)
				
func check_battle_status():
	purge_dead_cards()
	
	var alive_enemies = get_alive_enemies()
	var alive_players = get_alive_players()
	
	if alive_players.is_empty():
		await get_tree().create_timer(1.0).timeout
		fade_out_music()
		GlobalMenu.show_loss_menu() 
		return
		
	if alive_enemies.is_empty():
		await get_tree().create_timer(0.5).timeout
		
		if Global.current_tower_floor > 0:
			Global.mark_floor_cleared(Global.current_tower_floor) 
			fade_out_music()
			GlobalMenu.show_victory_menu()
	
func get_alive_players() -> Array:
	var alive = []
	for hero in player_team.get_children():
		if is_instance_valid(hero) and hero.current_health > 0:
			alive.append(hero)
	return alive

func spawn_mana_popup(amount: int):
	if mana_label == null: return
	
	var popup = mana_popup_scene.instantiate()
	$CanvasLayer.add_child(popup)
	
	popup.global_position = mana_label.global_position + Vector2(20, -20)
	popup.setup(amount)

func _on_global_info_button_pressed():
	is_info_mode_on = !is_info_mode_on
	
	var btn = get_node_or_null("CanvasLayer/GlobalInfoButton")
	if btn:
		btn.text = "Hide Card Info" if is_info_mode_on else "Show Card Info"

	for card in hand_container.get_children():
		if is_instance_valid(card) and card.has_method("set_description_visible"):
			card.set_description_visible(is_info_mode_on)

func _on_enemy_clicked(clicked_enemy):
	for enemy in get_alive_enemies():
		enemy.set_target_lock(false)
	clicked_enemy.set_target_lock(true)
	

func get_targets_for_action(is_aoe: bool, num_targets: int) -> Array:
	var alive_enemies = get_alive_enemies()
	var targets = []
	
	if alive_enemies.is_empty():
		return targets

	var locked_enemy = null
	for e in alive_enemies:
		if e.is_locked_target:
			locked_enemy = e
			break
	
	if is_aoe:
		if locked_enemy:
			targets.append(locked_enemy)
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

func _on_menu_button_pressed() -> void:
	GlobalMenu.show_pause_menu()

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
	

func purge_dead_cards():
	# 1. Create a list of CharacterData for heroes that are actually ALIVE in the scene
	var alive_hero_data: Array = []
	
	for hero in player_team.get_children():
		# Safety check: ensures we only look at living BattleCharacter nodes
		if is_instance_valid(hero) and hero.current_health > 0:
			# We assume your BattleCharacter script has a 'character_data' variable 
			# assigned during setup_character()
			if hero.get("character_data"):
				alive_hero_data.append(hero.character_data)
	
	# 2. Helper function to check if a card belongs to any of the alive heroes
	var card_is_valid = func(card_res: CardData):
		for data in alive_hero_data:
			# Check if it's the signature card
			if data.unique_card == card_res:
				return true
			# Check if it's one of the common cards
			if card_res in data.common_cards:
				return true
		return false

	# 3. Filter the Arrays
	deck = deck.filter(card_is_valid)
	discard_pile = discard_pile.filter(card_is_valid)
	
	# 4. Remove dead cards from the Hand UI
	for card_node in hand_container.get_children():
		if is_instance_valid(card_node) and card_node.card_data:
			if not card_is_valid.call(card_node.card_data):
				card_node.queue_free()
				
	# 5. Remove dead cards from Slots UI
	for card_node in slotted_nodes.duplicate():
		if is_instance_valid(card_node) and card_node.card_data:
			if not card_is_valid.call(card_node.card_data):
				slotted_nodes.erase(card_node)
				card_node.queue_free()
