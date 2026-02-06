extends Resource
class_name CardData

@export var card_name: String = ""
@export var card_image: Texture2D 
@export_multiline var description: String = ""

@export_group("Base Stats (Level 1)")
@export var damage: int = 0
@export var shield: int = 0
@export var heal_amount: int = 0 
@export var mana_gain: int = 0 
@export var stuns_enemy: bool = false 
@export var mana_cost: int = 0
@export var is_aoe: bool = false
@export var aoe_targets: int = 0
@export var critical_chance: int = 0
@export var stun_duration: int = 0

@export_group("Level Up Stats")
@export var damage_growth: int = 1    
@export var shield_growth: int = 1      
@export var heal_growth: int = 1      
@export var upgrade_cost: int = 50      

@export_group("Visuals & Audio")
@export var sound_effect: AudioStream
