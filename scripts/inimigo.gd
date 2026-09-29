extends Barco

## Inimigos: patrulham parados até o jogador entrar no raio de detecção.
## Depois passam a perseguir, atirar bolas e — bem de perto — disparar um
## lança-chamas da proa (dano constante + queimadura no jogador).
## O boss, ao chegar à metade da vida, fica "enraivecido": +3 canhões, mais
## rápido, fogo por todos os lados e a música de batalha acelera.

@export var detect_radius := 900.0
@export var give_up_radius := 1500.0
@export var aggression := 2.5
@export var is_boss := false
@export var enemy_max_speed := 115.0
@export var max_hp := 3
@export var hit_radius := 36.0
@export var fire_cooldown := 2.4
@export var shot_speed := 260.0

@export var flame_range := 195.0
@export var flame_arc_deg := 42.0
@export var flame_dps := 1.0
@export var flame_duration := 1.4
@export var flame_cooldown := 2.6
@export var burn_duration := 2.5
@export var nova_cooldown := 4.5

const BALA := preload("res://scenes/BalaCanhao.tscn")
const FLAME_TEX := "res://assets/vfx/PNG (Transparent)/flame_01.png"

var hp := 0
var _alerted := false
var _dead := false

var _fire_t := 0.0
var _cannons := 1

var _flame: CPUParticles2D
var _flame_active := false
var _flame_time := 0.0
var _flame_rest := 0.0
var _dmg_accum := 0.0

var _enraged := false
var _nova: CPUParticles2D
var _nova_rest := 0.0

func _ready() -> void:
	super._ready()
	add_to_group("boss" if is_boss else "inimigos")
	max_speed = enemy_max_speed * (0.7 if is_boss else 1.0)
	if is_boss:
		turn_speed *= 0.8
		_cannons = 3
	hp = max_hp
	_build_flame()
	if is_boss:
		_build_nova()

func take_damage(amount: int) -> void:
	if _dead:
		return
	hp -= amount
	_flash()
	if is_boss and not _enraged and hp > 0 and hp <= max_hp / 2:
		_enrage()
	if hp <= 0:
		_morrer()

func _flash() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return
	var base := sprite.modulate
	sprite.modulate = Color(1.0, 0.3, 0.3)
	var t := create_tween()
	t.tween_property(sprite, "modulate", base, 0.18)

func _enrage() -> void:
	_enraged = true
	_cannons += 3
	max_speed *= 1.25
	fire_cooldown *= 0.7
	_nova_rest = 1.0
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite != null:
		sprite.modulate = Color(1.0, 0.55, 0.55)
	var audio := get_node_or_null("/root/Audio")
	if audio != null:
		audio.set_tempo(1.25)

func _morrer() -> void:
	_dead = true
	if _alerted:
		_set_alerted(false)
	set_physics_process(false)
	var explosao := (load("res://scenes/Explosao.tscn") as PackedScene).instantiate() as Node2D
	explosao.scale = Vector2(1.3, 1.3)
	get_parent().add_child(explosao)
	explosao.global_position = global_position
	var t := create_tween().set_parallel(true)
	t.tween_property(self, "modulate:a", 0.0, 0.5)
	t.tween_property(self, "scale", Vector2(0.5, 0.5), 0.5)
	t.chain().tween_callback(queue_free)
	call_deferred("_checar_vitoria")

## Quando não resta nenhum inimigo/boss vivo, dispara a vitória do jogador.
func _checar_vitoria() -> void:
	if get_tree().get_first_node_in_group("vitoria") != null:
		return
	for grupo in ["inimigos", "boss"]:
		for e in get_tree().get_nodes_in_group(grupo):
			if e != self and e.get("_dead") != true:
				return
	var guarda := Node.new()
	guarda.name = "GuardaVitoria"
	guarda.add_to_group("vitoria")
	if get_tree().current_scene != null:
		get_tree().current_scene.add_child(guarda)
	var p := Mapa.jogador
	if p != null and is_instance_valid(p):
		p.vencer()

