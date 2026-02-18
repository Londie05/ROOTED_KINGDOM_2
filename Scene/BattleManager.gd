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

@export_group("Story Mode Battles")
@export var story_ch1_stage_1_1: Array[EnemyData] = []
@export var story_ch2_stage_1_2: Array[EnemyData] = [] # Drag 3 Goblins here
@export var story_ch2_stage_1_4: Array[EnemyData] = [] # Drag the Shaman here

# --- 1. NODE LINKS ---
@onready var slot_container = %CardSlots
@onready var player_team = $PlayerTeam
@onready var enemy_team = $EnemyTeam
@onready var hand_container = %Hand
@onready var mana_label = $CanvasLayer/EnergyLabel

var is_battle_ending: bool = false

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

var vfx_scene = preload("res://Scene/EffectVFX.tscn")

var battle_themes: Array[String] = [
	"res://Asset/Sound effects/background effect1.mp3",
	"res://Asset/Sound effects/background effect2.mp3"
]

func _ready():
	for child in hand_container.get_children():
		child.queue_free()
	
	await get_tree().process_frame 
	
	# --- IMPROVED MUSIC LOGIC ---
	if Global.current_game_mode == Global.GameMode.TOWER:
		if Global.current_tower_floor == 10:
			bgm_player.stream = load("res://Asset/Sound effects/background effect3.mp3")
		else:
			var random_track_path = battle_themes.pick_random()
			bgm_player.stream = load(random_track_path)
	else:
		# Use a default Story Battle theme or keep current
		bgm_player.stream = load("res://Asset/Sound effects/background effect1.mp3")
	
	bgm_player.play()
	
	# --- IMPROVED UI LOGIC ---
	if stage_count_label:
		if Global.current_game_mode == Global.GameMode.TOWER:
			stage_count_label.text = "Floor: " + str(Global.current_tower_floor)
		else:
			stage_count_label.text = "Stage: " + Global.current_battle_stage
		
	setup_player_team()
	build_deck_from_team()
	setup_enemies()
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
	
	if not new_card.card_clicked.is_connected(_on_card_interaction):
		new_card.card_clicked.connect(_on_card_interaction)

func _on_card_interaction(card_node: Node):
	if phases[current_phase_index] != "player": return
	if is_processing_turn: return
	
	var data = card_node.card_data
	
	if card_node.is_in_hand:
		try_play_card_to_slot(data, card_node)
		
	elif card_node in slotted_nodes:
		return_card_to_hand(data, card_node)
		
func end_current_phase():
	if sfx_player:
		sfx_player.stop()
		
	check_battle_status()
	current_phase_index += 1
	
	if current_phase_index >= phases.size():
		current_phase_index = 0
		advance_round()
	
	start_current_phase()

func find_hero_owner(card_data: CardData) -> BattleCharacter:
	for hero in player_team.get_children():
		if not is_instance_valid(hero): continue
		
		# Check the Hero's data to see if they own this card
		var data = hero.character_data
		if data:
			if data.unique_card == card_data:
				return hero
			if card_data in data.common_cards:
				return hero
	return null
	
func try_play_card_to_slot(data: CardData, card_node: Node):
	if slotted_nodes.size() >= max_slots: return 
	if current_mana < data.mana_cost:
		if card_node.has_method("animate_error"):
			card_node.animate_error() 
		return
	
	current_mana -= data.mana_cost
	card_node.is_in_hand = false

	slotted_nodes.append(card_node) 
	card_node.get_parent().remove_child(card_node)
	slot_container.add_child(card_node)
	card_node.reset_visuals_instantly()
	if card_node.has_method("reset_card_visuals"):
		card_node.reset_card_visuals()
	
	update_mana_ui()
	
func return_card_to_hand(data: CardData, card_node: Node):
	if is_processing_turn: return
	
	current_mana += data.mana_cost
	current_mana = min(current_mana, max_mana)

	slotted_nodes.erase(card_node) 
	
	card_node.get_parent().remove_child(card_node)
	hand_container.add_child(card_node)
	
	if "is_in_hand" in card_node:
		card_node.is_in_hand = true
	
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
			var content = card.get_node("Visuals/VBoxContainer") 
			
			if not is_player_phase or cost > current_mana:
				content.modulate = Color(0.5, 0.5, 0.5) 
			else:
				content.modulate = Color(1, 1, 1)

	for card in slot_container.get_children():
		card.modulate = Color(1, 1, 1)
		var content = card.get_node_or_null("Visuals/VBoxContainer")
		if content:
			content.modulate = Color(1, 1, 1)

func reshuffle_discard_into_deck():
	if discard_pile.is_empty():
		return
		
	deck = discard_pile.duplicate()
	discard_pile.clear()
	deck.shuffle()
	
