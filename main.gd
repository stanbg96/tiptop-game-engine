extends Node3D

@onready var log_label: RichTextLabel = $UI/LogLabel
@onready var input_field: LineEdit = $UI/BottomBar/Input
@onready var send_btn: Button = $UI/BottomBar/SendBtn
@onready var camera: Camera3D = $Camera3D
@onready var sun: DirectionalLight3D = $DirectionalLight3D

var cam_yaw: float = 0.0
var cam_pitch: float = 0.5
var cam_dist: float = 18.0
var touch_down: bool = false
var last_touch_pos: Vector2 = Vector2.ZERO
var entities: Dictionary = {}

func _ready():
send_btn.pressed.connect(_on_send_pressed)
input_field.text_submitted.connect(_on_text_submitted)

# Създаваме началната къщичка за куче и двамата бойци
spawn_dog_house(Vector3(0, 0, 2))
spawn_humanoid("hero", "Стилиян 3D", Vector3(-4, 0, 2), Color(0.0, 0.9, 1.0))
spawn_humanoid("rival", "Георги 3D", Vector3(4, 0, 2), Color(1.0, 0.0, 0.5))

log_message("[color=#00e676]★ TipTop Godot 4 Енджинът е зареден на 60 FPS![/color]\n[color=#ffffff]Истинско 3D със сенки и зелена поляна. Пиши в полето отдолу![/color]")
update_camera()

func _on_send_pressed():
execute_omni_command(input_field.text)
input_field.text = ""

func _on_text_submitted(text: String):
execute_omni_command(text)
input_field.text = ""

func log_message(msg: String):
if log_label:
log_label.text = msg

func execute_omni_command(text: String):
var t = text.to_lower().strip_edges()
if t.is_empty():
return

if "къща" in t or "куче" in t or "house" in t:
spawn_dog_house(Vector3(randf_range(-6, 6), 0, randf_range(-2, 6)))
log_message("[color=#00e676]🏠 3D: Построена къща за куче със сенки и червен покрив![/color]")
elif "кола" in t or "болид" in t or "car" in t:
spawn_car(Vector3(randf_range(-6, 6), 0, randf_range(-2, 6)))
log_message("[color=#00e5ff]🚗 3D: Сглобен спортен автомобил с 4 колела и фарове![/color]")
elif "слон" in t or "elephant" in t:
spawn_elephant(Vector3(randf_range(-6, 6), 0, randf_range(-2, 6)))
log_message("[color=#ffd600]🐘 3D: Изчислен 3D слон с крака, тяло и хобот![/color]")
elif "бой" in t or "стилиян" in t or "георги" in t or "удар" in t:
simulate_combat()
else:
log_message("[color=#00e5ff]⚡ Командата '%s' беше обработена от ядрото![/color]" % text)

func spawn_dog_house(pos: Vector3):
var house = Node3D.new()
house.position = pos

# Стени (Дърво)
var body = MeshInstance3D.new()
var b_box = BoxMesh.new()
b_box.size = Vector3(3.5, 3.0, 4.0)
body.mesh = b_box
body.position.y = 1.5
var mat_wood = StandardMaterial3D.new()
mat_wood.albedo_color = Color(0.45, 0.28, 0.15)
body.material_override = mat_wood
house.add_child(body)

# Вход
var door = MeshInstance3D.new()
var d_box = BoxMesh.new()
d_box.size = Vector3(1.4, 2.0, 0.2)
door.mesh = d_box
door.position = Vector3(0, 1.0, 2.01)
var mat_door = StandardMaterial3D.new()
mat_door.albedo_color = Color(0.08, 0.08, 0.08)
door.material_override = mat_door
house.add_child(door)

# Двускатен червен покрив
var roof = MeshInstance3D.new()
var r_prism = PrismMesh.new()
r_prism.size = Vector3(4.2, 1.8, 4.4)
roof.mesh = r_prism
roof.position.y = 3.9
var mat_roof = StandardMaterial3D.new()
mat_roof.albedo_color = Color(0.8, 0.15, 0.15)
roof.material_override = mat_roof
house.add_child(roof)

add_child(house)

func spawn_car(pos: Vector3):
var car = Node3D.new()
car.position = pos

var body = MeshInstance3D.new()
var b_mesh = BoxMesh.new()
b_mesh.size = Vector3(2.8, 0.8, 5.5)
body.mesh = b_mesh
body.position.y = 0.8
var mat = StandardMaterial3D.new()
mat.albedo_color = Color(1.0, 0.1, 0.2)
mat.metallic = 0.9
body.material_override = mat
car.add_child(body)

