extends Resource
class_name CharacterData

@export var name: String = "Hero"
# DELETE the old texture lines if you don't use them anymore, or keep them for UI
@export var character_sprite: Texture2D 
@export var character_illustration: Texture2D

@export_group("Stats")
@export var max_health: int = 100
@export var base_shield: int = 0
@export var base_damage: int = 10

@export_group("Deck")
@export var unique_card: CardData
@export var common_cards: Array[CardData]

@export var is_locked: bool = false 
@export var unlock_cost: int = 1000

# --- THE IMPORTANT NEW PART ---
@export var idle_animation: SpriteFrames 
# ------------------------------
