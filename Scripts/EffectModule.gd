extends "res://Scripts/EffectBase.gd"

export(String, "physical", "fire", "water", "life", "earth", "death", "stun") var effect_type = "physical"
export(String, "hp", "mp", "movement_speed") var effect_stat = "hp"
export(float) var amount = 0 setget set_amount, get_amount
var is_buff = false
var is_status = false


func set_amount(a):
	amount = float(a)

func get_amount():
	return amount

func _ready():
	pass
