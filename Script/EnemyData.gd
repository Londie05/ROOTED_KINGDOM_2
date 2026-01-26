extends Resource
class_name EnemyData

@export var name: String = "Enemy"
# @export var enemy_sprite: Texture2D  <-- REMOVE THIS OLD LINE
@export var idle_animation: SpriteFrames # <-- ADD THIS NEW LINE

@export_group("Stats")
@export var max_health: int = 100
@export var base_damage: int = 10
@export var base_shield: int = 0

@export_group("Combat Rules")
@export var min_crit_chance: int = 5
@export var max_crit_chance: int = 30
@export var is_aoe: bool = false
@export var aoe_targets: int = 1
