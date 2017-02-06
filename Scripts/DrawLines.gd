extends Node2D

var points = []
var line_color = Color(80, 220, 30, 0.5)

func _ready():
	pass

func _draw():
#	var x = 35
#	var z = get_tree().get_root().get_node("Game/Camera2D").get_zoom()
#	draw_line(Vector2(x, 50) / z, Vector2(x + 100, 50) / z, Color(1, 0, 0, 1), 5)
#	draw_line(Vector2(x, 60) / z, Vector2(x + 32, 60) / z, Color(0, 1, 0, 1), 5)

	for i in range(points.size()):
		if i > 0:
			draw_line(points[i-1], points[i], line_color, 5)
