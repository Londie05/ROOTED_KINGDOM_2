extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass


func _on_start_battle_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/start_battle.tscn")


func _on_inventory_and_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/inventory_and_shop.tscn")


func _on_characters_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/characters.tscn")


func _on_tutorial_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/tutorial.tscn")


func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://Scene/User Interfaces/settings.tscn")
