extends WindowDialog

var list_item = preload("res://Scenes/UI/StatListItem.tscn")
var actor_item = preload("res://Scenes/UI/ActorListItem.tscn")
var active_actor = null
var points = 0
onready var content_root = get_node("CenterContainer/VBoxContainer/HBoxContainer")

var party_scenes = 	[
	preload("res://Scenes/Actors/Tank.tscn"),
	preload("res://Scenes/Actors/Archer.tscn"),
	preload("res://Scenes/Actors/Rogue.tscn"),
	preload("res://Scenes/Actors/Mage.tscn"),
	preload("res://Scenes/Actors/Healer.tscn")
]

var relevant = [
	"level", "base_strength", "base_intelligence", "base_agility", "base_spirit", "base_stamina",
]
#	"max_hp", "max_mp", "base_damage", "base_spell_power", "base_phys_crit", "base_spell_crit", "base_hit_rate",
#	"base_armor", "base_magic_resist", "base_movement_speed", "base_attack_speed", "base_attack_range"
var stats = {
	"level": 2,
	"xp": 0,
	"primary_stat": "int",
	"base_strength": 1,
	"base_intelligence": 1,
	"base_agility": 1,
	"base_spirit": 1,
	"base_stamina": 1,
	"max_hp": 30,
	"max_mp": 10,
	"base_damage": 6,
	"base_spell_power": 0,
	"base_phys_crit": 5.0,
	"base_spell_crit": 5.0,
	"base_hit_rate": 0,
	"base_armor": 0,
	"base_magic_resist": 0,
	"base_movement_speed": 50,
	"stealth_speed_increase": 1.2,
	"base_attack_speed": 0.6,
	"base_attack_range": 60,
	"stealthed": false
}

func _ready():
#	for d in relevant:
#		var data = stats[d]
#		var sli = list_item.instance()
#		sli.init(d, data)
#		content_root.get_node("ActorInfo/Container").add_child(sli)
	for a in party_scenes:
		var ali = actor_item.instance()
		ali.init(a)
		ali.connect("selected", self, "_on_partymember_selected")
		content_root.get_node("ActorList").add_child(ali)
	popup()

func gather_data():
	var new_stats = stats
	for c in content_root.get_node("ActorInfo/VBoxContainer/Container").get_children():
		new_stats[c.stat] = c.value
	print(new_stats)

func populate_data(d):
	var ap = d["attribute_points"]
	points = ap
	content_root.get_node("ActorInfo/VBoxContainer/Label").set_text("Points available: " + str(ap))
	for c in content_root.get_node("ActorInfo/VBoxContainer/Container").get_children():
		c.free()
	for r in relevant:
		var data = d[r]
		var sli = list_item.instance()
		sli.init(self, r, data)
		sli.connect("value_changed", self, "_on_stat_changed")
		content_root.get_node("ActorInfo/VBoxContainer/Container").add_child(sli)

func _on_partymember_selected(a):
	for c in content_root.get_node("ActorList").get_children():
		c.select(false)
	var d = a.get_node("StatsModule").export_stats()
	populate_data(d)

func _on_stat_changed(s):
	for c in content_root.get_node("ActorInfo/VBoxContainer/Container").get_children():
		c.update_value()
	content_root.get_node("ActorInfo/VBoxContainer/Label").set_text("Points available: " + str(points))


func _on_Button_pressed():
	gather_data()
