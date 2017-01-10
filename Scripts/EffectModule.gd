extends Node

export(String, "physical", "fire", "water", "life", "earth", "death", "stun") var effect_type = "physical"
export(String, "hp", "mp", "movement_speed") var effect_stat = "hp"
export(float) var amount = 0
var is_buff = false


func _ready():
	pass
