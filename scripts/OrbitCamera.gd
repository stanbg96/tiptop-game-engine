extends Camera3D

var yaw: float = 0.7
var pitch: float = 0.3
var distance: float = 7.5

func _ready():
_update_camera()

func _input(event):
if event is InputEventScreenDrag:
yaw -= event.relative.x * 0.008
pitch = clamp(pitch - event.relative.y * 0.008, -0.2, 1.2)
_update_camera()

func _update_camera():
var pos = Vector3(
sin(yaw) * cos(pitch) * distance,
sin(pitch) * distance + 1.2,
cos(yaw) * cos(pitch) * distance
)
position = pos
look_at(Vector3(0, 0.7, 0), Vector3.UP)
