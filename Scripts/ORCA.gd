extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass


func orca(agent, colliding_agents, t, dt):
	"""Compute ORCA solution for agent. NOTE: velocity must be _instantly_
	changed on tick *edge*, like first-order integration, otherwise the method
	undercompensates and you will still risk colliding."""
	var lines = []
	for collider in colliding_agents:
		var result = get_avoidance_velocity(agent, collider, t, dt)
		var line = Line(agent.velocity + result[0] / 2, result[1])
		lines.append(line)
	var return_values = [halfplane_optimize(lines, agent.pref_velocity), lines]
	return return_values

func get_avoidance_velocity(agent, collider, t, dt):
	var x = -(agent.position - collider.position)
	var v = agent.velocity - collider.velocity
	var r = agent.radius + collider.radius

	var x_len_sq = x.dot(x)

	if x_len_sq >= r * r:
		var adjusted_center = x/t * (1 - (r*r)/x_len_sq)

		if (v - adjusted_center).dot(adjusted_center) < 0:
			# v lies in the front part of the cone
			var w = v - x/t
			var u = w.normalized() * r/t - w
			var n = w.normalized()
		else: # v lies in the rest of the cone
			# Rotate x in the direction of v, to make it a side of the cone.
			# Then project v onto that, and calculate the difference.
			var leg_len = sqrt(x_len_sq - r*r)
			# The sign of the sine determines which side to project on.
			var det_val = det([v, x])
			var sine = copysign(r, det_val)
			var rot = [
				[leg_len, sine],
				[-sine, leg_len]
			]
			rotated_x = rot.dot(x) / x_len_sq
			n = perp(rotated_x)
			if sine < 0:
				# Need to flip the direction of the line to make the
				# half-plane point out of the cone.
				n = -n
			u = rotated_x * v.dot(rotated_x) - v
	else:
		# We're already intersecting. Pick the closest velocity to our
		# velocity that will get us out of the collision within the next
		# timestep.
		w = v - x/dt
		u = w.normalized() * r/dt - w
		n = w.normalized()
	return [u, n]
