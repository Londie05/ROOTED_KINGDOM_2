extends MarginContainer

# 1. Add a custom signal so the BattleManager knows when we click this card
signal card_clicked(card_node)

static var currently_inspecting_card: MarginContainer = null

var card_data: CardData 
@onready var visuals = $Visuals
@onready var card_image_node = $Visuals/VBoxContainer/CardImage
# 2. Replaced play_button with mana_label
@onready var mana_label = $Visuals/VBoxContainer/ManaLabel 
@onready var desc_label = $Visuals/VBoxContainer/CardImage/MarginContainer/DescriptionLabel

var allow_hover: bool = true
var click_locked: bool = false
var current_tween: Tween = null
var allow_inspect: bool = true

var is_playable: bool = true
var is_in_hand: bool = true
var is_inspecting: bool = false
var original_z_index: int = 0
var spacer_node: Control 
var original_parent_index: int = 0

const HOVER_SCALE = Vector2(1.1, 1.1)
const INSPECT_SCALE = Vector2(2.0, 2.0)
const HOVER_PULL_UP = -30.0

func _ready():
	visuals.pivot_offset = visuals.size / 2

func setup(data: CardData):
	# Connect mouse signals for hovering
	if not mouse_entered.is_connected(_on_mouse_entered):
		mouse_entered.connect(_on_mouse_entered)
	if not mouse_exited.is_connected(_on_mouse_exited):
		mouse_exited.connect(_on_mouse_exited)
	
	card_data = data
	if data.card_image:
		card_image_node.texture = data.card_image
	
	if mana_label:
		mana_label.text = "Mana: " + str(data.mana_cost)
	
	if desc_label:
		desc_label.text = data.description

func _gui_input(event):
	if not is_playable or click_locked: return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			click_locked = true
			get_tree().create_timer(0.15).timeout.connect(func(): click_locked = false)
			
			if is_inspecting:
				stop_inspecting()
			elif currently_inspecting_card == null:
				card_clicked.emit(self)
			
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if not allow_inspect: return 
			
			if is_inspecting:
				stop_inspecting()
			elif currently_inspecting_card == null:
				start_inspecting()

func _on_mouse_entered():
	if not allow_hover or not is_playable or is_inspecting or not is_in_hand: return
	
	if current_tween: current_tween.kill()
	current_tween = create_tween().set_parallel(true)
	current_tween.tween_property(visuals, "scale", HOVER_SCALE, 0.1)
	current_tween.tween_property(visuals, "position:y", HOVER_PULL_UP, 0.1)

func _on_mouse_exited():
	if not allow_hover or not is_playable or is_inspecting or not is_in_hand: return
	
	if current_tween: current_tween.kill()
	current_tween = create_tween().set_parallel(true)
	current_tween.tween_property(visuals, "scale", Vector2.ONE, 0.1)
	current_tween.tween_property(visuals, "position:y", 0.0, 0.1)

func reset_visuals_instantly():
	if current_tween:
		current_tween.kill()
	
	visuals.scale = Vector2.ONE
	visuals.position = Vector2.ZERO
	z_index = 0
	modulate = Color.WHITE
	
func start_inspecting():
	if is_inspecting or currently_inspecting_card != null: return
	
	is_inspecting = true
	currently_inspecting_card = self
	
	original_z_index = z_index
	z_index = 100 
	pivot_offset = size / 2 
	
	spacer_node = Control.new()
	spacer_node.custom_minimum_size = size
	spacer_node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var parent = get_parent()
	original_parent_index = get_index()
	parent.add_child(spacer_node)
	parent.move_child(spacer_node, original_parent_index)
	
	var start_pos = global_position
	top_level = true 
	global_position = start_pos
	
	var screen_center = get_viewport_rect().size / 2
	var target_pos = screen_center - (size * INSPECT_SCALE / 2)
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_pos, 0.25)
	tween.tween_property(self, "scale", INSPECT_SCALE, 0.25)

func stop_inspecting():
	var target_return_pos = spacer_node.global_position
	
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "global_position", target_return_pos, 0.2)
	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	
	tween.finished.connect(_on_stop_inspecting_finished)

func _on_stop_inspecting_finished():
	top_level = false
	if is_instance_valid(spacer_node):
		spacer_node.queue_free()
		
	get_parent().move_child(self, original_parent_index)
	
	is_inspecting = false
	currently_inspecting_card = null
	
	z_index = original_z_index
	visuals.position = Vector2.ZERO
	
	if get_global_rect().has_point(get_global_mouse_position()):
		_on_mouse_entered()
	else:
		_on_mouse_exited()

func animate_play():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1)

func animate_error():
	var tween = create_tween()
	var original_pos = visuals.position.x
	tween.tween_property(visuals, "position:x", original_pos + 10, 0.05)
	tween.tween_property(visuals, "position:x", original_pos - 10, 0.05)
	tween.tween_property(visuals, "position:x", original_pos, 0.05)
	visuals.modulate = Color.RED
	tween.finished.connect(func(): visuals.modulate = Color.WHITE)

func animate_as_active():
	var tween = create_tween()
	visuals.modulate = Color(2.03, 1.962, 1.802, 1.0) 
	tween.tween_interval(0.8) 
	tween.tween_property(visuals, "modulate", Color(1, 1, 1), 0.2)