func advance_round():
	round_number += 1

func spawn_vfx(frames: SpriteFrames, anim: String, pos: Vector2, scale_mult: float):
	var effect = vfx_scene.instantiate()
	get_tree().current_scene.add_child(effect)
	
	effect.global_position = pos
	effect.scale = Vector2(scale_mult, scale_mult)
	effect.z_index = z_index # This ensures it's never behind a character
	effect.play_effect(frames, anim)
	
func execute_slotted_actions():
	is_processing_turn = true
	
	for card_node in slotted_nodes:
		if get_alive_enemies().is_empty():
			break
		
		if not is_instance_valid(card_node): continue
		
		var data = card_node.card_data
		
		var caster_hero = find_hero_owner(data)
		var targets = get_targets_for_action(data.is_aoe, data.aoe_targets)
		var primary_target = targets[0] if not targets.is_empty() else null
		
		# Inside execute_slotted_actions() in BattleManager.gd

		if data.vfx_frames:
			var final_pos = Vector2.ZERO
			
			match data.vfx_position_mode:
				data.VFXPositionMode.CASTER_RELATIVE:
					if is_instance_valid(caster_hero):
						# 1. Start at hero
						final_pos = caster_hero.global_position 
						# 2. Add the custom Vector2 offset (Distance)
						final_pos += data.vfx_offset 
						# 3. Subtract the lift to move it UP
						final_pos.y -= data.vfx_vertical_lift 
						
				data.VFXPositionMode.ENEMY_CENTER:
					var alive_enemies = get_alive_enemies()
					if not alive_enemies.is_empty():
						var total_pos = Vector2.ZERO
						for e in alive_enemies:
							total_pos += e.global_position
						final_pos = total_pos / alive_enemies.size()
						final_pos.y -= data.vfx_vertical_lift
						
				data.VFXPositionMode.TARGET:
					for target in targets:
						if is_instance_valid(target):
							var t_pos = target.global_position
							t_pos.y -= data.vfx_vertical_lift
							spawn_vfx(data.vfx_frames, data.vfx_animation, t_pos, data.vfx_scale)
					continue # Skip the single spawn below if we already spawned for each target

			# Spawn the effect for CASTER_RELATIVE and ENEMY_CENTER
			spawn_vfx(data.vfx_frames, data.vfx_animation, final_pos, data.vfx_scale)
				
			
		if card_node.has_method("animate_as_active"):
			card_node.animate_as_active()
		
		if caster_hero and primary_target:
			caster_hero.play_attack_sequence(primary_target, data.moves_to_target, data.animation_name)
			
			await caster_hero.attack_hit_moment
		else:
			await get_tree().create_timer(0.2).timeout
		
		if data.sound_effect and sfx_player:
			sfx_player.stream = data.sound_effect
			sfx_player.play()
		
		if data.damage > 0 and not targets.is_empty():
			var final_damage = Global.get_card_damage(data)
			var is_crit = randi() % 100 < data.critical_chance
			
			for target in targets:
				if is_instance_valid(target):
					target.take_damage(final_damage if not is_crit else int(final_damage * 1.5), is_crit)
		
		if data.shield > 0:
			var shield_targets = get_alive_players() # Shield targets are players, not enemies
			if not shield_targets.is_empty():
				var final_shield = Global.get_card_shield(data)
				if data.is_aoe:
					var hits = min(data.aoe_targets, shield_targets.size())
					for i in range(hits):
						shield_targets[i].add_shield(final_shield)
				else:
					# Helper to find lowest HP or self (modify as needed)
					shield_targets.sort_custom(func(a, b): return a.current_health < b.current_health)
					shield_targets[0].add_shield(final_shield)

		if data.heal_amount > 0:
			var heal_targets = get_alive_players()
			if not heal_targets.is_empty():
				var final_heal = Global.get_card_heal(data)
				if data.is_aoe:
					var hits = min(data.aoe_targets, heal_targets.size())
					for i in range(hits):
						heal_targets[i].heal(final_heal)
				else:
					heal_targets.sort_custom(func(a, b): return a.current_health < b.current_health)
					heal_targets[0].heal(final_heal)
					
		if data.mana_gain > 0:
			var gain = Global.get_card_mana(data)
			current_mana = min(current_mana + gain, max_mana)
			spawn_mana_popup(gain)
			update_mana_ui()
			
		if data.stuns_enemy and not targets.is_empty():
			for target in targets:
				if target.has_method("apply_stun"):
					target.apply_stun(data.stun_duration)
					
		if caster_hero:
			await caster_hero.attack_finished
		else:
			await get_tree().create_timer(0.5).timeout
			
		discard_pile.append(data)
		
		# Short pause between cards
		await get_tree().create_timer(0.7).timeout
		
	for child in slot_container.get_children():
		child.queue_free()
		
	slotted_nodes.clear()
	check_battle_status()


