extends Control

## Tela de game over: imagem em tela cheia. Espaço (ou Enter) reinicia a Fase 1.

const CENA_FASE := "res://scenes/Fase1.tscn"
const MUSICA_JOGO := "res://navegando.mp3"
const MUSICA_GAMEOVER := "res://gameover.mp3"

var _started := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var audio := get_node_or_null("/root/Audio")
	if audio != null:
		audio.reset_combat()
		audio.play_music(MUSICA_GAMEOVER, true, 1.0)
	_pulsar()

func _pulsar() -> void:
	var press := get_node_or_null("Fundo") as CanvasItem
	if press == null:
		return
	var t := create_tween().set_loops()
	t.tween_property(press, "modulate:a", 0.82, 0.9).set_trans(Tween.TRANS_SINE)
	t.tween_property(press, "modulate:a", 1.0, 0.9).set_trans(Tween.TRANS_SINE)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_reiniciar()

func _reiniciar() -> void:
	if _started:
		return
	_started = true
	var transicao := get_node_or_null("/root/Transicao")
	if transicao == null:
		get_tree().change_scene_to_file(CENA_FASE)
		return
	transicao.flash(0.25)
	transicao.transition_to(CENA_FASE, 0.6, func() -> void:
		var audio := get_node_or_null("/root/Audio")
		if audio != null:
			audio.play_music(MUSICA_JOGO, true, 0.9))
