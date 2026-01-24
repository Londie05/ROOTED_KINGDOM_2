# EnemyData.gd
extends Resource
class_name EnemyData

@export var name: String = "Enemy"
@export var enemy_sprite: Texture2D

@export_group("Stats")
@export var max_health: int = 100
@export var base_damage: int = 10
@export var base_shield: int = 0

@export_group("Combat Rules")
# The random range you asked for (5% to 30%)
@export var min_crit_chance: int = 5
@export var max_crit_chance: int = 30
@export var is_aoe: bool = false
@export var aoe_targets: int = 1
