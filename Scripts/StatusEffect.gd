extends Node

export(String, "physical", "fire", "water", "life", "earth", "death", "stun") var effect_type = "physical"
export(String, "max_hp", "max_mp", "movement_speed", "attack_speed") var effect_stat = "movement_speed"
export(float) var amount = 0.0
var is_buff = false
var is_status = true
export(float, 0, 60, 0.1) var time = 1.0
var buff_timer = 0.0


func _ready():
	pass

func status_update(delta):
	buff_timer += delta
	if buff_timer >= time:
		buff_timer = 0.0
		return true
	else:
		return false
