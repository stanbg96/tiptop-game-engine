extends Control

var output: Vector2 = Vector2.ZERO
var touch_id: int = -1
var radius: float = 65.0
var knob_pos: Vector2 = Vector2.ZERO

func _ready():
custom_minimum_size = Vector2(160, 160)
knob_pos = size * 0.5

func _gui_input(event):
if event is InputEventScreenTouch:
if event.pressed and touch_id == -1:
touch_id = event.index
_update_knob(event.position)
elif not event.pressed and event.index == touch_id:
touch_id = -1
knob_pos = size * 0.5
output = Vector2.ZERO
queue_redraw()

elif event is InputEventScreenDrag and event.index == touch_id:
_update_knob(event.position)

func _update_knob(pos: Vector2):
var center = size * 0.5
var diff = pos - center
if diff.length() > radius:
diff = diff.normalized() * radius
knob_pos = center + diff
output = diff / radius
queue_redraw()

func _draw():
var center = size * 0.5
# Външен пръстен
draw_circle(center, radius, Color(0.1, 0.15, 0.25, 0.45))
draw_arc(center, radius, 0, TAU, 32, Color(0.0, 0.95, 1.0, 0.7), 3.0)
# Вътрешен аналогов стик
draw_circle(knob_pos, 28.0, Color(0.0, 0.95, 1.0, 0.85))
draw_circle(knob_pos, 14.0, Color(1.0, 1.0, 1.0, 0.9))
