class_name Mapa
extends RefCounted

## Estado global do mundo (classe estática): limites, referência ao jogador
## e registro das ações de input.

static var rect := Rect2(0, 0, 4800, 3200)
static var jogador: Node2D = null

static func clamp_pos(p: Vector2) -> Vector2:
	return Vector2(
		clampf(p.x, rect.position.x, rect.end.x),
		clampf(p.y, rect.position.y, rect.end.y)
	)

static func ensure_input() -> void:
	_ensure_action("acelerar", [KEY_W, KEY_UP])
	_ensure_action("desacelerar", [KEY_S, KEY_DOWN])
	_ensure_action("esquerda", [KEY_A, KEY_LEFT])
	_ensure_action("direita", [KEY_D, KEY_RIGHT])
	_ensure_action("boost", [KEY_SHIFT])
	_ensure_mouse_action("atirar", MOUSE_BUTTON_LEFT)

static func _ensure_mouse_action(action: String, button: int) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	var ev := InputEventMouseButton.new()
	ev.button_index = button
	InputMap.action_add_event(action, ev)

static func _ensure_action(action: String, keys: Array) -> void:
	if InputMap.has_action(action):
		return
	InputMap.add_action(action)
	for k in keys:
		var ev := InputEventKey.new()
		ev.physical_keycode = k
		InputMap.action_add_event(action, ev)
