extends CharacterBody3D

@export var speed: float = 9.0
@export var turn_speed: float = 3.5
@export var jump_velocity: float = 10.0
@export var gravity: float = 26.0

var move_forward: bool = false
var move_backward: bool = false
var turn_left: bool = false
var turn_right: bool = false
var walk_time: float = 0.0

@onready var left_leg: Node3D = $Visuals/LeftLeg
@onready var right_leg: Node3D = $Visuals/RightLeg
@onready var left_arm: Node3D = $Visuals/LeftArm
@onready var right_arm: Node3D = $Visuals/RightArm

func _physics_process(delta):
if not is_on_floor():
velocity.y -= gravity * delta

# Завъртане на играча наляво / надясно
var rot = 0.0
if turn_left: rot += 1.0
if turn_right: rot -= 1.0
rotate_y(rot * turn_speed * delta)

# Движение напред / назад
var move = 0.0
if move_forward: move += 1.0
if move_backward: move -= 1.0

var dir = -transform.basis.z * move
velocity.x = dir.x * speed
velocity.z = dir.z * speed

# Размахване на крайниците при ходене
if move != 0.0 or rot != 0.0:
walk_time += delta * 12.0
var swing = sin(walk_time) * 0.6
if left_leg: left_leg.rotation.x = swing
if right_leg: right_leg.rotation.x = -swing
if left_arm: left_arm.rotation.x = -swing
if right_arm: right_arm.rotation.x = swing
else:
if left_leg: left_leg.rotation.x = lerp(left_leg.rotation.x, 0.0, 10.0 * delta)
if right_leg: right_leg.rotation.x = lerp(right_leg.rotation.x, 0.0, 10.0 * delta)
if left_arm: left_arm.rotation.x = lerp(left_arm.rotation.x, 0.0, 10.0 * delta)
if right_arm: right_arm.rotation.x = lerp(right_arm.rotation.x, 0.0, 10.0 * delta)

move_and_slide()

func jump():
if is_on_floor():
velocity.y = jump_velocity
