extends Node

var parent = null
var buff_module = load("res://Scripts/BuffModule.gd")
var effect_module = load("res://Scripts/EffectModule.gd")

var lvl_scale = 1.05
var str_scale = 1.1
var int_scale = 1.1
var agi_scale = 1.1
var spi_scale = 1.1
var sta_scale = 1.1
var xp = 0 # not total, only progress to next level
var attribute_points = 3
export(int) var level = 1 setget set_level, get_level
export(String, "str", "int", "agi", "spi", "sta") var primary_stat = "str"
export(int) var base_strength = 0
export(int) var base_intelligence = 0
export(int) var base_agility = 0
export(int) var base_spirit = 0
export(int) var base_stamina = 0
export(float) var max_hp = 10.0 # Replace with base
export(float) var max_mp = 5.0  # Replace with base
export(float) var hp_regen = 0.0
export(float) var mp_regen = 0.5
export(float) var base_damage = 1.0
export(float) var base_spell_power = 0.0
export(float) var base_phys_crit = 0.0
export(float) var base_spell_crit = 0.0
export(float) var base_hit_rate = 0.0
export(float) var base_armor = 0.0
export(float) var base_magic_resist = 0.0
export(float) var base_movement_speed = 100.0
export(float) var stealth_speed_increase = 30.0 setget set_stealth_speed_increase, get_stealth_speed_increase
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
var invulnerable = false setget set_invulnerable, is_invulnerable
export var stealthed = false setget set_stealthed, is_stealthed
signal stealth_broken
signal critical_hit
signal dmg_taken(origin, amount)
signal healing_taken(origin, amount)
signal leveled_up(origin)

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
	if val:
		parent.get_brain().push_state("stunned")

func is_stunned():
	return stunned

func set_invulnerable(val):
	invulnerable = val

func is_invulnerable():
	return invulnerable

func set_stealthed(val):
	stealthed = val

func is_stealthed():
	return stealthed

func set_stealth_speed_increase(val):
	stealth_speed_increase = val

func get_stealth_speed_increase():
	return stealth_speed_increase

func _ready():
	parent = get_parent()
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

func get_spi_scale():
	if primary_stat == "spi":
		return lvl_scale * spi_scale
	else:
		return lvl_scale

func get_sta_scale():
	if primary_stat == "sta":
		return lvl_scale * sta_scale
	else:
		return lvl_scale

func scale_stat(stat, scal):
	var bonus = 0.0 + stat
	if level > 1:
		bonus *= pow(scal, level - 1)
	return bonus

func apply_mp_cost(amount):
	if mp < amount:
		mp = 0
		print("We used negative mana, oh god.")
		return
	mp -= amount


func update_final_stats():
	self.final_stats = {
		hp=scale_stat(max_hp, get_sta_scale()),
		mp=scale_stat(max_mp, get_spi_scale()),
		max_hp=scale_stat(max_hp, get_sta_scale()),
		max_mp=scale_stat(max_mp, get_spi_scale()),
		strength=base_strength,
		agility=base_agility,
		intelligence=base_intelligence,
		spirit=base_spirit,
		stamina=base_stamina,
		damage=scale_stat(base_damage, get_str_scale()),
		spell_power=scale_stat(base_spell_power, get_int_scale()),
		phys_crit=scale_stat(base_phys_crit, get_agi_scale()),
		spell_crit=scale_stat(base_spell_crit, get_int_scale()),
		hit_rate=base_hit_rate,
#		armor=scale_stat(base_armor, get_str_scale()),
		armor=base_armor,
		magic_resist=base_magic_resist,
		attack_speed=base_attack_speed,
		attack_range=base_attack_range,
		movement_speed=base_movement_speed,
	}
	if not parent:
		return
	if parent.has_node("Attack"):
		var am = get_parent().get_node("Attack")
		am.set_amount(-get_actual("damage"))
	if parent.has_node("Debuff"):
		var dm = parent.get_node("Debuff")
		dm.set_amount(-get_actual("damage"))

func add_xp(amount):
	var lvl = get_level()
	xp += amount
	var next_lvl = 5 + pow(lvl, log(lvl))
	if xp >= next_lvl:
		set_level(lvl + 1)
		xp = fmod(xp, next_lvl)
		on_levelup()

func on_levelup():
	attribute_points += 1
	emit_signal("leveled_up", parent)
	update_final_stats()
	hp = get_actual("max_hp")
	mp = get_actual("max_mp")

