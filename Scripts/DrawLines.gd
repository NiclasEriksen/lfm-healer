extends Node2D

var points = []
var line_color = Color(80, 220, 30, 0.5)

func _ready():
	pass

func _draw():
	for i in range(points.size()):
		if i > 0:
			draw_line(points[i-1], points[i], line_color, 5)
