extends Node

# This program is just a temporary saving file for Story Mode
var rewards = {
	"1-2": { "small": 100, "crystal": 20 },
	"1-4": { "small": 300, "crystal": 20 },
	"1-7": { "small": 350, "crystal": 20 },
	"1-10": { "small": 400, "crystal": 30 },
	"1-13": { "small": 500, "crystal": 30 },
	"1-18": { "small": 550, "crystal": 30 },
	"1-21": { "small": 700, "crystal": 40 },
	"1-25": { "small": 900, "crystal": 40 },
	"1-29": { "small": 1000, "crystal": 50 }
}

var multiplier = {
	"1-2": 2,
	"1-4": 3,
	"1-7": 4,
	"1-10": 5,
	"1-13": 6,
	"1-15": 7,
	"1-18": 8,
	"1-21": 9,
	"1-25": 10,
	"1-29": 11,
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
