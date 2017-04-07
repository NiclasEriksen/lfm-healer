extends WindowDialog

var list_item = preload("res://Scenes/UI/StatListItem.tscn")
var actor_item = preload("res://Scenes/UI/ActorListItem.tscn")
var changes_made = false
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

var current_stats = {}
var relevant = [
	"level", "base_strength", "base_intelligence", "base_agility", "base_spirit", "base_stamina",
]
#	"max_hp", "max_mp", "base_damage", "base_spell_power", "base_phys_crit", "base_spell_crit", "base_hit_rate",
#	"base_armor", "base_magic_resist", "base_movement_speed", "base_attack_speed", "base_attack_range"

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
	var new_stats = current_stats
	for c in content_root.get_node("ActorInfo/VBoxContainer/Container").get_children():
		new_stats[c.stat] = c.value
	return new_stats

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
	if active_actor == a:
		return
	active_actor = a
	for c in content_root.get_node("ActorList").get_children():
		c.select(false)
	var d = a.get_node("StatsModule").export_stats()
	current_stats = d
	populate_data(d)

func _on_stat_changed(s):
	changes_made = true
	for c in content_root.get_node("ActorInfo/VBoxContainer/Container").get_children():
		c.update_value()
	content_root.get_node("ActorInfo/VBoxContainer/Label").set_text("Points available: " + str(points))
	get_node("CenterContainer/VBoxContainer/ButtonGroup/SaveButton").show()


func _on_Button_pressed():
	changes_made = false
	var d = gather_data()
	d["attribute_points"] = points
	if active_actor:
		active_actor.get_node("StatsModule").import_stats(d)
	for c in content_root.get_node("ActorList").get_children():
		c.refresh()
	populate_data(d)
	get_node("CenterContainer/VBoxContainer/ButtonGroup/SaveButton").hide()
