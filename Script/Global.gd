extends Node

# --- EXISTING VARIABLES ---
var current_tower_floor: int = 1
var floors_cleared: Array = [] 
var selected_team: Array[CharacterData] = []
var player_team: Array = []

# --- NEW: UPGRADE SYSTEM VARIABLES ---
var upgrade_materials: int = 500  # Starting currency (for testing)
var card_levels: Dictionary = {}  # Format: { "Fireball": 0, "Slash": 2 }
# Note: 0 in the dictionary means "Standard Level 1". 
# 1 means "Level 2" (1 upgrade applied).

# --- EXISTING FUNCTIONS ---
func add_to_team(data: CharacterData):
	selected_team.append(data)
		
func clear_team():
	selected_team.clear()

func mark_floor_cleared(floor_num: int):
	if not floors_cleared.has(floor_num):
		floors_cleared.append(floor_num)

# --- NEW: CALCULATOR FUNCTIONS ---

# 1. Get Damage based on Level
func get_card_damage(data: CardData) -> int:
	# If the card isn't in our dictionary yet, it's level 0 (Base stats)
	var lvl = card_levels.get(data.card_name, 0)
	return data.damage + (data.damage_growth * lvl)

# 2. Get Shield based on Level
func get_card_shield(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	return data.shield + (data.shield_growth * lvl)

# 3. Get Heal based on Level
func get_card_heal(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	return data.heal_amount + (data.heal_growth * lvl)

func get_card_mana(data: CardData) -> int:
	var lvl = card_levels.get(data.card_name, 0)
	return data.mana_gain + (data.mana_gain * lvl)

# 4. Get the Current Level Number (For UI)
func get_card_level_number(data: CardData) -> int:
	# Returns 1, 2, 3... instead of 0, 1, 2...
	return card_levels.get(data.card_name, 0) + 1

# 5. The Upgrade Action
func attempt_upgrade(data: CardData) -> bool:
	if upgrade_materials >= data.upgrade_cost:
		# 1. Deduct Cost
		upgrade_materials -= data.upgrade_cost
		
		# 2. Increase Level
		if not card_levels.has(data.card_name):
			card_levels[data.card_name] = 0
		
		card_levels[data.card_name] += 1
		
		print("Upgraded " + data.card_name + " to Level " + str(card_levels[data.card_name] + 1))
		return true
	else:
		print("Not enough materials!")
		return false
