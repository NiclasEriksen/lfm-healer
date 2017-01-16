extends Node

export(String, "physical", "fire", "water", "life", "earth", "death", "stun") var effect_type = "physical"
export(String, "max_hp", "max_mp", "movement_speed", "attack_speed") var effect_stat = "movement_speed"
export(String, "percentage", "flat") var apply_as = "percentage" setget set_apply_as, get_apply_as
export(float) var amount = 0.0 setget set_amount, get_amount
var unique_ref = null setget set_unique_ref, get_unique_ref
var is_buff = false
var is_status = true
export(bool) var stacking = false setget set_stacking, get_stacking
export(float, 0, 60, 0.1) var time = 1.0 setget set_time, get_time
var buff_timer = 0.0

func set_time(val):
	time = float(val)

func get_time():
	return time

func set_unique_ref(val):
	unique_ref = val

func get_unique_ref():
	return unique_ref

func set_amount(val):
	amount = float(val)

func get_amount():
	return amount

func _ready():
#	unique_ref = "toto"
	pass

func status_update(delta):
	buff_timer += delta
	if buff_timer >= time:
		buff_timer = 0.0
		return false
	else:
		return true

func get_apply_as():
	return apply_as

func set_apply_as(val):
	apply_as = val

func get_stacking():
	return stacking

func set_stacking(val):
	stacking = val

func get_effect_amount(val):
	if get_apply_as() == "percentage":
		return val * get_amount() / 100
	elif get_apply_as() == "flat":
		return get_amount()
	print("what?! unable to calculate status effect amount using > ", get_apply_as())
	return 0.0
