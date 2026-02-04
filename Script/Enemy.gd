extends BattleCharacter

signal enemy_selected(node)

func _ready():
	super() # This is vital to capture the original color for stun reset
	var area = get_node_or_null("ClickArea")
	if area:
		if not area.input_event.is_connected(_on_input_event):
			area.input_event.connect(_on_input_event)
			
func setup_enemy(data: EnemyData):
	if data == null:
		hide()
		return
		
	char_name = data.name
	max_health = data.max_health
	current_health = max_health
	base_damage = data.base_damage
	current_shield = data.base_shield
	
	critical_chance = randi_range(data.min_crit_chance, data.max_crit_chance)
	is_aoe = data.is_aoe
	max_aoe_targets = data.aoe_targets
	
	if anim_sprite and data.idle_animation:
		anim_sprite.sprite_frames = data.idle_animation
		anim_sprite.play("default")
		anim_sprite.flip_h = true 
		
		var first_frame = data.idle_animation.get_frame_texture("default", 0)
		if first_frame:
			var t_size = first_frame.get_size()
			var scale_factor = target_height / t_size.y
			anim_sprite.scale = Vector2(scale_factor, scale_factor)
	
	update_ui()
	show()

func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			get_viewport().set_input_as_handled()
			enemy_selected.emit(self)