func _physics_process(delta: float) -> void:
	if _dead:
		return
	var chasing := false
	var target := Mapa.jogador
	if target != null and is_instance_valid(target):
		var to: Vector2 = target.global_position - global_position
		var dist := to.length()
		if dist <= detect_radius:
			_set_alerted(true)
		elif _alerted and dist > give_up_radius:
			_set_alerted(false)
		if _alerted:
			chasing = true
			var desired := to.angle() + PI * 0.5
			var diff := wrapf(desired - rotation, -PI, PI)
			var steer := clampf(diff * aggression, -1.0, 1.0)
			navigate(1.0, steer, delta)

			_fire_t -= delta
			if _fire_t <= 0.0:
				_fire_t = fire_cooldown
				_atirar()

			_gerenciar_chamas(delta, target)

			if is_boss and _enraged:
				_nova_rest -= delta
				if _nova_rest <= 0.0:
					_nova_rest = nova_cooldown
					_nova_burst()

	if not chasing:
		_parar_chamas()
		navigate(0.0, 0.0, delta)

func _atirar() -> void:
	var p := Mapa.jogador
	if p == null or not is_instance_valid(p):
		return
	var from := global_position + Vector2.UP.rotated(rotation) * 58.0
	var ang0 := (p.global_position - from).angle()
	var dist := from.distance_to(p.global_position)
	var spread := deg_to_rad(14.0)
	for i in range(_cannons):
		var offset := (i - (_cannons - 1) * 0.5) * spread
		var to := from + Vector2.from_angle(ang0 + offset) * maxf(dist, 220.0)
		var bala = BALA.instantiate()
		get_parent().add_child(bala)
		bala.configurar(from, to, shot_speed, "inimigo", 1)

func _gerenciar_chamas(delta: float, p) -> void:
	var dist := global_position.distance_to(p.global_position)
	if _flame_active:
		_flame_time -= delta
		if _flame_time <= 0.0:
			_parar_chamas()
			_flame_rest = flame_cooldown
		else:
			_aplicar_chama(delta, p, dist)
	elif dist <= flame_range and _flame_rest <= 0.0:
		_flame_active = true
		_flame_time = flame_duration
		if _flame != null:
			_flame.emitting = true
	else:
		_flame_rest = maxf(_flame_rest - delta, 0.0)

func _aplicar_chama(delta: float, p, dist: float) -> void:
	if dist > flame_range:
		return
	var frente := Vector2.UP.rotated(rotation)
	var dir: Vector2 = (p.global_position - global_position).normalized()
	if frente.angle_to(dir) > deg_to_rad(flame_arc_deg):
		return
	_dmg_accum += flame_dps * delta
	while _dmg_accum >= 1.0:
		_dmg_accum -= 1.0
		p.take_damage(1, true)
	p.set_on_fire(burn_duration)

func _parar_chamas() -> void:
	_flame_active = false
	_flame_time = 0.0
	if _flame != null:
		_flame.emitting = false

func _nova_burst() -> void:
	if _nova != null:
		_nova.restart()
	var p = Mapa.jogador
	if p != null and is_instance_valid(p) and global_position.distance_to(p.global_position) <= flame_range:
		p.take_damage(1, true)
		p.set_on_fire(burn_duration)

func _set_alerted(v: bool) -> void:
	if v == _alerted:
		return
	_alerted = v
	if v:
		_fire_t = fire_cooldown
	var audio := get_node_or_null("/root/Audio")
	if audio == null:
		return
	if v:
		audio.enter_combat()
	else:
		audio.exit_combat()

func _build_flame() -> void:
	_flame = CPUParticles2D.new()
	_flame.name = "LancaChamas"
	_flame.texture = load(FLAME_TEX)
	_flame.amount = 36
	_flame.lifetime = 0.9
	_flame.direction = Vector2.UP
	_flame.spread = 16.0
	_flame.gravity = Vector2.ZERO
	_flame.initial_velocity_min = 220.0
	_flame.initial_velocity_max = 320.0
	_flame.scale_amount_min = 0.06
	_flame.scale_amount_max = 0.16
	_flame.color = Color(1.0, 0.55, 0.15, 0.9)
	_flame.position = Vector2(0, -58)
	_flame.emitting = false
	add_child(_flame)

func _build_nova() -> void:
	_nova = CPUParticles2D.new()
	_nova.name = "FogoRadial"
	_nova.texture = load(FLAME_TEX)
	_nova.amount = 48
	_nova.lifetime = 0.7
	_nova.one_shot = true
	_nova.explosiveness = 1.0
	_nova.direction = Vector2.UP
	_nova.spread = 180.0
	_nova.gravity = Vector2.ZERO
	_nova.radial_accel_min = 260.0
	_nova.radial_accel_max = 380.0
	_nova.scale_amount_min = 0.06
	_nova.scale_amount_max = 0.15
	_nova.color = Color(1.0, 0.5, 0.12, 0.9)
	_nova.emitting = false
	add_child(_nova)
