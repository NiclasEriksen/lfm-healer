extends Node
var buff_module = load("res://Scripts/BuffModule.gd")
var effect_module = load("res://Scripts/EffectModule.gd")

var lvl_scale = 1.05
var str_scale = 1.05
var int_scale = 1.1
var agi_scale = 1.1
export(int) var level = 1 setget set_level, get_level
export(String, "str", "int", "agi") var primary_stat = "str"
export(int) var base_strength = 0
export(int) var base_intelligence = 0
export(int) var base_agility = 0
export(int) var base_spirit = 0
export(int) var base_stamina = 0
export(float) var max_hp = 10.0 # Replace with base
export(float) var max_mp = 5.0  # Replace with base
export(float) var base_damage = 1.0
export(float) var base_spell_power = 0.0
export(float) var base_phys_crit = 0.0
export(float) var base_spell_crit = 0.0
export(float) var base_hit_rate = 0.0
export(float) var base_armor = 0.0
export(float) var base_magic_resist = 0.0
export(float) var base_movement_speed = 100.0
export(float) var base_attack_speed = 2.0
export(float) var base_attack_range = 20.0
var MIN_MOVEMENT_SPEED = 20.0
var hp = max_hp
var mp = max_mp
var strength = base_strength
var agility = base_agility
var intelligence = base_intelligence
var spirit = base_spirit
var stamina = base_stamina
var damage = base_damage
var spell_power = base_spell_power
var phys_crit = base_phys_crit
var spell_crit = base_spell_crit
var hit_rate = base_hit_rate
var armor = base_armor
var magic_resist = base_magic_resist
var attack_speed = base_attack_speed
var attack_range = base_attack_range
var immobile = false
var stunned = false setget set_stunned, is_stunned


var final_stats = {}
var active_effects = []

#TODO
# getset functions for all stats, reroute to functions that calculate final stats
# get = final stat, set = set base stat (should not be used dynamically)
# instead of setting base stat directly, most cases should be handled by passing modifier objects
# such as stats on gear, talent traits etc.

func set_level(lvl):
	level = lvl

func get_level():
	return level

func set_stunned(val):
	stunned = val

func is_stunned():
	return stunned

func _ready():
	self.update_final_stats()
	hp = get_actual("max_hp")
	mp = get_actual("max_mp")
	set_process(true)
	set_fixed_process(true)

func get_str_scale():
	if primary_stat == "str":
		return lvl_scale * str_scale
	else:
		return lvl_scale

func get_int_scale():
	if primary_stat == "int":
		return lvl_scale * int_scale
	else:
		return lvl_scale

func get_agi_scale():
	if primary_stat == "agi":
		return lvl_scale * agi_scale
	else:
		return lvl_scale

func scale_stat(stat, scal):
	var bonus = 0.0 + stat
	if level > 1:
		bonus *= pow(scal, level - 1)
	return bonus

func update_final_stats():
	self.final_stats = {
		hp=scale_stat(max_hp, get_str_scale()),
		mp=scale_stat(max_mp, get_int_scale()),
		max_hp=scale_stat(max_hp, get_str_scale()),
		max_mp=scale_stat(max_mp, get_int_scale()),
		strength=base_strength,
		agility=base_agility,
		intelligence=base_intelligence,
		spirit=base_spirit,
		stamina=base_stamina,
		damage=scale_stat(base_damage, max(get_str_scale(), get_agi_scale())),
		spell_power=scale_stat(base_spell_power, get_int_scale()),
		phys_crit=scale_stat(base_phys_crit, get_agi_scale()),
		spell_crit=scale_stat(base_spell_crit, get_int_scale()),
		hit_rate=base_hit_rate,
		armor=scale_stat(base_armor, get_str_scale()),
		magic_resist=scale_stat(base_magic_resist, get_str_scale()),
		attack_speed=base_attack_speed,
		attack_range=base_attack_range,
		movement_speed=base_movement_speed,
	}
	if get_parent().has_node("Attack"):
		var am = get_parent().get_node("Attack")
		am.set_amount(-get_actual("damage"))
	if get_parent().has_node("Debuff"):
		var dm = get_parent().get_node("Debuff")
		dm.set_amount(-get_actual("damage"))


