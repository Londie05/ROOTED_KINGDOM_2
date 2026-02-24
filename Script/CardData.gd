extends Resource
class_name CardData

enum VFXPositionMode { TARGET, ENEMY_CENTER, SCREEN_CENTER, CASTER_RELATIVE }
enum TargetType { ENEMY, HERO }

@export var card_name: String = ""
@export var card_image: Texture2D 
@export_multiline var description: String = ""
@export var target_type: TargetType = TargetType.ENEMY

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
@export var animation_name: String = "attack" # Default animation name
@export var moves_to_target: bool = false     # True = Melee, False = Ranged/Magic
@export var vfx_frames: SpriteFrames # One file containing ALL your common FX
@export var vfx_animation: String = "slash" # The specific animation to play
@export var vfx_scale: float = 1.0
@export var vfx_position_mode: VFXPositionMode = VFXPositionMode.TARGET
@export var vfx_offset: Vector2 = Vector2(100, 0)
@export var vfx_vertical_lift: float = 80.0     #  How many pixels to move UP
