extends Barco

## Controles do Capitão Piteu:
##   W / ↑ acelerar | S / ↓ desacelerar | A / ← bombordo | D / → estibordo
##   Mouse mirar | Botão esquerdo atirar bola de canhão

const BALA := preload("res://scenes/BalaCanhao.tscn")
const EXPLOSAO := preload("res://scenes/Explosao.tscn")
const FLAME_TEX := "res://assets/vfx/PNG (Transparent)/flame_01.png"
const CENA_GAMEOVER := "res://scenes/GameOver.tscn"
const CENA_VITORIA := "res://scenes/Vitoria.tscn"

@export var fire_cooldown := 0.7
@export var shot_speed := 330.0
@export var max_hp := 10

## Energia: cada tiro custa 1 e o boost no Shift custa boost_custo. Ao zerar,
## o capitão dorme por sono_duracao (imóvel, com "Zzz") e acorda com a energia
## cheia. A energia recarrega 1 ponto a cada energia_recarga segundos.
@export var max_energia := 10
@export var custo_tiro := 1
@export var energia_recarga := 2.0
@export var sono_duracao := 3.0

@export var boost_custo := 5
@export var boost_duracao := 2.0
@export var boost_multiplicador := 1.8

var hp := 0
var energia := 0
var _cooldown := 0.0
var _invuln := 0.0
var _burn_time := 0.0
var _burn_tick := 0.0
var _regen_acum := 0.0
var _dormindo := false
var _sono_t := 0.0
var _boost_t := 0.0
var _base_max_speed := 0.0
var _game_over := false
var _fire_fx: CPUParticles2D
var _zzz: Label

func _ready() -> void:
	super._ready()
	Mapa.ensure_input()
	add_to_group("jogador")
	Mapa.jogador = self
	hp = max_hp
	energia = max_energia
	_base_max_speed = max_speed
	_build_fire_fx()
	_build_zzz()

func _physics_process(delta: float) -> void:
	if _dormindo:
		_atualizar_sono(delta)
		_atualizar_zzz()
		_atualizar_queimadura(delta)
		return

	_invuln = maxf(_invuln - delta, 0.0)
	_cooldown = maxf(_cooldown - delta, 0.0)
	_boost_t = maxf(_boost_t - delta, 0.0)
	if Input.is_action_just_pressed("boost") and _boost_t <= 0.0 and energia >= boost_custo:
		energia -= boost_custo
		if energia <= 0:
			_dormir()
			_atualizar_zzz()
			_atualizar_queimadura(delta)
			return
		_boost_t = boost_duracao

	var boost := _boost_t > 0.0
	var throttle := Input.get_axis("desacelerar", "acelerar")
	if boost:
		throttle = maxf(throttle, 1.0)
	var steer := Input.get_axis("esquerda", "direita")
	max_speed = _base_max_speed * (boost_multiplicador if boost else 1.0)
	navigate(throttle, steer, delta)

	if Input.is_action_pressed("atirar") and _cooldown <= 0.0:
		_atirar()

	_recarregar_energia(delta)
	_atualizar_queimadura(delta)

func _atirar() -> void:
	if _dormindo or energia < custo_tiro:
		return
	_cooldown = fire_cooldown
	energia -= custo_tiro
	var from := global_position + Vector2.UP.rotated(rotation) * 58.0
	var to := get_global_mouse_position()
	_disparar(from, to)
	if energia <= 0:
		_dormir()

func _recarregar_energia(delta: float) -> void:
	if _dormindo or energia >= max_energia:
		_regen_acum = 0.0
		return
	_regen_acum += delta
	while _regen_acum >= energia_recarga:
		_regen_acum -= energia_recarga
		energia = mini(energia + 1, max_energia)

func _dormir() -> void:
	_dormindo = true
	_sono_t = sono_duracao
	_boost_t = 0.0
	speed = 0.0
	if _zzz != null:
		_zzz.visible = true

func _atualizar_sono(delta: float) -> void:
	_sono_t -= delta
	if _sono_t <= 0.0:
		_dormindo = false
		energia = max_energia
		_regen_acum = 0.0
		if _zzz != null:
			_zzz.visible = false

func _atualizar_zzz() -> void:
	if _zzz == null:
		return
	_zzz.global_position = global_position + Vector2(-14.0, -94.0)
	_zzz.rotation = -rotation