func _process(delta):
	if hp > get_actual("max_hp"):
		hp = get_actual("max_hp")
	if mp > get_actual("max_mp"):
		mp = get_actual("max_mp")
	check_negatives()
	stunned = false
	for wr in get_children():
		if wr.is_buff:
			handle_buff(wr, delta)
		elif wr.is_status:
			handle_status(wr, delta)

func handle_status(wr, dt):
	var status_result = wr.status_update(dt)
	if status_result:
		if wr.get_effect_type() == "stun":
			stunned = true
	else:
		if Globals.get("debug_mode"):
			print("Removing status.")
		wr.queue_free()

func handle_buff(wr, dt):
	var buff_result = [false, false]
	buff_result = wr.buff_update(dt)
	if not buff_result[0]:
#			print("Removing buff.")
		if wr.effect_type == "stun":
			immobile = false
		wr.queue_free()
	elif buff_result[1]:
#			print("Applying tick.")
		if not wr.effect_stat == "movement_speed" and not wr.effect_stat == "attack_speed":
			var e = effect_module.new()
			e.amount = wr.amount * (wr.tick_interval / wr.time)
			e.effect_stat = wr.effect_stat
			e.effect_type = wr.effect_type
			apply_effect(e, null)
		else:
			print(wr.effect_stat)

func _fixed_process(delta):
	pass

func check_negatives():
	if hp < 0:
		hp = 0
	if mp < 0 :
		mp = 0


func apply_effect(effectmodule, originmodule): # Recieves an EffectModule, and another optional statsmodule for calculating final effects.
	if effectmodule.is_buff:
		var buff = buff_module.new()
		buff.effect_stat = effectmodule.get("effect_stat")
		buff.amount = effectmodule.get("amount")
		buff.tick_interval = effectmodule.get("tick_interval")
		buff.time = effectmodule.get("time")
		add_child(buff)
		update_final_stats()
#		print("Added buff.")
		return
	elif effectmodule.is_status:
		if not effectmodule.get_stacking():
			for se in get_children():
				if se.is_status:
					if se.get_unique_ref():
						if se.get_unique_ref() == effectmodule.get_unique_ref():
							se.queue_free()
		add_child(effectmodule)
		return
		
	if effectmodule.effect_type == "stun":
		immobile = true
	elif get(effectmodule.effect_stat) or get(effectmodule.effect_stat) == 0:
		# print(effectmodule.effect_stat, effectmodule.amount)
		var amount = effectmodule.amount * rand_range(0.9, 1.1)
		if get_parent().has_node("ActorBase"):
			if amount > 0 and effectmodule.effect_stat == "hp":
				get_parent().get_node("ActorBase").on_heal()
			elif amount < 0 and effectmodule.effect_stat == "hp":
				var tar = null
				if originmodule:
					tar = originmodule.get_parent()
				get_parent().get_node("ActorBase").on_hit(tar)
		set(effectmodule.effect_stat, get(effectmodule.effect_stat) + amount)
	else:
		print("StatsModule does not recognize that attribute: ", effectmodule.effect_stat)
	update_final_stats()

func get_actual(stat):
	var return_stat = stat
	if final_stats.has(stat):
		return_stat = final_stats[stat]
		var total_change = 0
		for effect in get_children():
			if effect.is_status and effect.get_effect_type() == stat:
				total_change += effect.get_effect_amount(return_stat)
		return_stat += total_change
		if return_stat < 0:
			return_stat = 0
		if stat == "movement_speed":
			if return_stat < MIN_MOVEMENT_SPEED:
				return MIN_MOVEMENT_SPEED
		return return_stat
	else:
		print("STAT NOT FOUND! ", stat)

func get_base(stat):
	pass

# Scaling and modifier functions #

func sp_modifier():
	return spell_power + (float(intelligence) * 1.5)

func dmg_modifier():
	return base_damage + (float(strength) * 1.25)

func armor_modifier():
	return armor
