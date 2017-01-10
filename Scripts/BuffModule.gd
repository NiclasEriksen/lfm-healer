extends Node

export(String, "physical", "fire", "water", "life", "earth", "death", "stun") var effect_type = "physical"
export(String, "hp", "mp", "movement_speed") var effect_stat = "hp"
export(float) var amount = 0
var is_buff = true
export(float, 0, 60, 0.1) var time = 1.0
export(float, 0, 10, 0.05) var tick_interval = 0.3
var tick_timer = 0.0
var buff_timer = 0.0


func _ready():
	pass

func buff_update(delta):
	buff_timer += delta
	tick_timer += delta
	if buff_timer >= time:
		buff_timer = 0.0
		tick_timer = 0.0
		return [false, false]
	else:
		if tick_timer >= tick_interval:
			tick_timer = 0.0
			return [true, true]
		else:
			return [true, false]