extends Node2D

## Mira (crosshair) desenhada na posição do mouse, no mundo.
## Esconde o cursor do sistema para deixar só a mira durante o jogo.

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

func _process(_delta: float) -> void:
	global_position = get_global_mouse_position()
	queue_redraw()

func _draw() -> void:
	var cor := Color(1, 1, 1, 0.85)
	draw_arc(Vector2.ZERO, 11.0, 0.0, TAU, 32, cor, 2.0)
	draw_line(Vector2(-20, 0), Vector2(-6, 0), cor, 2.0)
	draw_line(Vector2(6, 0), Vector2(20, 0), cor, 2.0)
	draw_line(Vector2(0, -20), Vector2(0, -6), cor, 2.0)
	draw_line(Vector2(0, 6), Vector2(0, 20), cor, 2.0)
	draw_circle(Vector2.ZERO, 2.0, cor)