func handle_regen(dt):
	hp += hp_regen * dt
	mp += mp_regen * dt

func _process(delta):
	handle_regen(delta)
	if hp > get_actual("max_hp"):
		hp = get_actual("max_hp")
	if mp > get_actual("max_mp"):
		mp = get_actual("max_mp")
	check_negatives()
	set_stunned(false)
	invulnerable = false
	for wr in get_children():
		if wr.is_buff:
			handle_buff(wr, delta)
		elif wr.is_status:
			handle_status(wr, delta)

func handle_status(wr, dt):
	var status_result = wr.status_update(dt)
	if status_result:
		if wr.get_status_type() == "stun":
			set_stunned(true)
		elif wr.get_status_type() == "invulnerable":
			invulnerable = true
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
		if originmodule:
			var crit_type = "phys_crit"
			if not effectmodule.effect_type == "physical":
				crit_type = "spell_crit"
			if rand_range(0, 100) < originmodule.get_actual(crit_type):
				originmodule.emit_signal("critical_hit")
				amount *= 1.5
		if parent.has_node("ActorBase"):
			if amount > 0 and effectmodule.effect_stat == "hp":
				if originmodule:
					emit_signal("healing_taken", originmodule.parent, amount)
				parent.get_node("ActorBase").on_heal()
			elif amount < 0 and effectmodule.effect_stat == "hp":
				var tar = null
				if originmodule:
					tar = originmodule.parent
#					print("damage_taken ", tar, " ", -amount)
					emit_signal("dmg_taken", tar, -amount)
				parent.get_node("ActorBase").on_hit(tar)
				if parent.is_healer():
					parent.set_target(tar)
					parent.get_brain().push_state("evade")
		if effectmodule.effect_stat == "hp" and amount < 0 and is_invulnerable():
			pass
		else:
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
			if effect.is_status:
				if effect.get_status_type() == stat:
					total_change += effect.get_amount()
			elif effect.is_buff:
				if effect.get_effect_stat() == stat:
					total_change += effect.get_amount()
					

		return_stat += total_change
		if return_stat < 0:
			return_stat = 0
		if stat == "movement_speed":
			if is_stealthed():
				return_stat += get_stealth_speed_increase()
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


func export_stats():
	return {
		"level": level,
		"xp": xp,
		"attribute_points": attribute_points,
		"primary_stat": primary_stat,
		"base_strength": base_strength,
		"base_intelligence": base_intelligence,
		"base_agility": base_agility,
		"base_spirit": base_spirit,
		"base_stamina": base_stamina,
		"max_hp": max_hp,
		"max_mp": max_mp,
		"base_damage": base_damage,
		"base_spell_power": base_spell_power,
		"base_phys_crit": base_phys_crit,
		"base_spell_crit": base_spell_crit,
		"base_hit_rate": base_hit_rate,
		"base_armor": base_armor,
		"base_magic_resist": base_magic_resist,
		"base_movement_speed": base_movement_speed,
		"stealth_speed_increase": stealth_speed_increase,
		"base_attack_speed": base_attack_speed,
		"base_attack_range": base_attack_range,
		"stealthed": stealthed
	}

func import_stats(stats):
	level = stats["level"]
	xp = stats["xp"]
	attribute_points = stats["attribute_points"]
	primary_stat = stats["primary_stat"]
	base_strength = stats["base_strength"]
	base_intelligence = stats["base_intelligence"]
	base_agility = stats["base_agility"]
	base_spirit = stats["base_spirit"]
	base_stamina = stats["base_stamina"]
	max_hp = stats["max_hp"]
	max_mp = stats["max_mp"]
	base_damage = stats["base_damage"]
	base_spell_power = stats["base_spell_power"]
	base_phys_crit = stats["base_phys_crit"]
	base_spell_crit = stats["base_spell_crit"]
	base_hit_rate = stats["base_hit_rate"]
	base_armor = stats["base_armor"]
	base_magic_resist = stats["base_magic_resist"]
	base_movement_speed = stats["base_movement_speed"]
	stealth_speed_increase = stats["stealth_speed_increase"]
	base_attack_speed = stats["base_attack_speed"]
	base_attack_range = stats["base_attack_range"]
	stealthed = stats["stealthed"]
	update_final_stats()

func _on_StatsModule_stealth_broken():
	set_stealthed(false)
