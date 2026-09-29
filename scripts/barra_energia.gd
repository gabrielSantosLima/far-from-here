extends Control

## Barra de energia do jogador: lê energia/max_energia do nó no grupo.
## Fica logo abaixo da barra de vida.

@export var grupo := "jogador"
@export var cor := Color(0.95, 0.8, 0.2)
@export var rotulo := "ENERGIA"

var _alvo: Node = null

func _process(_delta: float) -> void:
	if _alvo == null or not is_instance_valid(_alvo):
		_alvo = get_tree().get_first_node_in_group(grupo)
	var mostrar: bool = _alvo != null and is_instance_valid(_alvo)
	if mostrar != visible:
		visible = mostrar
	if visible:
		queue_redraw()

func _draw() -> void:
	if _alvo == null or not is_instance_valid(_alvo):
		return
	var w := size.x
	var h := size.y
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.05, 0.05, 0.08, 0.85), true)
	var frac: float = clampf(float(_alvo.energia) / float(_alvo.max_energia), 0.0, 1.0)
	draw_rect(Rect2(Vector2(3, 3), Vector2((w - 6) * frac, h - 6)), cor, true)
	draw_rect(Rect2(Vector2.ZERO, size), Color(1, 1, 1, 0.7), false, 2.0)
	if rotulo != "":
		draw_string(ThemeDB.fallback_font, Vector2(4, -6), rotulo, HORIZONTAL_ALIGNMENT_LEFT, -1, 16, Color.WHITE)
