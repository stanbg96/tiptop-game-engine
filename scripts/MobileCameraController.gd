extends Camera3D

@export var move_speed: float = 16.0
var touch_look_id: int = -1
var touch_move_id: int = -1
var move_dir: Vector2 = Vector2.ZERO
var rot_x: float = -20.0
var rot_y: float = 0.0

func _input(event):
if event is InputEventScreenTouch:
if event.pressed:
# Лявата половина на екрана управлява движението, дясната - погледа
if event.position.x < get_viewport().size.x * 0.5:
touch_move_id = event.index
else:
touch_look_id = event.index
else:
if event.index == touch_move_id:
touch_move_id = -1
move_dir = Vector2.ZERO
elif event.index == touch_look_id:
touch_look_id = -1

elif event is InputEventScreenDrag:
if event.index == touch_look_id:
rot_y -= event.relative.x * 0.25
rot_x = clamp(rot_x - event.relative.y * 0.25, -85.0, 85.0)
rotation_degrees = Vector3(rot_x, rot_y, 0)
elif event.index == touch_move_id:
move_dir = event.relative.normalized()

func _process(delta):
if move_dir != Vector2.ZERO:
var forward = -transform.basis.z
var right = transform.basis.x
var dir = (forward * -move_dir.y + right * move_dir.x).normalized()
global_position += dir * move_speed * delta