func _disparar(from: Vector2, to: Vector2) -> void:
	var bala = BALA.instantiate()
	get_parent().add_child(bala)
	bala.configurar(from, to, shot_speed, "jogador", 1)

	var flash := EXPLOSAO.instantiate() as Node2D
	flash.scale = Vector2(0.22, 0.22)
	get_parent().add_child(flash)
	flash.global_position = from

## fogo = true: ignora invulnerabilidade e é dano de queimadura (chip).
func take_damage(amount: int, fogo := false) -> void:
	if hp <= 0:
		return
	if not fogo:
		if _invuln > 0.0:
			return
		_invuln = 0.6
	hp -= amount
	_flash()
	if hp <= 0:
		_morrer()

func set_on_fire(duration := 3.0) -> void:
	_burn_time = maxf(_burn_time, duration)
	if _fire_fx != null:
		_fire_fx.emitting = true

func _atualizar_queimadura(delta: float) -> void:
	if _burn_time <= 0.0:
		return
	_burn_time -= delta
	_burn_tick -= delta
	if _burn_tick <= 0.0:
		_burn_tick = 1.0
		take_damage(1, true)
	if _burn_time <= 0.0 and _fire_fx != null:
		_fire_fx.emitting = false

func _flash() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return
	var base := sprite.modulate
	sprite.modulate = Color(1.0, 0.3, 0.3)
	var t := create_tween()
	t.tween_property(sprite, "modulate", base, 0.2)

## Ao afundar, abre a tela de game over (Espaço reinicia a fase).
func _morrer() -> void:
	if _game_over:
		return
	_game_over = true
	_dormindo = false
	_burn_time = 0.0
	speed = 0.0
	set_physics_process(false)
	if _fire_fx != null:
		_fire_fx.emitting = false
	if _zzz != null:
		_zzz.visible = false
	var transicao := get_node_or_null("/root/Transicao")
	if transicao == null:
		get_tree().change_scene_to_file(CENA_GAMEOVER)
		return
	transicao.flash(0.3, Color(0.6, 0.05, 0.05, 0.7))
	transicao.transition_to(CENA_GAMEOVER, 0.8)

## Frota inimiga destruída: abre a tela de vitória (Espaço volta ao menu).
func vencer() -> void:
	if _game_over:
		return
	_game_over = true
	_dormindo = false
	_burn_time = 0.0
	_boost_t = 0.0
	speed = 0.0
	set_physics_process(false)
	if _fire_fx != null:
		_fire_fx.emitting = false
	if _zzz != null:
		_zzz.visible = false
	var transicao := get_node_or_null("/root/Transicao")
	if transicao == null:
		get_tree().change_scene_to_file(CENA_VITORIA)
		return
	transicao.flash(0.4, Color(1.0, 0.9, 0.5, 0.8))
	transicao.transition_to(CENA_VITORIA, 0.9)

func _build_zzz() -> void:
	_zzz = Label.new()
	_zzz.name = "Zzz"
	_zzz.text = "Zzz"
	_zzz.add_theme_font_size_override("font_size", 28)
	_zzz.add_theme_color_override("font_color", Color(1.0, 0.95, 0.6))
	_zzz.add_theme_color_override("font_outline_color", Color(0.05, 0.05, 0.1))
	_zzz.add_theme_constant_override("outline_size", 5)
	_zzz.z_index = 100
	_zzz.visible = false
	add_child(_zzz)

func _build_fire_fx() -> void:
	_fire_fx = CPUParticles2D.new()
	_fire_fx.name = "Fogo"
	_fire_fx.texture = load(FLAME_TEX)
	_fire_fx.amount = 24
	_fire_fx.lifetime = 0.6
	_fire_fx.direction = Vector2.UP
	_fire_fx.spread = 180.0
	_fire_fx.gravity = Vector2.ZERO
	_fire_fx.initial_velocity_min = 20.0
	_fire_fx.initial_velocity_max = 70.0
	_fire_fx.scale_amount_min = 0.05
	_fire_fx.scale_amount_max = 0.13
	_fire_fx.color = Color(1.0, 0.55, 0.15, 0.9)
	_fire_fx.emitting = false
	add_child(_fire_fx)
