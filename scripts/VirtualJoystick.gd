extends Control

var output: Vector2 = Vector2.ZERO
var touch_id: int = -1
var radius: float = 60.0
var knob_pos: Vector2 = Vector2.ZERO

func _ready():
knob_pos = size / 2.0

func _gui_input(event):
if event is InputEventScreenTouch:
if event.pressed and touch_id == -1:
touch_id = event.index
_update_knob(event.position)
accept_event()
elif not event.pressed and event.index == touch_id:
touch_id = -1
knob_pos = size / 2.0
output = Vector2.ZERO
queue_redraw()
elif event is InputEventScreenDrag and event.index == touch_id:
_update_knob(event.position)
accept_event()

func _update_knob(pos: Vector2):
var center = size / 2.0
var diff = pos - center
if diff.length() > radius:
diff = diff.normalized() * radius
knob_pos = center + diff
output = diff / radius # X и Y от -1 до 1
queue_redraw()

func _draw():
draw_circle(size / 2.0, radius, Color(0.2, 0.25, 0.3, 0.8))
draw_circle(knob_pos, 25.0, Color(0.0, 0.95, 1.0, 0.9))
