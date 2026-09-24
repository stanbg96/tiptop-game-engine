extends Camera3D

var yaw: float = 0.8
var pitch: float = 0.35
var distance: float = 8.0

func _input(event):
if event is InputEventScreenDrag:
yaw -= event.relative.x * 0.008
pitch = clamp(pitch - event.relative.y * 0.008, -1.2, 1.2)
_update_camera()

func _update_camera():
var pos = Vector3(
sin(yaw) * cos(pitch) * distance,
sin(pitch) * distance + 0.8,
cos(yaw) * cos(pitch) * distance
)
position = pos
look_at(Vector3(0, 0.6, 0), Vector3.UP)

func _ready():
_update_camera()
