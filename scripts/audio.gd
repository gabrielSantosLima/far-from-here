extends Node

## Autoload "Audio": música-tema com crossfade suave entre faixas e
## controle de volume/mudo. A tecla M alterna o mudo em qualquer tela.

const TEMA := "res://FarFromHereTheme.mp3"
const CALMA := "res://navegando.mp3"
const BATALHA := "res://batalha.mp3"

var _a: AudioStreamPlayer
var _b: AudioStreamPlayer
var _current: AudioStreamPlayer
var _volume := 0.8
var _muted := false
var _combat := 0
var _tempo := 1.0

## Chamado pelos inimigos quando entram/saem de combate.
## A música troca para batalha no primeiro e volta à calma quando o último desiste.
func enter_combat() -> void:
	_combat += 1
	if _combat == 1:
		play_music(BATALHA, true, 0.8)

func exit_combat() -> void:
	_combat = maxi(_combat - 1, 0)
	if _combat == 0:
		set_tempo(1.0)
		play_music(CALMA, true, 1.2)

func in_combat() -> bool:
	return _combat > 0

## Zera o combate e o tempo da música (usado ao reiniciar a fase no game over).
func reset_combat() -> void:
	_combat = 0
	set_tempo(1.0)

## Acelera/desacelera a música (pitch). Usado na fase enraivecida do boss.
func set_tempo(scale: float) -> void:
	_tempo = clampf(scale, 0.5, 2.0)
	_a.pitch_scale = _tempo
	_b.pitch_scale = _tempo

func _ready() -> void:
	_a = _make_player()
	_b = _make_player()
	_current = _a
	_apply()

func _make_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	add_child(p)
	return p

## toca path; se já houver música, faz crossfade de "fade" segundos.
func play_music(path: String = TEMA, loop: bool = true, fade: float = 0.0) -> void:
	var stream := load(path) as AudioStream
	if stream == null:
		push_warning("Audio: stream nao encontrado: " + path)
		return
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = loop
	if _current.stream == stream and _current.playing:
		return

	var old := _current
	var novo := _b if _current == _a else _a
	_current = novo
	novo.stream = stream
	novo.volume_db = -80.0 if fade > 0.0 else _target_db()
	novo.play()

	if fade > 0.0:
		var t := create_tween().set_parallel(true)
		t.tween_property(novo, "volume_db", _target_db(), fade)
		t.tween_property(old, "volume_db", -80.0, fade)
		t.chain().tween_callback(old.stop)
	else:
		old.stop()

func stop_music() -> void:
	_a.stop()
	_b.stop()

func set_volume(v: float) -> void:
	_volume = clampf(v, 0.0, 1.0)
	_apply()

func get_volume() -> float:
	return _volume

func toggle_mute() -> void:
	_muted = not _muted
	_apply()

func is_muted() -> bool:
	return _muted

func _target_db() -> float:
	return -80.0 if (_muted or _volume <= 0.0) else linear_to_db(_volume)

func _apply() -> void:
	if _current != null:
		_current.volume_db = _target_db()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_M:
		toggle_mute()
