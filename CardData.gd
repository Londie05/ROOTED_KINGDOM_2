extends Resource
class_name CardData

@export var card_name: String = ""
@export var card_image: Texture2D # For your unique images!
@export var damage: int = 0
@export var shield: int = 0
@export var heal_amount: int = 0 
@export var energy_gain: int = 0 
@export var stuns_enemy: bool = false 
@export var energy_cost: int = 1
@export var description: String = ""
