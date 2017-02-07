extends Node

var state_stack = []
onready var owner = get_parent()
export(NodePath) var stats_node = null
export(NodePath) var move_node = null
export(NodePath) var actorbase_node = null
var tempdist = 500

var available_states = {
	"idle": null,
	"seek_target": preload("res://Scenes/Modules/States/SeekTarget.gd").new(),
	"follow_path": preload("res://Scenes/Modules/States/FollowPath.gd").new(),
	"attack": preload("res://Scenes/Modules/States/Attack.gd").new(),
	"seek_end": null,
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
		else:
			print("Requirements for state not met.")

func pop_state():
	print("Popping state \"" + get_current_state().name +  "\".")
	state_stack.pop_back()

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
		if not move_node == null:
			s.movemodule = get_node(move_node)
		if not actorbase_node == null:
			s.actorbasemodule = get_node(actorbase_node)

func _ready():
	register_modules()
	push_state("attack")
	set_process(true)

func _process(dt):
	var cs = get_current_state()
	if cs:
		cs.update(dt)