func get_alive_enemies() -> Array:
	var alive = []
	for enemy in enemy_team.get_children():
		if is_instance_valid(enemy) and enemy.current_health > 0 and enemy.is_visible_in_tree():
			alive.append(enemy)
	return alive

func setup_enemies():
	var enemy_nodes = enemy_team.get_children()
	var selected_data: Array[EnemyData] = []
	var growth_multiplier: float = 1.0
	# --- 1. CALCULATE GROWTH ---
	if Global.current_game_mode == Global.GameMode.TOWER:
		# --- TOWER LOGIC (Existing) ---
		var growth_percent = 0.05 
		growth_multiplier = 1.0 + (Global.current_tower_floor * growth_percent)
	
		match Global.current_tower_floor:
			1: selected_data = floor_1_enemies
			2: selected_data = floor_2_enemies
			3: selected_data = floor_3_enemies
			4: selected_data = floor_4_enemies
			5: selected_data = floor_5_enemies
			6: selected_data = floor_6_enemies
			7: selected_data = floor_7_enemies
			8: selected_data = floor_8_enemies
			9: selected_data = floor_9_enemies
			10: selected_data = floor_10_enemies
			11: selected_data = floor_11_enemies
			12: selected_data = floor_12_enemies
			13: selected_data = floor_13_enemies
			14: selected_data = floor_14_enemies
			15: selected_data = floor_15_enemies
			16: selected_data = floor_16_enemies
			17: selected_data = floor_17_enemies
			18: selected_data = floor_18_enemies
			19: selected_data = floor_19_enemies
			20: selected_data = floor_20_enemies
	elif Global.current_game_mode == Global.GameMode.STORY:
		growth_multiplier = 1.0 # Keep story battles at intended difficulty
		print("Story Mode Active. Loading Stage: ", Global.current_battle_stage)
		# This "match" looks at the ID we sent from the Chapter script
		match Global.current_battle_stage:
			"1-1": selected_data = story_ch1_stage_1_1
			"1-2": selected_data = story_ch2_stage_1_2
			"1-4": selected_data = story_ch2_stage_1_4
		
	for node in enemy_nodes:
		node.hide()
		node.current_health = 0 

	for i in range(selected_data.size()):
		if i < enemy_nodes.size():
			var enemy_resource = selected_data[i]
			
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
			
			enemy_nodes[i].show() 
			
			if not enemy_nodes[i].enemy_selected.is_connected(_on_enemy_clicked):
				enemy_nodes[i].enemy_selected.connect(_on_enemy_clicked)
				
func check_battle_status():
	if is_battle_ending: return
	
	purge_dead_cards()
	
	var alive_enemies = get_alive_enemies()
	var alive_players = get_alive_players()
	
	# --- DEFEAT ---
	if alive_players.is_empty():
		is_battle_ending = true
		await get_tree().create_timer(1.0).timeout
		fade_out_music()
		GlobalMenu.show_loss_menu() 
		return
		
	# --- VICTORY ---
	if alive_enemies.is_empty():
		is_battle_ending = true 
		
		await get_tree().create_timer(0.5).timeout
		if not is_inside_tree(): return 

		# A. STORY MODE VICTORY
		if Global.current_game_mode == Global.GameMode.STORY:
			# Record story progress
			if not Global.story_chapters_cleared.has(Global.current_battle_stage):
				Global.story_chapters_cleared.append(Global.current_battle_stage)
			
			Global.save_game() # SAVE PROGRESS
			
			Global.just_finished_battle = true
			if Global.last_story_scene_path != "":
				get_tree().change_scene_to_file(Global.last_story_scene_path)
			else:
				get_tree().change_scene_to_file("res://Scene/User Interfaces/UI scenes/Chapter Scenes/Chapter1.tscn")
		
		# B. TOWER MODE VICTORY
		else:
			# 1. RECORD THE WIN: Add the floor we JUST beat to the cleared list
			if not Global.floors_cleared.has(Global.current_tower_floor):
				Global.floors_cleared.append(Global.current_tower_floor)
			
			# 2. SAVE TO FILE: This ensures the gap disappears forever
			Global.save_game()
			
			# 3. Increment for the "Next Floor" button logic
			# We don't change Global.current_tower_floor yet, 
			# we let the Victory Menu handle the transition.
			
			if GlobalMenu.has_method("show_victory_menu"):
				GlobalMenu.show_victory_menu()
			else:
				# Fallback: Go back to selection to see the new unlocked floor
				get_tree().change_scene_to_file("res://Scene/TowerSelection.tscn")
	
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
