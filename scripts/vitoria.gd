extends Control

## Tela de vitória (frota inimiga destruída): win.png em tela cheia.
## Espaço (ou Enter) volta para a tela inicial.

const CENA_MENU := "res://scenes/TelaInicial.tscn"
const MUSICA := "res://FarFromHereTheme.mp3"

var _started := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var audio := get_node_or_null("/root/Audio")
	if audio != null:
		audio.reset_combat()
		audio.play_music(MUSICA, true, 1.0)
	_pulsar()

func _pulsar() -> void:
	var win := get_node_or_null("Fundo") as CanvasItem
	if win == null:
		return
	var t := create_tween().set_loops()
	t.tween_property(win, "modulate:a", 0.82, 0.9).set_trans(Tween.TRANS_SINE)
	t.tween_property(win, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_continuar()

func _continuar() -> void:
	if _started:
		return
	_started = true
	var transicao := get_node_or_null("/root/Transicao")
	if transicao == null:
		get_tree().change_scene_to_file(CENA_MENU)
		return
	transicao.flash(0.25)
	transicao.transition_to(CENA_MENU, 0.6)
