extends Control

## Tela inicial: logo com "respiração" de escala, "Press Space to Play" pulsante.
## Ao pressionar Espaço (ou Enter): efeito visual + fade out/in e troca de música.

const CENA_FASE := "res://scenes/Fase1.tscn"
const MUSICA_JOGO := "res://navegando.mp3"

var _started := false
var _logo_tween: Tween

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var audio := get_node_or_null("/root/Audio")
	if audio != null:
		audio.play_music()
	_animar_logo.call_deferred()
	_animar_press()

func _animar_logo() -> void:
	var logo := get_node_or_null("Logo") as Control
	if logo == null:
		return
	logo.pivot_offset = logo.size * 0.5
	_logo_tween = create_tween().set_loops()
	_logo_tween.tween_property(logo, "scale", Vector2(1.05, 1.05), 1.3) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_logo_tween.tween_property(logo, "scale", Vector2.ONE, 1.3) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _animar_press() -> void:
	var press := get_node_or_null("PressSpace") as CanvasItem
	if press == null:
		return
	var t := create_tween().set_loops()
	t.tween_property(press, "modulate:a", 0.25, 0.7).set_trans(Tween.TRANS_SINE)
	t.tween_property(press, "modulate:a", 1.0, 0.7).set_trans(Tween.TRANS_SINE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_iniciar()

func _iniciar() -> void:
	if _started:
		return
	_started = true

	var logo := get_node_or_null("Logo") as Control
	if logo != null:
		if _logo_tween != null:
			_logo_tween.kill()
		var t := create_tween()
		t.tween_property(logo, "scale", Vector2(1.18, 1.18), 0.12).set_trans(Tween.TRANS_BACK)
		t.tween_property(logo, "scale", Vector2.ONE, 0.25)

	var transicao := get_node_or_null("/root/Transicao")
	if transicao == null:
		get_tree().change_scene_to_file(CENA_FASE)
		return
	transicao.flash(0.25)
	transicao.transition_to(CENA_FASE, 0.6, func() -> void:
		var audio := get_node_or_null("/root/Audio")
		if audio != null:
			audio.play_music(MUSICA_JOGO, true, 0.9))
