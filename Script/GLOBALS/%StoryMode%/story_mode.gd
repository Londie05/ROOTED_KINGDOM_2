extends Node

# This program is just a temporary saving file for Story Mode
var rewards = {
	"1-2": { "small": 100, "crystal": 2 }
}

var multiplier = {
	"1-2": 2
}

func stage_label():
	var value = str(Global._CURRENTLY_PLAYING_CHAPTER) + "-" + str(Global._current_playing_on_stage)
	return value
	
func next_stage():
	var value = str(Global._CURRENTLY_PLAYING_CHAPTER) + "-" + str(Global._current_playing_on_stage + 1)
	return value
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta: float) -> void:
#	pass
