extends Control

## Minimapa estilo Age of Empires: mapa do mundo com jogador, inimigos,
## boss e o retângulo da área visível.

const COR_FUNDO := Color(0.02, 0.09, 0.16, 0.85)
const COR_BORDA := Color(1, 1, 1, 0.6)
const COR_VIEW := Color(1, 1, 1, 0.25)
const COR_JOGADOR := Color(0.55, 1.0, 0.40)
const COR_INIMIGO := Color(1.0, 0.35, 0.30)
const COR_BOSS := Color(1.0, 0.20, 0.55)

func _process(_delta: float) -> void:
	queue_redraw()

func _w2m(p: Vector2) -> Vector2:
	var r := Mapa.rect
	return (p - r.position) / r.size * size

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), COR_FUNDO, true)

	var cam := get_viewport().get_camera_2d()
	if cam != null:
		var vp := get_viewport_rect().size
		var center := cam.get_screen_center_position()
		var tl := _w2m(center - vp * 0.5)
		var br := _w2m(center + vp * 0.5)
		draw_rect(Rect2(tl, br - tl), COR_VIEW, false, 1.0)

	for e in get_tree().get_nodes_in_group("inimigos"):
		if e is Node2D:
			draw_circle(_w2m(e.global_position), 3.0, COR_INIMIGO)
	for b in get_tree().get_nodes_in_group("boss"):
		if b is Node2D:
			draw_circle(_w2m(b.global_position), 5.0, COR_BOSS)
	if Mapa.jogador != null and is_instance_valid(Mapa.jogador):
		draw_circle(_w2m(Mapa.jogador.global_position), 4.0, COR_JOGADOR)

	draw_rect(Rect2(Vector2.ZERO, size), COR_BORDA, false, 1.0)
