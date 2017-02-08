extends Node

var state_stack = []
onready var owner = null
export(NodePath) var stats_node = null
export(NodePath) var move_node = null
export(NodePath) var actorbase_node = null
var tempdist = 500
signal exit_state
signal entered_state


var available_states = {
	"idle": preload("res://Scenes/Modules/States/Idle.gd").new(),
	"seek_target": preload("res://Scenes/Modules/States/SeekTarget.gd").new(),
	"follow_path": preload("res://Scenes/Modules/States/FollowPath.gd").new(),
	"follow_formation": preload("res://Scenes/Modules/States/FollowFormation.gd").new(),
	"attack": preload("res://Scenes/Modules/States/Attack.gd").new(),
	"evade": preload("res://Scenes/Modules/States/Evade.gd").new(),
	"stunned": preload("res://Scenes/Modules/States/Stunned.gd").new(),
	"celebrate": null
}

func push_state(state):
	if available_states.has(state):
		var s = available_states[state]
		if s == get_current_state() or s == null:
			return
		if s.check_reqs():
			print("Requirements met for state " + s.name + ", pushing.")
			state_stack.append(s)
			s.on_enter()
			emit_signal("entered_state", s.name)
		else:
			print("Requirements for state not met.")

func pop_state():
	emit_signal("exit_state", get_current_state().name)
	print("Popping state \"" + get_current_state().name +  "\".")
	state_stack.pop_back()
	if state_stack.size():
		print("Current state: ", get_current_state().name)

func get_current_state():
	if state_stack.size():
		return state_stack[state_stack.size() - 1]
	return null

func register_modules():
	for k in available_states:
		var s = available_states[k]
		if s == null:
			continue
		s.brain = self
		s.name = k
		if not stats_node == null:
			s.statsmodule = get_node(stats_node)
		elif owner.has_node("StatsModule"):
			s.statsmodule = owner.get_node("StatsModule")
		if not move_node == null:
			s.movemodule = get_node(move_node)
		elif owner.has_node("MoveModule"):
			s.movemodule = owner.get_node("MoveModule")
		if not actorbase_node == null:
			s.actorbasemodule = get_node(actorbase_node)
		elif owner.has_node("ActorBase"):
			s.actorbasemodule = owner.get_node("ActorBase")

func _ready():
	owner = get_parent()
	register_modules()
	push_state("idle")
	set_process(true)

func _process(dt):
	var cs = get_current_state()
	if cs:
		cs.update(dt)