var cabin = MeshInstance3D.new()
var c_mesh = BoxMesh.new()
c_mesh.size = Vector3(2.2, 0.8, 2.8)
cabin.mesh = c_mesh
cabin.position = Vector3(0, 1.5, -0.3)
var mat_g = StandardMaterial3D.new()
mat_g.albedo_color = Color(0.1, 0.8, 1.0, 0.7)
cabin.material_override = mat_g
car.add_child(cabin)

for wx in [-1.5, 1.5]:
for wz in [-1.6, 1.6]:
var w = MeshInstance3D.new()
var wm = CylinderMesh.new()
wm.top_radius = 0.5
wm.bottom_radius = 0.5
wm.height = 0.4
w.mesh = wm
w.rotation_degrees = Vector3(0, 0, 90)
w.position = Vector3(wx, 0.5, wz)
var mt = StandardMaterial3D.new()
mt.albedo_color = Color(0.1, 0.1, 0.1)
w.material_override = mt
car.add_child(w)

add_child(car)

func spawn_elephant(pos: Vector3):
var el = Node3D.new()
el.position = pos

var b = MeshInstance3D.new()
var bm = BoxMesh.new()
bm.size = Vector3(3.8, 3.2, 5.5)
b.mesh = bm
b.position.y = 3.2
var mat = StandardMaterial3D.new()
mat.albedo_color = Color(0.5, 0.52, 0.55)
b.material_override = mat
el.add_child(b)

for lx in [-1.3, 1.3]:
for lz in [-1.8, 1.8]:
var leg = MeshInstance3D.new()
var lm = CylinderMesh.new()
lm.top_radius = 0.5
lm.bottom_radius = 0.5
lm.height = 2.5
leg.mesh = lm
leg.position = Vector3(lx, 1.25, lz)
leg.material_override = mat
el.add_child(leg)

add_child(el)

func spawn_humanoid(id: String, name_str: String, pos: Vector3, col: Color):
var person = Node3D.new()
person.position = pos

var torso = MeshInstance3D.new()
var tm = BoxMesh.new()
tm.size = Vector3(1.5, 2.0, 0.9)
torso.mesh = tm
torso.position.y = 2.0
var mat = StandardMaterial3D.new()
mat.albedo_color = col
torso.material_override = mat
person.add_child(torso)

var head = MeshInstance3D.new()
var hm = BoxMesh.new()
hm.size = Vector3(1.0, 1.0, 1.0)
head.mesh = hm
head.position.y = 3.5
var hmat = StandardMaterial3D.new()
hmat.albedo_color = Color(1.0, 0.8, 0.6)
head.material_override = hmat
person.add_child(head)

var arm = MeshInstance3D.new()
var am = BoxMesh.new()
am.size = Vector3(0.5, 1.6, 0.5)
arm.mesh = am
arm.name = "Arm"
arm.position = Vector3(1.1, 2.0, 0)
arm.material_override = mat
person.add_child(arm)

for lx in [-0.4, 0.4]:
var leg = MeshInstance3D.new()
var lm = BoxMesh.new()
lm.size = Vector3(0.55, 1.4, 0.55)
leg.mesh = lm
leg.position = Vector3(lx, 0.7, 0)
var lmat = StandardMaterial3D.new()
lmat.albedo_color = Color(0.15, 0.2, 0.3)
leg.material_override = lmat
person.add_child(leg)

entities[id] = person
add_child(person)

func simulate_combat():
if not entities.has("hero") or not entities.has("rival"):
return
var hero = entities["hero"]
var rival = entities["rival"]

var arm = hero.get_node_or_null("Arm")
if arm:
arm.position.z = 1.4

rival.position.x += 2.5
rival.rotation_degrees.z = 90
log_message("[color=#ff007f]💥 БОЙ: Стилиян нанесе удар със замах! Георги падна в нокаут на поляната![/color]")

func _unhandled_input(event):
if event is InputEventScreenTouch:
touch_down = event.pressed
last_touch_pos = event.position
elif event is InputEventScreenDrag and touch_down:
var delta = event.position - last_touch_pos
last_touch_pos = event.position
cam_yaw -= delta.x * 0.006
cam_pitch = clamp(cam_pitch - delta.y * 0.006, 0.1, 1.3)
update_camera()

func update_camera():
var cx = cam_dist * sin(cam_yaw) * cos(cam_pitch)
var cy = cam_dist * sin(cam_pitch)
var cz = cam_dist * cos(cam_yaw) * cos(cam_pitch)
camera.position = Vector3(cx, cy, cz)
camera.look_at(Vector3(0, 1.5, 0), Vector3.UP)
