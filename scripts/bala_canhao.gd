extends Node2D

## Bola de canhão com física simples de projétil: viaja em linha reta (lenta)
## até o alvo, descrevendo um arco de altura (a bola "voa"). Uma sombra fica
## parada no ponto de queda indicando onde a bola vai cair. O dano é aplicado
## na aterrissagem (dá tempo de desviar).

const EXPLOSAO := preload("res://scenes/Explosao.tscn")

var _origem := Vector2.ZERO
var _alvo := Vector2.ZERO
var _tempo := 0.0
var _duracao := 1.0
var _altura := 70.0
var _dono := "jogador"
var _dano := 1
var _pronto := false

@onready var _bola: Sprite2D = $Bola
@onready var _sombra: Sprite2D = $Sombra

func _ready() -> void:
	add_to_group("bala")

## velocidade em px/s (quanto menor, mais lento e mais fácil desviar).
func configurar(origem: Vector2, alvo: Vector2, velocidade := 330.0,
		dono := "jogador", dano := 1) -> void:
	_origem = origem
	_alvo = alvo
	_dono = dono
	_dano = dano
	_duracao = maxf(origem.distance_to(alvo) / maxf(velocidade, 1.0), 0.3)
	global_position = origem
	_pronto = true

func _physics_process(delta: float) -> void:
	if not _pronto:
		return
	_tempo += delta
	var u := clampf(_tempo / _duracao, 0.0, 1.0)
	global_position = _origem.lerp(_alvo, u)

	var z := _altura * 4.0 * u * (1.0 - u)  # parábola (0 -> altura -> 0)
	_bola.position.y = -z
	_bola.scale = Vector2.ONE * (2.0 + z / 120.0)

	# sombra fixa no ponto de queda, indicando o alvo
	_sombra.global_position = _alvo
	_sombra.scale = Vector2(0.17, 0.085) * (1.0 + 0.4 * u)

	if u >= 1.0:
		_impacto()

func _impacto() -> void:
	_pronto = false
	var explosao := EXPLOSAO.instantiate() as Node2D
	explosao.scale = Vector2(0.7, 0.7)
	get_parent().add_child(explosao)
	explosao.global_position = _alvo
	_aplicar_dano()
	queue_free()

func _aplicar_dano() -> void:
	if _dono == "inimigo":
		var p := Mapa.jogador
		if p != null and is_instance_valid(p) and _alvo.distance_to(p.global_position) <= 46.0:
			p.take_damage(_dano)
	else:
		for grupo in ["inimigos", "boss"]:
			for e in get_tree().get_nodes_in_group(grupo):
				var raio: float = e.get("hit_radius")
				if raio > 0.0 and _alvo.distance_to(e.global_position) <= raio:
					e.take_damage(_dano)
