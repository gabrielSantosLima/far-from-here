class_name Barco
extends Node2D

## Base para todos os navios: física de vela/leme, balanço (navegação) e esteira.

@export var max_speed := 230.0
@export var accel := 180.0
@export var brake := 240.0
@export var turn_speed := 2.0
@export var bob_amp := 1.8
@export var wobble_speed := 2.6
@export var has_wake := true

var speed := 0.0
var _steer := 0.0
var _t := 0.0
var _wake: CPUParticles2D
@onready var _sprite: Sprite2D = get_node_or_null("Sprite2D")

func _ready() -> void:
	if has_wake:
		_build_wake()

func _process(delta: float) -> void:
	_t += delta
	if _sprite:
		_sprite.position.y = sin(_t * wobble_speed) * bob_amp
		_sprite.rotation = sin(_t * wobble_speed * 0.7) * 0.02 - _steer * 0.12
	if _wake:
		_wake.emitting = absf(speed) > 25.0

## throttle: -1 (ré) .. 1 (vela cheia) | steer: -1 (bombordo) .. 1 (estibordo)
func navigate(throttle: float, steer_input: float, delta: float) -> void:
	_steer = clampf(steer_input, -1.0, 1.0)
	rotation += _steer * turn_speed * delta
	if throttle > 0.0:
		speed = move_toward(speed, max_speed * throttle, accel * delta)
	elif throttle < 0.0:
		speed = move_toward(speed, max_speed * 0.45 * throttle, accel * delta)
	else:
		speed = move_toward(speed, 0.0, brake * delta)
	var dir := Vector2.UP.rotated(rotation)
	global_position = Mapa.clamp_pos(global_position + dir * speed * delta)

func _build_wake() -> void:
	_wake = CPUParticles2D.new()
	_wake.name = "Esteira"
	_wake.texture = load("res://assets/vfx/PNG (Transparent)/circle_05.png")
	_wake.amount = 24
	_wake.lifetime = 1.0
	_wake.direction = Vector2(0, 1)
	_wake.spread = 22.0
	_wake.gravity = Vector2.ZERO
	_wake.initial_velocity_min = 10.0
	_wake.initial_velocity_max = 35.0
	_wake.scale_amount_min = 0.05
	_wake.scale_amount_max = 0.13
	_wake.color = Color(1, 1, 1, 0.35)
	_wake.position = Vector2(0, 55)
	_wake.emitting = false
	add_child(_wake)
