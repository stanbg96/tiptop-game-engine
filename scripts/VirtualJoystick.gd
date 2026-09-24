extends Control

var output: Vector2 = Vector2.ZERO
var touch_id: int = -1
var radius: float = 50.0
var knob_pos: Vector2 = Vector2.ZERO

func _ready():
custom_minimum_size = Vector2(120, 120)
knob_pos = size / 2

func _gui_input(event):
if event is InputEventScreenTouch:
if event.pressed and touch_id == -1:
touch_id = event.index
_update_knob(event.position)
elif not event.pressed and event.index == touch_id:
touch_id = -1
knob_pos = size / 2
output = Vector2.ZERO
queue_redraw()
elif event is InputEventScreenDrag and event.index == touch_id:
_update_knob(event.position)

func _update_knob(pos: Vector2):
var center = size / 2
var diff = pos - center
if diff.length() > radius: diff = diff.normalized() * radius
knob_pos = center + diff
output = diff / radius
queue_redraw()

func _draw():
draw_circle(size / 2, radius, Color(0.1, 0.15, 0.2, 0.6))
draw_circle(knob_pos, 20.0, Color(0.0, 0.9, 1.0, 0.9))
