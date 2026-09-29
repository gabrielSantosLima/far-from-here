extends CanvasLayer

## Autoload "Transicao": fade out/in entre cenas (com flash opcional).
## Fica acima de tudo (layer alto) e não bloqueia cliques quando invisível.

var _fade: ColorRect
var _flash: ColorRect
var _busy := false

func _ready() -> void:
	layer = 128
	_fade = _make_rect(Color(0, 0, 0, 0))
	_flash = _make_rect(Color(1, 1, 1, 0))

func _make_rect(color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = color
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(rect)
	return rect

func flash(duration := 0.25, color := Color(1, 1, 1, 0.7)) -> void:
	_flash.color = color
	var t := create_tween()
	t.tween_property(_flash, "color:a", 0.0, duration)

func transition_to(scene_path: String, duration := 0.6, mid: Callable = Callable()) -> void:
	if _busy:
		return
	_busy = true
	var out := create_tween()
	out.tween_property(_fade, "color:a", 1.0, duration)
	await out.finished
	if mid.is_valid():
		mid.call()
	get_tree().change_scene_to_file(scene_path)
	await get_tree().process_frame
	var fin := create_tween()
	fin.tween_property(_fade, "color:a", 0.0, duration)
	await fin.finished
	_busy = false
